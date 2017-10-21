part of tests;

/// The block for the unit-test output and the test arguments.
class TestBlock extends TestArgs {
  TestManager _man;
  html.DivElement _body;
  html.DivElement _title;
  DateTime _start;
  DateTime _end;
  TestHandler _test;
  String _testName;
  bool _started;
  bool _failed;
  bool _finished;

  /// Creates a new test block for the given test.
  TestBlock(this._man, this._test, this._testName) {
    _body = new html.DivElement()..className = "test_body body_hidden";
    _title = new html.DivElement()
      ..className = "running top_header"
      ..onClick.listen(_titleClicked);
    _man._elem.children..add(_title)..add(_body);
    _start = null;
    _end = null;
    _started = false;
    _failed = false;
    _finished = false;
    _update();
  }

  /// Handles the test title clicked to show and hide the test output.
  void _titleClicked(_) {
    if (_body.className != "test_body body_hidden")
      _body.className = "test_body body_hidden";
    else
      _body.className = "test_body body_shown";
  }

  /// Updates the test header.
  void _update() {
    String time = "";
    if (_start != null) {
      DateTime end = _end;
      if (end == null) end = new DateTime.now();
      time = ((end.difference(_start).inMilliseconds) * 0.001).toStringAsFixed(2);
      time = "(${time}s)";
    }
    if (!_started) {
      _title
        ..className = "test_header queued"
        ..text = "Queued: $_testName $time";
    } else if (_failed) {
      _title
        ..className = "test_header failed"
        ..text = "Failed: $_testName $time";
    } else if (_finished) {
      _title
        ..className = "test_header passed"
        ..text = "Passed: $_testName $time";
    } else {
      _title
        ..className = "test_header running"
        ..text = "Running: $_testName $time";
    }
    _man._update();
  }

  /// Runs this test asynchronously in the event loop.
  void run() {
    new asy.Future(() {
      _started = true;
      _update();
      html.window.requestAnimationFrame((_) {});
    }).then((_) {
      _start = new DateTime.now();
      _test(this);
      _end = new DateTime.now();
    }).catchError((exception, stackTrace) {
      _end = new DateTime.now();
      error("\nException: $exception");
      warning("\nStack: $stackTrace");
    }).then((_) {
      _finished = true;
      _man._testDone(this);
      _update();
      html.window.requestAnimationFrame((_) {});
    });
  }

  /// Adds a div element to the test output.
  html.DivElement addDiv() {
    html.DivElement div = new html.DivElement()
      ..className = "test_div"
      ..id = "testDiv${_man.takeDivIndex}";
    _body.children.add(div);
    return div;
  }

  /// Adds a new log event
  void _addLog(String text, String type) {
    List<String> entries = _man._escape.convert(text).replaceAll(" ", "&nbsp;").split("\n");

    if (entries.isNotEmpty) {
      if (entries[0].isNotEmpty) {
        _body.children.add(new html.DivElement()
          ..className = type
          ..text = entries[0]);
      }
      for (int i = 1; i < entries.length; i++) {
        _body.children.add(new html.BRElement()..className = type);

        if (entries[i].isNotEmpty) {
          _body.children.add(new html.DivElement()
            ..className = type
            ..text = entries[i]);
        }
      }
    }
  }

  /// Prints text to the test's output console as an information.
  void info(String text) {
    _addLog(text, "info_log");
  }

  /// Prints text to the test's output console as a notice.
  void notice(String text) {
    _addLog(text, "notice_log");
  }

  /// Prints text to the test's output console as a warning.
  void warning(String text) {
    _addLog(text, "warning_log");
  }

  /// Prints text to the test's output console as an error.
  /// This will also mark this test as a failure.
  void error(String text) {
    _addLog(text, "error_log");
    fail();
  }

  /// The title of the unit-test.
  String get title => _testName;
  set title(String title) {
    _testName = title;
    _update();
  }

  /// Indicates if the test had started.
  bool get stated => _started;

  /// Indicates if the test had finished.
  bool get finished => _finished;

  /// Indicates if the test has failed.
  bool get failed => _failed;

  /// Marks this test as failed.
  void fail() {
    if (!_failed) {
      _failed = true;
      _update();
    }
  }
}
