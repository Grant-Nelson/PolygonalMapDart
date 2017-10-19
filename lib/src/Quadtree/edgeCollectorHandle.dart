part of PolygonalMapDart.Quadtree;

/// This is an edge handler which collects the edges into a set.
class EdgeCollectorHandle implements IEdgeHandler {
  /// The set to add new edges into.
  Set<EdgeNode> _set;

  /// The matcher to filter the collected edges with.
  IEdgeHandler _filter;

  /// Create a new edge collector.
  EdgeCollectorHandle({Set<EdgeNode> set: null, IEdgeHandler filter: null}) {
    this._set = (set == null) ? new Set<EdgeNode>() : set;
    this._filter = filter;
  }

  /// The set to add new edges into.
  Set<EdgeNode> get collection => this._set;

  /// The matcher to filter the collected edges with.
  IEdgeHandler get filter => this._filter;

  /// Handles a new edge.
  bool handle(EdgeNode edge) {
    if (this._filter != null) {
      if (!this._filter.handle(edge)) return true;
    }
    this._set.add(edge);
    return true;
  }
}
