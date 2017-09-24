part of PolygonalMap.Quadtree;

/// The edge node is a connection in the quad-tree between two point nodes. It
/// represents a two dimensional directed line segment.
class EdgeNode implements IEdge, Comparable<EdgeNode> {
  /// The start point node for the edge.
  final PointNode _start;

  /// The end point node for the edge.
  final PointNode _end;

  /// Any additional data that this edge should contain.
  Object _data;

  /// Creates a new edge node.
  EdgeNode._(PointNode start, PointNode end) {
    assert(start != null); // May not initialize an edge node with a null start node.
    assert(end != null); // May not initialize an edge node with a null end node.
    assert(start != end); // May not initialize an edge node with the same node for both the start and end.

    this._start = start;
    this._end = end;
    this._data = null;
  }

  /// Gets the start point node for the edge.
  PointNode get startNode => this._start;

  /// Gets the end point node for the edge.
  PointNode get endNode => this._end;

  /// Gets any additional data that this edge should contain.
  Object get data => this._data;

  /// Sets additional data that this edge should contain.
  void set data(Object data) {
    this._data = data;
  }

  /// Gets the edge for this edge node.
  Edge get edge => new Edge(this._start, this._end);

  /// Gets the point for the given node.
  /// Set [start] t0 true to return the start point, false to return the end point.
  Point point(bool start) => start ? this._start.point : this._end.point;

  /// Gets the point node for the given point.
  /// Set [start] to true to return the start node, false to return the end node.
  PointNode node(bool start) => start ? this._start : this._end;

  /// Determines if this edge is connected to the given node.
  /// [point] is the node to determine if it is either the start
  /// or end node of this edge.
  /// Returns true if the given node was either the start or end node of this edge,
  /// false if not or the node was null.
  bool connectsTo(PointNode point) => (this._start == point) || (this._end == point);

  /// Determines if this edge is connected to the given edge. To be connected
  /// either the start node or end node of this edge must be the same node as
  /// either the start node or end node of the given edge.
  /// [edge] is the edge to determine if it shares a node with this edge.
  /// Returns true if the given edge shared a node with this edge,
  /// false if not or the edge was null.
  bool connectsTo(EdgeNode edge) =>
      (edge != null) &&
      ((this._start == edge._end) ||
          (this._end == edge._start) ||
          (this._start == edge._start) ||
          (this._end == edge._end));

  /// This gets the edge set of neighbor edges to this edge.
  // Set [next] to true to return the start edges from the end node,
  /// false to return the end edges from the start node..
  /// Returns the edge set of neighbors to this edge.
  EdgeNodeSet neighborEdges(bool next) => next ? this._end.startEdges() : this._start.endEdges();

  /// This will attempt to find an edge which ends where this one starts and
  /// starts where this one ends, coincident and opposite.
  EdgeNode findOpposite() => this._end.findEdgeTo(this._start);

  /// Gets the first component of the start point of the edge.
  @Override
  int get x1 => this._start.x;

  /// Gets the second component of the start point of the edge.
  @Override
  int get y1 => this._start.y;

  /// Gets the first component of the end point of the edge.
  @Override
  int get x2 => this._end.x;

  /// Gets the second component of the end point of the edge.
  @Override
  int get y2 => this._end.y;

  /// Gets the start point for this edge.
  @Override
  IPoint get start => this._start;

  /// Gets the end point for this edge.
  @Override
  IPoint get end => this._end;

  /// Gets the change in the first component, delta X.
  @Override
  int get dx => this._end.x - this._start.x;

  /// Gets the change in the second component, delta Y.
  @Override
  int get dy => this._end.y - this._start.y;

  /// Determines the next neighbor edge on a properly wound polygon.
  IEdge nextBorder(IEdgeHandler matcher) {
    BorderNeighbor border = new BorderNeighbor(this, true, matcher);
    for (EdgeNode neighbor in this._end.startEdges()) {
      border.handle(neighbor);
    }
    return border.result();
  }

  /// Determines the previous neighbor edge on a properly wound polygon.
  IEdge previousBorder(IEdgeHandler matcher) {
    BorderNeighbor border = new BorderNeighbor(this._end, this._start, false, matcher);
    for (EdgeNode neighbor in this._start.endEdges()) {
      border.handle(neighbor);
    }
    return border.result();
  }

  /// Validates this node and all children nodes.
  bool validate(StringBuffer sout, IFormatter format) {
    bool result = true;

    if (this._start.commonAncestor(this._end) == null) {
      sout.append("Error in ");
      this.toString(sout, format);
      sout.append(": The nodes don't have a common ancestor.\n");
      result = false;
    }

    if (!this._start.startEdges().contains(this)) {
      sout.append("Error in ");
      this.toString(sout, format);
      sout.append(":  The start node, ");
      sout.append(this._start);
      sout.append(", doesn't have this edge in it's starting list.\n");
      result = false;
    }

    if (!this._end.endEdges().contains(this)) {
      sout.append("Error in ");
      this.toString(sout, format);
      sout.append(":  The end node, ");
      sout.append(this._end);
      sout.append(", doesn't have this edge in it's ending list.\n");
      result = false;
    }

    return result;
  }

  /// Compares the given line with this line.
  /// Returns 1 if this line is greater than the other line,
  /// -1 if this line is less than the other line,
  /// 0 if this line is the same as the other line.
  int compareTo(EdgeNode other) {
    int cmp = this._start.compareTo(other._start);
    if (cmp != 0) return cmp;
    return this._end.compareTo(other._end);
  }

  /// Formats the nodes into a string.
  /// [contained] indicates this node is part of another node.
  /// [last] indicates this is the last node of the parent.
  void toString(StringBuffer sout,
      {String indent: "", bool contained: false, bool last: true, IFormatter format: null}) {
    if (contained) {
      if (last)
        sout.append(StringParts.Last);
      else
        sout.append(StringParts.Child);
    }
    sout.append("EdgeNode: ");
    sout.append(this.edge().toString(format));

    if (this._data != null) {
      sout.append(" ");
      sout.append(this._data.toString());
    }
  }

  /// Gets the string for this edge node.
  @Override
  String toString() {
    StringBuffer sout = new StringBuffer();
    this.toString(sout);
    return sout.toString();
  }
}
