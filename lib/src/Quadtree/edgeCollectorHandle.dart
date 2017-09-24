part of PolygonalMap.Quadtree;

/// This is an edge handler which collects the edges into a set.
class EdgeCollectorHandle implements IEdgeHandler {
  /// The set to add new edges into.
  EdgeNodeSet _set;

  /// The matcher to filter the collected edges with.
  IEdgeHandler _filter;

  /// Create a new edge collector.
  EdgeCollectorHandle() {
    this._set = new EdgeNodeSet();
    this._filter = null;
  }

  /// Create a new edge collector.
  EdgeCollectorHandle({EdgeNodeSet set: null, IEdgeHandler filter: null}) {
    this._set = (set == null) ? new EdgeNodeSet() : set;
    this._filter = filter;
  }

  /// The set to add new edges into.
  EdgeNodeSet get collection => this._set;

  /// The matcher to filter the collected edges with.
  IEdgeHandler get filter => this._filter;

  /// Handles a new edge.
  @Override
  bool handle(EdgeNode edge) {
    if (this._filter != null) {
      if (!this._filter.handle(edge)) return true;
    }
    this._set.add(edge);
    return true;
  }
}
