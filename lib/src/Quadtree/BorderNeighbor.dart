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

  /// The current result edge or opposite to point away from query edge.
  IEdge _adjusted;

  /// Indicates that forward edges are still allowed,
  /// edges which head in the same direction as the query edge.
  bool _allowFore;

  /// Indicates that backward edges are still allowed,
  /// edges which head back towards the query point.
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
  BorderNeighbor.Points(IPoint origin, IPoint query, [bool ccw = true, IEdgeHandler matcher = null]):
    this(new Edge(origin, query), ccw, matcher);

  /// Creates a new border neighbor finder.
  /// The given [query] point is usually the other point on the border.
  /// Set [ccw] to true to use a counter-clockwise border, false if clockwise.
  /// The given [matcher] will filter possible neighbors.
  BorderNeighbor(this._query, [this._ccw = true, this._matcher = null]) {
    this._result    = null;
    this._adjusted  = null;
    this._allowFore = true;
    this._allowBack = true;
    this._allowTurn = true;
    this._hasLeft   = false;
    this._hasRight  = false;
  }

  /// The currently found edge border neighbor or null.
  IEdge get result => this._result;

  /// Updates the border neighbor with the given edge.
  /// Always returns true.
  bool handle(IEdge edge) {
    if (this._matcher != null) {
      if (edge is EdgeNode) {
        if (!this._matcher.handle(edge)) return true;
      }
    }

    IEdge adjusted = this._adjustedNeighbor(edge);
    if (adjusted == null) return true;

    if (this._ccw) this._ccwNeighbor(edge, adjusted);
    else this._cwNeighbor(edge, adjusted);
    return true;
  }

  /// Gets the neighbor edge edge or opposite to point away from query edge.
  IEdge _adjustedNeighbor(IEdge edge) {
    if (Point.equals(edge.start, this._query.start) ||
        Point.equals(edge.start, this._query.end))
      return edge;
    
    if (Point.equals(edge.end, this._query.start) ||
        Point.equals(edge.end, this._query.end))
      return new Edge(edge.end, edge.start);
    
    return null;
  }

  /// Updates the counter-clockwise border neighbor.
  void _ccwNeighbor(IEdge edge, IEdge adjusted) {
    // Get the far point in the other edge.
    IPoint point = adjusted.end;

    // Check if edge is opposite.
    if (Point.equals(point, this._query.end)) {
      if (this._allowBack) {
        this._result    = edge;
        this._adjusted  = adjusted;
        this._allowBack = false;
      }
      return;
    }

    // Determine the side of the query edge that the other edge is on.
    switch (Edge.side(this._query, point)) {
      case Side.Inside:
        if (this._allowFore || this._allowBack) {
          // Bias toward edges heading the same way.
          if (Edge.acute(this._query, edge)) {
            if (this._allowFore) {
              this._result    = edge;
              this._adjusted  = adjusted;
              this._allowFore = false;
              this._allowBack = false;
              this._allowTurn = false;
            }
          } else if (this._allowBack) {
            this._result    = edge;
            this._adjusted  = adjusted;
            this._allowBack = false;
          }
        }
        break;

      case Side.Left:
        if (this._allowTurn) {
          if (!this._hasLeft) {
            this._result    = edge;
            this._adjusted  = adjusted;
            this._hasLeft   = true;
            this._allowBack = false;
          } else if (Edge.side(this._adjusted, point) == Side.Right) {
            this._result   = edge;
            this._adjusted = adjusted;
          }
        }
        break;

      case Side.Right:
        if (!this._hasRight) {
          this._result    = edge;
          this._adjusted  = adjusted;
          this._hasRight  = true;
          this._allowFore = false;
          this._allowBack = false;
          this._allowTurn = false;
        } else if (Edge.side(this._adjusted, point) == Side.Right) {
          this._result   = edge;
          this._adjusted = adjusted;
        }
        break;
    }
  }

  /// Updates the clockwise border neighbor.
  void _cwNeighbor(IEdge edge, IEdge adjusted) {
    // Get the far point in the other edge.
    IPoint point = adjusted.end;

    // Check if edge is opposite.
    if (Point.equals(point, this._query.end)) {
      if (this._allowBack) {
        this._result    = edge;
        this._adjusted  = adjusted;
        this._allowBack = false;
      }
      return;
    }

    // Determine the side of the query edge that the other edge is on.
    switch (Edge.side(this._query, point)) {
      case Side.Inside:
        if (this._allowFore || this._allowBack) {
          // Bias toward edges heading the same way.
          if (Edge.acute(this._query, edge)) {
            if (this._allowFore) {
              this._result    = edge;
              this._adjusted  = adjusted;
              this._allowFore = false;
              this._allowBack = false;
              this._allowTurn = false;
            }
          } else if (this._allowBack) {
            this._result    = edge;
            this._adjusted  = adjusted;
            this._allowBack = false;
          }
        }
        break;

      case Side.Left:
        if (!this._hasLeft) {
          this._result    = edge;
          this._adjusted  = adjusted;
          this._hasLeft   = true;
          this._allowFore = false;
          this._allowBack = false;
          this._allowTurn = false;
        } else if (Edge.side(this._adjusted, point) == Side.Left) {
          this._result   = edge;
          this._adjusted = adjusted;
        }
        break;

      case Side.Right:
        if (this._allowTurn) {
          if (!this._hasRight) {
            this._result    = edge;
            this._adjusted  = adjusted;
            this._hasRight  = true;
            this._allowBack = false;
          } else if (Edge.side(this._adjusted, point) == Side.Left) {
            this._result   = edge;
            this._adjusted = adjusted;
          }
        }
        break;
    }
  }
}
