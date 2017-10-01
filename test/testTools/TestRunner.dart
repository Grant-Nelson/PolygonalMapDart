part of tests;

/// This is called to run the unit-test.=
typedef void TestHandler(TestArgs args);

/// A tool for running a set of unit-tests.
class TestRunner {

  /// The set of test to run.
  List<TestHandler> _tests;

  /// Indicates testing should stop on failure.
  bool _stopOnFail;

  /// Show the stack on exception.
  bool _showStack;

  /// Indicates that tests should be run verbosely.
  bool _verbose;

  /// Indicates that tests should be timed.
  bool _timed;

  /// Indicates exceptions should be caught.
  bool _catchExceptions;

  /// Creates a new test runner.
  TestRunner() {
    this._tests = new List<TestHandler>();
    this._stopOnFail = false;
    this._showStack = true;
    this._verbose = true;
    this._timed = true;
    this._catchExceptions = true;
  }

    /// Indicates testing should stop on failure.
    bool get stopOnFail => this._stopOnFail;
    set stopOnFail(bool stopOnFail) =>this._stopOnFail = stopOnFail;

    /// Show the stack on exception.
    bool get showStack =>this._showStack;
    set showStack(bool showStack) =>this._showStack = showStack;

    /// Indicates that tests should be run verbosely.
    bool get verbose => this._verbose;
    set verbose(bool verbose) =>  this._verbose = verbose;

    /// Indicates that tests should be timed.
    bool get timed =>  this._timed;
    set timed(bool timed) =>  this._timed = timed;

    /// Indicates if exceptions should be caught.
    /// It useful to not catch exceptions when debugging in an IDE.
    /// Exceptions should be caught when not debugging.
    bool get catchExceptions =>  this._catchExceptions;
    set catchExceptions(bool catchExceptions) => this._catchExceptions = catchExceptions;

    /// The list of all the tests to be run.
    List<TestHandler> get tests => this._tests;

    /// Adds a test to the runner.
    void addTest(TestHandler test) => this._tests.add(test);

    /// Runs all the tests.
    /// Returns true if all tests passed, false if any test failed.
    bool runTests() {
        if (this._verbose)
            stdout.writeln("Running ${this._tests.length} tests...");

        int tested = 0;
        int failed = 0;
        DateTime start = new DateTime.now();
        for (TestHandler test in this._tests) {
            tested++;
            if (!this.runTest(test)) {
                failed++;
                if (this._stopOnFail) break;
            }
        }
        DateTime end = new DateTime.now();

        if (this._verbose)
            stdout.writeln("Ran $tested of ${this._tests.length} tests.");

        if (failed > 0) {
            stdout.write("Failed $failed tests.");
            if (this._timed)
                stdout.write(" (${end.difference(start)})");
            stdout.writeln();
            return false;
        } else {
            stdout.write("All tests passed.");
            if (this._timed)
                stdout.write(" (${end.difference(start)})");
            stdout.writeln();
            return true;
        }
    }

    /// Runs the given test.
    bool runTest(TestHandler test) {
        String name = test.runtimeType.toString();
        if (this._verbose)
            stdout.writeln("Running "+name+"...");

        TestArgs args = new TestArgs(this._verbose);
        DateTime start = new DateTime.now();
        if (this._catchExceptions) {
            try {
                test(args);
            } catch (ex) {
                args.failed("Exception: "+ex.getMessage());
            }
        } else {
            test(args);
        }

        DateTime end = new DateTime.now();
        if (args.hasFailed) {
            stdout.write("Failed");
            if (this._timed)
                stdout.write(" (${end.difference(start)})");
            stdout.writeln(": "+name);
            return false;
        } else {
            stdout.write("Passed");
            if (this._timed)
                stdout.write(" (${end.difference(start)})");
            stdout.writeln(": "+name);
            return true;
        }
    }
}
