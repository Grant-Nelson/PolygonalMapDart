part of PolygonalMapDart.Quadtree;

/// The interface for the formatting used for outputting data as strings.
abstract class IFormatter {
  /// Converts a x value to a string.
  String toXString(int x);

  /// Converts a y value to a string.
  String toYString(int y);

  /// Converts a width value to a string.
  String toWidthString(int width);

  /// Converts a height value to a string.
  String toHeightString(int height);

  /// Converts a point to a string.
  String toPointString(IPoint point);

  /// Converts an edge to a string.
  String toEdgeString(IEdge edge);

  /// Converts a boundary to a string.
  String toBoundaryString(IBoundary boundary);
}
