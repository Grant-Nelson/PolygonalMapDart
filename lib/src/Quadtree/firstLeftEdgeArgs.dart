part of PolygonalMapDart.Quadtree;

/// The first left edge arguments to handle multiple returns objects for
/// determining the first left edge to a point.
class FirstLeftEdgeArgs {
  /// The query point to find the first edge left of.
  final IPoint _queryPoint;

  /// The edge matcher to filter edges with.
  final IEdgeHandler _handle;

  /// The current right most value.
  double _rightValue;

  /// The currently found closest edge.
  /// Null if a point has been found closer.
  EdgeNode _resultEdge;

  /// The node if the nearest part of the edge is the point.
  /// Null if an edge has been found closer.
  PointNode _resultPoint;

  /// Creates a new first left edge argument for finding the first edge that is
  /// left of the given query point.
  /// [queryPoint] is the point to find the first edge left of.
  FirstLeftEdgeArgs(IPoint queryPoint, IEdgeHandler handle) {
    this._queryPoint = queryPoint;
    this._handle = handle;
    this._rightValue = -Double.MAX_VALUE;
    this._resultEdge = null;
    this._resultPoint = null;
  }

  /// Gets the query point, the point to find the first edge left of.
  IPoint get queryPoint => this._queryPoint;

  /// Gets the x value of the location the left horizontal edge crosses the
  /// current result. This will be the right most value found.
  double get rightValue => this._rightValue;

  /// Indicates that a result has been found. This doesn't mean the correct
  /// solution has been found. Only that a value has been found.
  bool get found => (this._resultEdge != null) || (this._resultPoint != null);

  /// Gets the resulting first edge left of the query point.
  /// Returns the first left edge in the tree which was found.
  /// If no edges were found null is returned.
  EdgeNode get result {
    if (this._resultPoint == null)
      return this._resultEdge;
    else
      return this._resultPoint.nearEndEdge(this._queryPoint);
  }

  /// This updates with the given edges.
  void update(EdgeNode edge) {
    if (edge == null) return;
    if (edge == this._resultEdge) return;
    if (this._handle != null) {
      if (!this._handle.handle(edge)) return;
    }

    // Determine how the edge crosses the horizontal edge from the point and left.
    if (edge.y1 == this._queryPoint.y) {
      if (edge.y2 == this._queryPoint.y) {
        if (edge.x1 > this._queryPoint.x) {
          if (edge.x2 > this._queryPoint.x) {
            // The edge to the right of the point, do nothing.
          } else {
            // The edge is collinear with and contains the query point.
            this.updateWithEdge(edge, this._queryPoint.x);
          }
        } else if (edge.x2 > this._queryPoint.x) {
          // The edge is collinear with and contains the query point.
          this.updateWithEdge(edge, this._queryPoint.x);
        } else if (edge.x1 > edge.x2) {
          // The edge is collinear with the point and the start is more right.
          this.updateWithPoint(edge.startNode);
        } else {
          // The edge is collinear with the point and the start is more left.
          this.updateWithPoint(edge.endNode);
        }
      } else if (edge.x1 < this._queryPoint.x) {
        // The start point is on the horizontal and to the left.
        this.updateWithPoint(edge.startNode);
      } else {
        // The start point is on the horizontal but on or to the right, do nothing.
      }
    } else if (edge.y1 > this._queryPoint.y) {
      if (edge.y2 == this._queryPoint.y) {
        if (edge.x2 <= this._queryPoint.x) {
          // The end point is on the horizontal and on or to the left.
          updateWithPoint(edge.endNode);
        } else {
          // The end point is on the horizontal but to the right, do nothing.
        }
      } else if (edge.y2 > this._queryPoint.y) {
        // The edge is above the horizontal, do nothing.
      } else {
        // (edge.y2 < this._queryPoint.y)
        if ((edge.x1 > this._queryPoint.x) && (edge.x2 > this._queryPoint.x)) {
          // The edge is to the right of the point, do nothing.
        } else {
          double x = (edge.x1 - edge.x2) * (this._queryPoint.y - edge.y2) / (edge.y1 - edge.y2) + edge.x2;
          if (x > this._queryPoint.x) {
            // The horizontal crossing is to the right of the point, do nothing.
          } else {
            // The edge crosses to the left of the point.
            this.updateWithEdge(edge, x);
          }
        }
      }
    } else {
      // (edge.y1 < this._queryPoint.y)
      if (edge.y2 == this._queryPoint.y) {
        if (edge.x2 <= this._queryPoint.x) {
          // The end point is on the horizontal and on or to the left.
          this.updateWithPoint(edge.endNode);
        } else {
          // The end point is on the horizontal but to the right, do nothing.
        }
      } else if (edge.y2 < this._queryPoint.y) {
        // The edge is below the horizontal, do nothing.
      } else {
        // (edge.y2 > this._queryPoint.y)
        if ((edge.x1 > this._queryPoint.x) && (edge.x2 > this._queryPoint.x)) {
          // The edge is to the right of the point, do nothing.
        } else {
          double x = (edge.x1 - edge.x2) * (this._queryPoint.y - edge.y2) / (edge.y1 - edge.y2) + edge.x2;
          if (x > this._queryPoint.x) {
            // The horizontal crossing is to the right of the point, do nothing.
          } else {
            // The edge crosses to the left of the point.
            this.updateWithEdge(edge, x);
          }
        }
      }
    }
  }

  /// The edge to update with has the point on the horizontal edge inside it.
  void _updateWithEdge(EdgeNode edge, double loc) {
    if (loc > this._rightValue) {
      this._resultEdge = edge;
      this._resultPoint = null;
      this._rightValue = loc;
    }
  }

  /// The edge to update with has the point on the horizontal edge at one of the end points.
  /// This is called to update with that point instead of point inside the edge.
  void _updateWithPoint(PointNode point) {
    if (point.x > this._rightValue) {
      // Do not set _resultEdge here, leave it as the previous value.
      this._resultPoint = point;
      this._rightValue = point.x;
    }
  }
}
