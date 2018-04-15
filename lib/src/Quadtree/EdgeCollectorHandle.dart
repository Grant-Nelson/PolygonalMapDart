part of PolygonalMapDart.Quadtree;

/// This is an edge handler which collects the edges into a set.
class EdgeCollectorHandle implements IEdgeHandler {
  /// The set to add new edges into.
  Set<EdgeNode> _set;

  /// The matcher to filter the collected edges with.
  IEdgeHandler _filter;

  /// Create a new edge collector.
  EdgeCollectorHandle({Set<EdgeNode> edgeSet: null, IEdgeHandler filter: null}) {
    _set = (edgeSet == null) ? new Set<EdgeNode>() : edgeSet;
    _filter = filter;
  }

  /// The set to add new edges into.
  Set<EdgeNode> get collection => _set;

  /// The matcher to filter the collected edges with.
  IEdgeHandler get filter => _filter;

  /// Handles a new edge.
  bool handle(EdgeNode edge) {
    if (_filter != null) {
      if (!_filter.handle(edge)) return true;
    }
    _set.add(edge);
    return true;
  }
}
