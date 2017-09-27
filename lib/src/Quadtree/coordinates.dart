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
  factory Coordinates.Origin(double smallest, [String format = _defaultFormat]) {
    NumberFormat numFmt = new NumberFormat(format, "en_US");
    return new Coordinates(0.0, 0.0, smallest, smallest, numFmt, numFmt);
  }

  /// Creates a coordinate converter.
  /// [centerX] is the first component (X) of the center point of the coordinate system.
  /// [centerY] is the second component (Y) of the center point of the coordinate system.
  /// [smallest] is the precision of the coordinate components, smallest X and Y change.
  factory Coordinates.Symmetric(double centerX, double centerY, double smallest, [String format = _defaultFormat]) {
    NumberFormat numFmt = new NumberFormat(format, "en_US");
    return new Coordinates(centerX, centerY, smallest, smallest, numFmt, numFmt);
  }

  /// Creates a coordinate converter.
  /// [centerX] is the first component (X) of the center point of the coordinate system.
  /// [centerY] is the second component (Y) of the center point of the coordinate system.
  /// [smallestX] is the precision of the first coordinate component, smallest X change.
  /// [smallestY] is the precision of the second coordinate component, smallest Y change.
  /// [formatX] is the format for the first component (X).
  /// [formatY] is the format for the second component (Y).
  Coordinates(double this.centerX, double this.centerY, double this.smallestX, double this.smallestY,
      NumberFormat this.formatX, NumberFormat this.formatY);

  /// Gets the minimum X component in the coordinate system that can be used.
  double get minX => this.toX(Maximum);

  /// Gets the minimum Y component in the coordinate system that can be used.
  double get minY => this.toY(Minimum);

  /// Gets the maximum X component in the coordinate system that can be used.
  double get maxX => this.toX(Maximum);

  /// Gets the maximum Y component in the coordinate system that can be used.
  double get maxY => this.toY(Minimum);

  /// Gets the quad-tree x component from the first coordinate component.
  int fromX(double x) => ((x - this.centerX) / this.smallestX).round();

  /// Gets the quad-tree y component from the second coordinate component.
  int fromY(double y) => ((y - this.centerY) / this.smallestY).round();

  /// Gets the change in the first component (width) from a width in the coordinate system.
  int fromWidth(double width) => (width / this.smallestX).round();

  /// Gets the change in the second component (height) from a height in the coordinate system.
  int fromHeight(double height) => (height / this.smallestY).round();

  /// Gets the first coordinate component from the given quad-tree x value.
  double toX(int x) => x * this.smallestX + this.centerX;

  /// Gets the second coordinate component from the given quad-tree y value.
  double toY(int y) => y * this.smallestY + this.centerY;

  /// Gets the width in the coordinate system from a change in the first component (width).
  double toWidth(int width) => width * this.smallestX;

  /// Gets the height in the coordinate system from a change in the second component (height).
  double toHeight(int height) => height * this.smallestY;

  /// Creates a point for the quad-tree from values in the coordinate system.
  Point toPoint(double x, double y) => new Point(this.fromX(x), this.fromY(y));

  /// Creates an edge for the quad-tree from values in the coordinate system.
  Edge toEdge(double x1, double y1, double x2, double y2) =>
      new Edge(this.fromX(x1), this.fromY(y1), this.fromX(x2), this.fromY(y2));

  /// Converts a x value to a string.
  String toXString(int x) => this.formatX.format(this.toX(x));

  /// Converts a y value to a string.
  String toYString(int y) => this.formatY.format(this.toY(y));

  /// Converts a width value to a string.
  String toWidthString(int width) => this.formatX.format(this.toWidth(width));

  /// Converts a height value to a string.
  String toHeightString(int height) => this.formatY.format(this.toHeight(height));

  /// Converts a point to a string.
  String toPointString(IPoint point) => "[" + this.toXString(point.x) + ", " + this.toYString(point.y) + "]";

  /// Converts an edge to a string.
  String toEdgeString(IEdge edge) =>
      "[${toXString(edge.x1)}, ${toYString(edge.y1)}, ${toXString(edge.x2)}, ${toYString(edge.y2)}]";

  /// Converts a boundary to a string.
  String toBoundaryString(IBoundary boundary) =>
      "[${toXString(boundary.xmin)}, ${toYString(boundary.ymin)}, ${toXString(boundary.xmax)}, ${toYString(boundary.ymax)}]";
}
