part of PolygonalMapDart.Maps;

/// The data for the edges in the region map.
/// The data defining identifier for the regions to the left and right of the edge
/// looking from the start point of the edge down to the end point.
class EdgeSide extends Object {
  /// The identifier of the region data to the left of the edge.
  int left;

  /// The identifier of the region data to the right of the edge.
  int right;

  /// Creates an edge side data.
  /// This specifies the identifiers of the region data to the [left] and [right] of the edge.
  EdgeSide(this.left, this.right);

  /// Creates a copy of the [other] edge side data.
  factory EdgeSide.copy(EdgeSide other) => new EdgeSide(other.left, other.right);

  /// A simple string displaying the data.
  String toString() => "[$left|$right]";
}
