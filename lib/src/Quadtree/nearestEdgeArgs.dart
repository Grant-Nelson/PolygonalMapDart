part of PolygonalMapDart.Quadtree;

/// The nearest edge arguments to handle multiple returns
/// objects for determining the nearest edge to a point.
class NearestEdgeArgs {
  /// The query point to find the nearest line to.
  final IPoint _queryPoint;

  /// The line matcher to filter lines with.
  final IEdgeHandler _handle;

  /// The maximum allowable distance squared to the result.
  double _cutoffDist2;

  /// The currently found closest edge. Null if a point has been found closer.
  EdgeNode _resultEdge;

  /// The node if the nearest part of the edge is the point.
  /// Null if an edge has been found closer.
  PointNode _resultPoint;

  /// Creates a new nearest edge arguments.
  /// [queryPoint] is the query point to find an edge nearest to.
  /// [cutoffDist2] is the maximum allowable distance squared to the nearest edge.
  /// The [handle] is the filter acceptable edges with, or null to not filter.
  NearestEdgeArgs(this._queryPoint, this._cutoffDist2, this._handle) {
    _resultEdge = null;
    _resultPoint = null;
  }

  /// Runs this node and all children nodes through this search.
  void run(INode rootNode) {
    NodeStack stack = new NodeStack();
    stack.push(rootNode);
    while (!stack.isEmpty) {
      INode node = stack.pop;
      if (node is PointNode) {
        for (EdgeNode edge in node.startEdges) {
          _checkEdge(edge);
        }
        for (EdgeNode edge in node.endEdges) {
          _checkEdge(edge);
        }
        for (EdgeNode edge in node.passEdges) {
          _checkEdge(edge);
        }
      } else if (node is PassNode) {
        for (EdgeNode edge in node.passEdges) {
          _checkEdge(edge);
        }
      } else if (node is BranchNode) {
        int width = node.width;
        int x = node.xmin + width ~/ 2;
        int y = node.ymin + width ~/ 2;
        double diagDist2 = 2.0 * width * width;
        double dist2 = Point.distance2(_queryPoint, new Point(x, y)) - diagDist2;
        if (dist2 <= _cutoffDist2) {
          stack.pushChildren(node);
        }
      }
      // else, empty nodes have no edges.
    }
  }

  /// Gets the result from this search.
  EdgeNode result() {
    if (_resultPoint == null) return _resultEdge;
    return _resultPoint.nearEndEdge(_queryPoint);
  }

  /// Checks if the given edge is closer that last found edge.
  void _checkEdge(EdgeNode edge) {
    if (edge == null) return;
    if (edge == _resultEdge) return;
    if (_handle != null) {
      if (!_handle.handle(edge)) return;
    }

    // Determine how the point is relative to the edge.
    PointOnEdgeResult result = Edge.pointOnEdge(edge, _queryPoint);
    switch (result.location) {
      case IntersectionLocation.InMiddle:
        _updateWithEdge(edge, result.closestOnEdge);
        break;
      case IntersectionLocation.BeforeStart:
        _updateWithPoint(edge.startNode);
        break;
      case IntersectionLocation.AtStart:
        _updateWithPoint(edge.startNode);
        break;
      case IntersectionLocation.PastEnd:
        _updateWithPoint(edge.endNode);
        break;
      case IntersectionLocation.AtEnd:
        _updateWithPoint(edge.endNode);
        break;
      case IntersectionLocation.None:
        break;
    }
  }

  /// Update with the edge with the middle of the edge the closest.
  void _updateWithEdge(EdgeNode edge, IPoint closePoint) {
    double dist2 = Point.distance2(_queryPoint, closePoint);
    if (dist2 <= _cutoffDist2) {
      _resultEdge = edge;
      _resultPoint = null;
      _cutoffDist2 = dist2;
    }
  }

  /// Update with the point at the end of the edge.
  void _updateWithPoint(PointNode point) {
    double dist2 = Point.distance2(_queryPoint, point);
    if (dist2 <= _cutoffDist2) {
      // Do not set _resultEdge here, leave it as the previous value.
      _resultPoint = point;
      _cutoffDist2 = dist2;
    }
  }
}
