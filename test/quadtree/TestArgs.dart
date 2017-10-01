part of quadtree_test;

/// The arguments for a unit-test.
class TestArgs {
  /// Indicates if the test has failed.
  bool _fail;

  /// Indicates if output should be verbose.
  bool _verbose;

  /// Creates a new test arguments.
  /// [verbose] indicates true to run the test verbosely,
  /// false to run the test quietly.
  TestArgs(bool verbose) {
    this._fail = false;
    this._verbose = verbose;
  }

  /// Indicates that the test should be run verbosely.
  /// Returns true to run the test verbosely,
  /// false to run the test quietly.
  bool get verbose => this._verbose;

  /// Indicates if the test has failed or not.
  /// Returns true if failed, false if not.
  bool get hasFailed => this._fail;

  /// Prints to the test log.
  void print(Object arg) {
    if (this._verbose) {
      stdout.write(arg);
    }
  }

  /// Prints to the test log followed by a new line.
  void println(Object arg) {
    if (this._verbose) {
      stdout.writeln(arg);
    }
  }

  /// Prints to the test log and marks the test as failed.
  void failed([Object arg = null]) {
    this._fail = true;
    if (arg != null) {
      stdout.writeln(arg);
    }
  }

  /**
     * Gets the string for the trace elements for the given frame.
     * @param frame The offset to the top frame of the stack.
     * @param count The number of frames to return.
     * @param indent The indent to each line of the trace.
     * @return The string for the trace.
     */
  String getTraceString(int frame, int count, String indent) {
    String trace = StackTrace.current.toString();
    List<String> lines = trace.split("\n");
    lines = lines.sublist(frame * 2 + 1, (frame + count) * 2 + 1);
    return lines.join(",{$indent}");
  }

  /**
     * Prints the trace elements for the given frame to the test log.
     * @param frame The offset to the top frame of the stack.
     * @param count The number of frames to return.
     * @param indent The indent to each line of the trace.
     */
  void printTrace(int frame, int count, String indent) {
    stdout.writeln(this.getTraceString(frame, count, indent));
  }
}
