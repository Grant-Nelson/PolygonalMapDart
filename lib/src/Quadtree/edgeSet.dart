part of PolygonalMapDart.Quadtree;

/// A set of edge nodes.
class EdgeSet {

  /// The internal set of edges.
  Set<IEdge> _set;

  /// Create a set of edge nodes.
  EdgeSet() {
    this._set = new Set<IEdge>();
  }

  /// Gets the internal set of edges.
  Set<IEdge> get edges => this._set;
}
