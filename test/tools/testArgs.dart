part of tests;

/// The method handler for unit-tests.
/// [args] are provided to call-back the status of the test.
typedef void TestHandler(TestArgs args);

/// The interface for the unit-test to callback with.
abstract class TestArgs {

  /// The title of the unit-test.
  String get title;
  set title(String title);

  /// Indicates if the test has failed.
  bool get failed;

  // addDiv adds a div element to the test output.
  String addDiv([int width = 600, int height = 400]);

  /// Marks this test as failed.
  void fail();

  /// Prints text to the test's output console as an information.
  void info(String text);

  /// Prints text to the test's output console as a notice.
  void notice(String text);

  /// Prints text to the test's output console as a warning.
  void warning(String text);

  /// Prints text to the test's output console as an error.
  /// This will also mark this test as a failure.
  void error(String text);
}
