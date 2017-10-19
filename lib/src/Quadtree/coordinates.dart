part of PolygonalMapDart.Quadtree;

/// The coordinate converter is used for getting the desired coordinates.
class Coordinates implements IFormatter {
  /// The maximum allowed coordinate value, 2^31-1.
  static const Maximum = 2147483647;

  /// The minimum allowed coordinate value, -2^31.
  static const Minimum = -2147483648;

  /// The default format for the coordinates.
  static const String _defaultFormat = "#0.00";

  /// The first component (X) of the center point of the coordinate system.
  final double centerX;

  /// The second component (Y) of the center point of the coordinate system.
  final double centerY;

  /// The precision of the first coordinate component, smallest X change.
  final double smallestX;

  /// The precision of the second coordinate component, smallest Y change.
  final double smallestY;

  /// The format for the first component (X).
  final NumberFormat formatX;

  /// The format for the second component (Y).
  final NumberFormat formatY;

  /// Creates a coordinate converter.
  /// [smallest] is the precision of the coordinate components, smallest X and Y change.
  factory Coordinates.Origin(double smallest,
      [String format = _defaultFormat]) {
    NumberFormat numFmt = new NumberFormat(format, "en_US");
    return new Coordinates(0.0, 0.0, smallest, smallest, numFmt, numFmt);
  }

  /// Creates a coordinate converter.
  /// [centerX] is the first component (X) of the center point of the coordinate system.
  /// [centerY] is the second component (Y) of the center point of the coordinate system.
  /// [smallest] is the precision of the coordinate components, smallest X and Y change.
  factory Coordinates.Symmetric(double centerX, double centerY, double smallest,
      [String format = _defaultFormat]) {
    NumberFormat numFmt = new NumberFormat(format, "en_US");
    return new Coordinates(
        centerX, centerY, smallest, smallest, numFmt, numFmt);
  }

  /// Creates a coordinate converter.
  /// [centerX] is the first component (X) of the center point of the coordinate system.
  /// [centerY] is the second component (Y) of the center point of the coordinate system.
  /// [smallestX] is the precision of the first coordinate component, smallest X change.
  /// [smallestY] is the precision of the second coordinate component, smallest Y change.
  /// [formatX] is the format for the first component (X).
  /// [formatY] is the format for the second component (Y).
  Coordinates(
      this.centerX,
      this.centerY,
      this.smallestX,
      this.smallestY,
      this.formatX,
      this.formatY);

  /// Gets the minimum X component in the coordinate system that can be used.
  double get minX => toX(Maximum);

  /// Gets the minimum Y component in the coordinate system that can be used.
  double get minY => toY(Minimum);

  /// Gets the maximum X component in the coordinate system that can be used.
  double get maxX => toX(Maximum);

  /// Gets the maximum Y component in the coordinate system that can be used.
  double get maxY => toY(Minimum);

  /// Gets the quad-tree x component from the first coordinate component.
  int fromX(double x) => ((x - centerX) / smallestX).round();

  /// Gets the quad-tree y component from the second coordinate component.
  int fromY(double y) => ((y - centerY) / smallestY).round();

  /// Gets the change in the first component (width) from a width in the coordinate system.
  int fromWidth(double width) => (width / smallestX).round();

  /// Gets the change in the second component (height) from a height in the coordinate system.
  int fromHeight(double height) => (height / smallestY).round();

  /// Gets the first coordinate component from the given quad-tree x value.
  double toX(int x) => x * smallestX + centerX;

  /// Gets the second coordinate component from the given quad-tree y value.
  double toY(int y) => y * smallestY + centerY;

  /// Gets the width in the coordinate system from a change in the first component (width).
  double toWidth(int width) => width * smallestX;

  /// Gets the height in the coordinate system from a change in the second component (height).
  double toHeight(int height) => height * smallestY;

  /// Creates a point for the quad-tree from values in the coordinate system.
  Point toPoint(double x, double y) => new Point(fromX(x), fromY(y));

  /// Creates an edge for the quad-tree from values in the coordinate system.
  Edge toEdge(double x1, double y1, double x2, double y2) =>
      new Edge(new Point(fromX(x1), fromY(y1)), new Point(fromX(x2), fromY(y2)));

  /// Converts a x value to a string.
  String toXString(int x) => formatX.format(toX(x));

  /// Converts a y value to a string.
  String toYString(int y) => formatY.format(toY(y));

  /// Converts a width value to a string.
  String toWidthString(int width) => formatX.format(toWidth(width));

  /// Converts a height value to a string.
  String toHeightString(int height) =>
      formatY.format(toHeight(height));

  /// Converts a point to a string.
  String toPointString(IPoint point) =>
      "[" + toXString(point.x) + ", " + toYString(point.y) + "]";

  /// Converts an edge to a string.
  String toEdgeString(IEdge edge) =>
      "[${toXString(edge.x1)}, ${toYString(edge.y1)}, ${toXString(edge.x2)}, ${toYString(edge.y2)}]";

  /// Converts a boundary to a string.
  String toBoundaryString(IBoundary boundary) =>
      "[${toXString(boundary.xmin)}, ${toYString(boundary.ymin)}, ${toXString(boundary.xmax)}, ${toYString(boundary.ymax)}]";
}
