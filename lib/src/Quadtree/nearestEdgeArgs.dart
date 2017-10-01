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
  NearestEdgeArgs(IPoint this._queryPoint, double this._cutoffDist2,
      IEdgeHandler this._handle) {
    this._resultEdge = null;
    this._resultPoint = null;
  }

  /// Runs this node and all children nodes through this search.
  void run(INode rootNode) {
    NodeStack stack = new NodeStack();
    stack.push(rootNode);
    while (!stack.isEmpty) {
      INode node = stack.pop;
      if (node is PointNode) {
        for (EdgeNode edge in node.startEdges.nodes) {
          this._checkEdge(edge);
        }
        for (EdgeNode edge in node.endEdges.nodes) {
          this._checkEdge(edge);
        }
        for (EdgeNode edge in node.passEdges.nodes) {
          this._checkEdge(edge);
        }
      } else if (node is PassNode) {
        for (EdgeNode edge in node.passEdges.nodes) {
          this._checkEdge(edge);
        }
      } else if (node is BranchNode) {
        int width = node.width;
        int x = node.xmin + width ~/ 2;
        int y = node.ymin + width ~/ 2;
        double diagDist2 = 2.0 * width * width;
        double dist2 =
            Point.distance2(this._queryPoint.x, this._queryPoint.y, x, y) -
                diagDist2;
        if (dist2 <= this._cutoffDist2) {
          stack.pushChildren(node);
        }
      }
      // else, empty nodes have no edges.
    }
  }

  /// Gets the result from this search.
  EdgeNode result() {
    if (this._resultPoint == null)
      return this._resultEdge;
    else
      return this._resultPoint.nearEndEdge(this._queryPoint);
  }

  /// Checks if the given edge is closer that last found edge.
  void _checkEdge(EdgeNode edge) {
    if (edge == null) return;
    if (edge == this._resultEdge) return;
    if (this._handle != null) {
      if (!this._handle.handle(edge)) return;
    }

    // Determine how the point is relative to the edge.
    PointOnEdgeResult result = Edge.pointOnEdge(edge, this._queryPoint);
    switch (result.location) {
      case IntersectionLocation.InMiddle:
        this._updateWithEdge(edge, result.closestOnEdge);
        break;
      case IntersectionLocation.BeforeStart:
        this._updateWithPoint(edge.startNode);
        break;
      case IntersectionLocation.AtStart:
        this._updateWithPoint(edge.startNode);
        break;
      case IntersectionLocation.PastEnd:
        this._updateWithPoint(edge.endNode);
        break;
      case IntersectionLocation.AtEnd:
        this._updateWithPoint(edge.endNode);
        break;
      case IntersectionLocation.None:
        break;
    }
  }

  /// Update with the edge with the middle of the edge the closest.
  void _updateWithEdge(EdgeNode edge, IPoint closePoint) {
    double dist2 = Point.distance2Points(this._queryPoint, closePoint);
    if (dist2 <= this._cutoffDist2) {
      this._resultEdge = edge;
      this._resultPoint = null;
      this._cutoffDist2 = dist2;
    }
  }

  /// Update with the point at the end of the edge.
  void _updateWithPoint(PointNode point) {
    double dist2 = Point.distance2Points(_queryPoint, point);
    if (dist2 <= this._cutoffDist2) {
      // Do not set _resultEdge here, leave it as the previous value.
      this._resultPoint = point;
      this._cutoffDist2 = dist2;
    }
  }
}
