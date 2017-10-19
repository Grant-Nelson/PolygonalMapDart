part of tests;

/// The manager to run the tests.
class TestManager {
  html.Element _elem;
  html.DivElement _header;
  convert.HtmlEscape _escape;
  DateTime _start;
  List<TestBlock> _tests;
  int _finished;
  int _failed;

  /// Creates new test manager attached to the given element.
  TestManager(this._elem) {
    this._escape = new convert.HtmlEscape(convert.HtmlEscapeMode.ELEMENT);
    this._header = new html.DivElement();
    this._elem.children.add(this._header);
    html.DivElement checkBoxes = new html.DivElement()
      ..className = "log_checkboxes";
    this._createLogSwitch(checkBoxes, "Information", "info_log");
    this._createLogSwitch(checkBoxes, "Notice", "notice_log");
    this._createLogSwitch(checkBoxes, "Warning", "warning_log");
    this._createLogSwitch(checkBoxes, "Error", "error_log");
    this._elem.children.add(checkBoxes);
    this._start = new DateTime.now();
    this._tests = new List<TestBlock>();
    this._finished = 0;
    this._failed = 0;
  }

  /// Creates a check box for changing the visibility of logs with the given [type].
  void _createLogSwitch(html.DivElement checkBoxes, String text, String type) {
    html.CheckboxInputElement checkBox = new html.CheckboxInputElement()
      ..className = "log_checkbox"
      ..checked = true;
    checkBox.onChange.listen((_) {
      html.ElementList<html.Element> myElements =
          html.document.querySelectorAll(".$type");
      String display = checkBox.checked ? "block" : "none";
      for (int i = 0; i < myElements.length; i++) {
        myElements[i].style.display = display;
      }
    });
    checkBoxes.children.add(checkBox);
    html.SpanElement span = new html.SpanElement()..text = text;
    checkBoxes.children.add(span);
  }

  /// Callback from a test to indicate it is done
  /// and to have the manager start a new test.
  void _testDone(TestBlock block) {
    this._finished++;
    if (block.failed) this._failed++;
    this._update();
    if (this._finished < this._tests.length) {
      new asy.Future(() {
        html.window.requestAnimationFrame((_) {});
        this._tests[this._finished].run();
      });
    }
  }

  /// Updates the top header of the tests.
  void _update() {
    String time =
        ((new DateTime.now().difference(this._start).inMilliseconds) * 0.001)
            .toStringAsFixed(2);
    int testCount = this._tests.length;
    if (testCount <= this._finished) {
      if (this._failed > 0) {
        this._header.className = "top_header failed";
        if (this._failed == 1)
          this._header.text = "Failed 1 Test (${time}s)";
        else
          this._header.text = "Failed ${this._failed} Tests (${time}s)";
      } else {
        this._header
          ..text = "Tests Passed (${time}s)"
          ..className = "top_header passed";
      }
    } else {
      String prec =
          ((this._finished.toDouble() / testCount) * 100.0).toStringAsFixed(2);
      this._header.text =
          "Running Tests: ${this._finished}/${testCount} ($prec%)";
      if (this._failed > 0) {
        this._header
          ..text = "${this._header.text} - ${this._failed} failed)"
          ..className = "topHeader failed";
      } else {
        this._header.className = "topHeader running";
      }
    }
  }

  /// Adds a new test to be run.
  void add(String testName, TestHandler test) {
    if (testName.length <= 0) testName = "$test";
    this._tests.add(new TestBlock(this, test, testName));
    this._update();

    // If currently none are running, start this one.
    if (this._finished + 1 == this._tests.length) {
      new asy.Future(() {
        html.window.requestAnimationFrame((_) {});
        this._tests[this._finished].run();
      });
    }
  }
}
