part of PolygonalMapDart.Quadtree;

/// A vector of point nodes which can represent
/// a polygon, poly-line, or point stack.
class PointNodeVector {
  /// The list of nodes in this vector.
  List<PointNode> _list;

  /// Creates a new point node vector.
  /// The [count] is the initial capacity of the vector.
  PointNodeVector() {
    _list = new List<PointNode>();
  }

  /// Gets the internal list of nodes.
  List<PointNode> get nodes => _list;

  /// Gets the edge between the point at the given index and the next index.
  Edge edge(int index) {
    PointNode startNode = _list[index];
    PointNode endNode = _list[(index + 1) % _list.length];
    return new Edge(startNode, endNode);
  }

  /// Reverses the location of all the points in the vector.
  void reverse() {
    for (int i = 0, j = _list.length - 1; i < j; ++i, --j) {
      PointNode temp = _list[i];
      _list[i] = _list[j];
      _list[j] = temp;
    }
  }

  /// Calculates the area of the polygon in the vector.
  AreaAccumulator get area {
    AreaAccumulator area = new AreaAccumulator();
    PointNode endNode = _list[0];
    for (int i = _list.length - 1; i >= 0; --i) {
      PointNode startNode = _list[i];
      area.handle(new Edge(startNode, endNode));
      endNode = startNode;
    }
    return area;
  }

  /// Calculates the boundary of all the points in the vertex.
  Boundary get bounds {
    Boundary bounds = null;
    for (int i = _list.length - 1; i >= 0; --i) {
      bounds = Boundary.expand(bounds, _list[i]);
    }
    return bounds;
  }

  /// Converts the vertex into a set.
  Set<PointNode> toSet() {
    Set<PointNode> newSet = new Set<PointNode>();
    for (int i = _list.length - 1; i >= 0; --i) {
      newSet.add(_list[i]);
    }
    return newSet;
  }
}
