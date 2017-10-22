part of tests;

/// The manager to run the tests.
class TestManager {
  html.Element _elem;
  html.DivElement _header;
  DateTime _start;
  List<TestBlock> _tests;
  int _finished;
  int _failed;
  int _testDivIndex;

  /// Creates new test manager attached to the given element.
  TestManager(this._elem) {
    _header = new html.DivElement();
    _elem.children.add(_header);
    html.DivElement checkBoxes = new html.DivElement()..className = "log_checkboxes";
    _createLogSwitch(checkBoxes, "Information", "info_log");
    _createLogSwitch(checkBoxes, "Notice", "notice_log");
    _createLogSwitch(checkBoxes, "Warning", "warning_log");
    _createLogSwitch(checkBoxes, "Error", "error_log");
    _elem.children.add(checkBoxes);
    _start = new DateTime.now();
    _tests = new List<TestBlock>();
    _finished = 0;
    _failed = 0;
    _testDivIndex = 0;
  }

  /// gets an index for a test div which is unique.
  int get takeDivIndex {
    int result = _testDivIndex;
    _testDivIndex++;
    return result;
  }

  /// Creates a check box for changing the visibility of logs with the given [type].
  void _createLogSwitch(html.DivElement checkBoxes, String text, String type) {
    html.CheckboxInputElement checkBox = new html.CheckboxInputElement()
      ..className = "log_checkbox"
      ..checked = true;
    checkBox.onChange.listen((_) {
      html.ElementList<html.Element> myElements = html.document.querySelectorAll(".$type");
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
    _finished++;
    if (block.failed) _failed++;
    _update();
    if (_finished < _tests.length) {
      new asy.Future(() {
        html.window.requestAnimationFrame((_) {});
        _tests[_finished].run();
      });
    }
  }

  /// Updates the top header of the tests.
  void _update() {
    String time = ((new DateTime.now().difference(_start).inMilliseconds) * 0.001).toStringAsFixed(2);
    int testCount = _tests.length;
    if (testCount <= _finished) {
      if (_failed > 0) {
        _header.className = "top_header failed";
        if (_failed == 1)
          _header.text = "Failed 1 Test (${time}s)";
        else
          _header.text = "Failed ${this._failed} Tests (${time}s)";
      } else {
        _header
          ..text = "Tests Passed (${time}s)"
          ..className = "top_header passed";
      }
    } else {
      String prec = ((_finished.toDouble() / testCount) * 100.0).toStringAsFixed(2);
      _header.text = "Running Tests: ${this._finished}/${testCount} ($prec%)";
      if (_failed > 0) {
        _header
          ..text = "${this._header.text} - ${this._failed} failed)"
          ..className = "topHeader failed";
      } else {
        _header.className = "topHeader running";
      }
    }
  }

  /// Adds a new test to be run.
  void add(String testName, TestHandler test) {
    if (testName.length <= 0) testName = "$test";
    _tests.add(new TestBlock(this, test, testName));
    _update();

    // If currently none are running, start this one.
    if (_finished + 1 == _tests.length) {
      new asy.Future(() {
        html.window.requestAnimationFrame((_) {});
        _tests[_finished].run();
      });
    }
  }
}
