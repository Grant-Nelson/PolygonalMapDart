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
  BorderNeighbor(IPoint origin, IPoint query, bool ccw, IEdgeHandler matcher) {
    this(new Edge(origin, query), ccw, matcher);
  }

  /// Creates a new border neighbor finder.
  /// The given [query] point is usually the other point on the border.
  /// Set [ccw] to true to use a counter-clockwise border, false if clockwise.
  /// The given [matcher] will filter possible neighbors.
  BorderNeighbor(IEdge query, bool ccw, IEdgeHandler matcher) {
    this._query = query;
    this._ccw = ccw;
    this._matcher = matcher;
    this._result = null;
    this._allowFore = true;
    this._allowBack = true;
    this._allowTurn = true;
    this._hasLeft = false;
    this._hasRight = false;
  }

  /// The currently found edge border neighbor or nill.
  IEdge get result => this._result;

  /// Updates the border neighbor with the given edge.
  /// Always returns true.
  @Override
  bool handle(EdgeNode edge) {
    this.update(edge);
    return true;
  }

  /// Updates the border neighbor with the given edge.
  void update(IEdge edge) {
    if (this._matcher != null) {
      if (edge is EdgeNode) {
        if (!this._matcher.handle(edge)) return;
      }
    }
    if (this._ccw)
      this.ccwNeighbor(edge);
    else
      this.cwNeighbor(edge);
  }

  /// Updates the counter-clockwise border neighbor.
  void _ccwNeighbor(IEdge edge) {
    // Get the far point in the other edge.
    IPoint point = null;
    if (edge.start().equals(this._query.start())) {
      point = edge.end();
    } else if (edge.end().equals(this._query.start())) {
      point = edge.start();
    } else if (edge.start().equals(this._query.end())) {
      point = edge.end();
    } else if (edge.end().equals(this._query.end())) {
      point = edge.start();
    } else
      return;

    // Check if edge is opposite.
    if (point.equals(this._query.end())) {
      if (this._allowBack) {
        this._result = edge;
        this._allowBack = false;
      }
      return;
    }

    // Determine the side of the query edge that the other edge is on.
    switch (Edge.side(this._query, point)) {
      case Inside:
        if (this._allowFore || this._allowBack) {
          // Bias toward edges heading the same way.
          if (Edge.acute(this._query, edge)) {
            if (this._allowFore) {
              this._result = edge;
              this._allowFore = false;
              this._allowBack = false;
              this._allowTurn = false;
            }
          } else if (this._allowBack) {
            this._result = edge;
            this._allowBack = false;
          }
        }
        break;

      case Left:
        if (this._allowTurn) {
          if (!this._hasLeft) {
            this._result = edge;
            this._hasLeft = true;
            this._allowBack = false;
          } else if (Edge.side(this._result, point) == Side.Right) {
            this._result = edge;
          }
        }
        break;

      case Right:
        if (!this._hasRight) {
          this._result = edge;
          this._hasRight = true;
          this._allowFore = false;
          this._allowBack = false;
          this._allowTurn = false;
        } else if (Edge.side(this._result, point) == Side.Right) {
          this._result = edge;
        }
        break;
    }
  }

  /// Updates the clockwise border neighbor.
  void _cwNeighbor(IEdge edge) {
    // Get the far point in the other edge.
    IPoint point = null;
    if (edge.start().equals(this._query.start())) {
      point = edge.end();
    } else if (edge.end().equals(this._query.start())) {
      point = edge.start();
    } else if (edge.start().equals(this._query.end())) {
      point = edge.end();
    } else if (edge.end().equals(this._query.end())) {
      point = edge.start();
    } else
      return;

    // Check if edge is opposite.
    if (point.equals(this._query.end())) {
      if (this._allowBack) {
        this._result = edge;
        this._allowBack = false;
      }
      return;
    }

    // Determine the side of the query edge that the other edge is on.
    switch (Edge.side(this._query, point)) {
      case Inside:
        if (this._allowFore || this._allowBack) {
          // Bias toward edges heading the same way.
          if (Edge.acute(this._query, edge)) {
            if (this._allowFore) {
              this._result = edge;
              this._allowFore = false;
              this._allowBack = false;
              this._allowTurn = false;
            }
          } else if (this._allowBack) {
            this._result = edge;
            this._allowBack = false;
          }
        }
        break;

      case Left:
        if (!this._hasLeft) {
          this._result = edge;
          this._hasLeft = true;
          this._allowFore = false;
          this._allowBack = false;
          this._allowTurn = false;
        } else if (Edge.side(this._result, point) == Side.Left) {
          this._result = edge;
        }
        break;

      case Right:
        if (this._allowTurn) {
          if (!this._hasRight) {
            this._result = edge;
            this._hasRight = true;
            this._allowBack = false;
          } else if (Edge.side(this._result, point) == Side.Left) {
            this._result = edge;
          }
        }
        break;
    }
  }
}
