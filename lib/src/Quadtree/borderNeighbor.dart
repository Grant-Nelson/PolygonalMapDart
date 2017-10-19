part of PolygonalMapDart.Quadtree;

/// An edge handler for determining a border neighbor.
/// The border neighbor is the most clockwise (or counter-clockwise) line sharing a point
/// with an edge. This will flow a border if the shapes is wound properly.
class BorderNeighbor implements IEdgeHandler {
  /// The query edge to get the neighbor of.
  final IEdge _query;

  /// True to use a counter-clockwise border, false if clockwise.
  final bool _ccw;

  /// The matcher to filter possible neighbors.
  final IEdgeHandler _matcher;

  /// The current result neighbor edge.
  IEdge _result;

  /// Indicates that forward edges are still allowed.
  bool _allowFore;

  /// Indicates that backward edges are still allowed.
  bool _allowBack;

  /// Indicates that left or right edges are still allowed.
  bool _allowTurn;

  /// Indicates that a left edge has been found.
  bool _hasLeft;

  /// Indicates that a right edge has been found.
  bool _hasRight;

  /// Creates a new border neighbor finder.
  /// The given [origin] point is the origin for neighbors.
  /// The given [query] point is usually the other point on the border.
  /// Set [ccw] to true to use a counter-clockwise border, false if clockwise.
  /// The given [matcher] will filter possible neighbors.
  BorderNeighbor.Points(
      IPoint origin, IPoint query, bool ccw, IEdgeHandler matcher)
      : this(new Edge(origin, query), ccw, matcher);

  /// Creates a new border neighbor finder.
  /// The given [query] point is usually the other point on the border.
  /// Set [ccw] to true to use a counter-clockwise border, false if clockwise.
  /// The given [matcher] will filter possible neighbors.
  BorderNeighbor(this._query, this._ccw, this._matcher) {
    _result = null;
    _allowFore = true;
    _allowBack = true;
    _allowTurn = true;
    _hasLeft = false;
    _hasRight = false;
  }

  /// The currently found edge border neighbor or nill.
  IEdge get result => _result;

  /// Updates the border neighbor with the given edge.
  /// Always returns true.
  bool handle(EdgeNode edge) {
    if (_matcher != null) {
      if (edge is EdgeNode) {
        if (!_matcher.handle(edge)) return true;
      }
    }
    if (_ccw) _ccwNeighbor(edge);
    else _cwNeighbor(edge);
    return true;
  }

  /// Updates the counter-clockwise border neighbor.
  void _ccwNeighbor(IEdge edge) {
    // Get the far point in the other edge.
    IPoint point = null;
    if (Point.equals(edge.start, _query.start)) {
      point = edge.end;
    } else if (Point.equals(edge.end, _query.start)) {
      point = edge.start;
    } else if (Point.equals(edge.start, _query.end)) {
      point = edge.end;
    } else if (Point.equals(edge.end, _query.end)) {
      point = edge.start;
    } else
      return;

    // Check if edge is opposite.
    if (Point.equals(point, _query.end)) {
      if (_allowBack) {
        _result = edge;
        _allowBack = false;
      }
      return;
    }

    // Determine the side of the query edge that the other edge is on.
    switch (Edge.side(_query, point)) {
      case Side.Inside:
        if (_allowFore || _allowBack) {
          // Bias toward edges heading the same way.
          if (Edge.acute(_query, edge)) {
            if (_allowFore) {
              _result = edge;
              _allowFore = false;
              _allowBack = false;
              _allowTurn = false;
            }
          } else if (_allowBack) {
            _result = edge;
            _allowBack = false;
          }
        }
        break;

      case Side.Left:
        if (_allowTurn) {
          if (!_hasLeft) {
            _result = edge;
            _hasLeft = true;
            _allowBack = false;
          } else if (Edge.side(_result, point) == Side.Right) {
            _result = edge;
          }
        }
        break;

      case Side.Right:
        if (!_hasRight) {
          _result = edge;
          _hasRight = true;
          _allowFore = false;
          _allowBack = false;
          _allowTurn = false;
        } else if (Edge.side(_result, point) == Side.Right) {
          _result = edge;
        }
        break;
    }
  }

  /// Updates the clockwise border neighbor.
  void _cwNeighbor(IEdge edge) {
    // Get the far point in the other edge.
    IPoint point = null;
    if (Point.equals(edge.start, _query.start)) {
      point = edge.end;
    } else if (Point.equals(edge.end, _query.start)) {
      point = edge.start;
    } else if (Point.equals(edge.start, _query.end)) {
      point = edge.end;
    } else if (Point.equals(edge.end, _query.end)) {
      point = edge.start;
    } else
      return;

    // Check if edge is opposite.
    if (Point.equals(point, _query.end)) {
      if (_allowBack) {
        _result = edge;
        _allowBack = false;
      }
      return;
    }

    // Determine the side of the query edge that the other edge is on.
    switch (Edge.side(_query, point)) {
      case Side.Inside:
        if (_allowFore || _allowBack) {
          // Bias toward edges heading the same way.
          if (Edge.acute(_query, edge)) {
            if (_allowFore) {
              _result = edge;
              _allowFore = false;
              _allowBack = false;
              _allowTurn = false;
            }
          } else if (_allowBack) {
            _result = edge;
            _allowBack = false;
          }
        }
        break;

      case Side.Left:
        if (!_hasLeft) {
          _result = edge;
          _hasLeft = true;
          _allowFore = false;
          _allowBack = false;
          _allowTurn = false;
        } else if (Edge.side(_result, point) == Side.Left) {
          _result = edge;
        }
        break;

      case Side.Right:
        if (_allowTurn) {
          if (!_hasRight) {
            _result = edge;
            _hasRight = true;
            _allowBack = false;
          } else if (Edge.side(_result, point) == Side.Left) {
            _result = edge;
          }
        }
        break;
    }
  }
}
