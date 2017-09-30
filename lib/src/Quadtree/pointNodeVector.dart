part of PolygonalMapDart.Quadtree;

/// A vector of point nodes which can represent
/// a polygon, poly-line, or point stack.
class PointNodeVector {

  /// The list of nodes in this vector.
  List<PointNode> _list;

  /// Creates a new point node vector.
  /// The [count] is the initial capacity of the vector.
  PointNodeVector([int count = 0]) {
    this._list = new List<PointNode>(count);
  }

  /// Gets the internal list of nodes.
  List<PointNode> get nodes => this._list;

  /// Gets the edge between the point at the given index and the next index.
  Edge edge(int index) {
    PointNode startNode = this._list[index];
    PointNode endNode = this._list[(index + 1) % this._list.length];
    return new Edge.FromPoints(startNode, endNode);
  }

  /// Reverses the location of all the points in the vector.
  void reverse() {
    final int count = this._list.length;
    for (int i = 0, j = count - 1; i < j; ++i, --j) {
      PointNode temp = this._list[i];
      this._list[i] = this._list[j];
      this._list[j] = temp;
    }
  }

  /// Calculates the area of the polygon in the vector.
  AreaAccumulator get area {
    AreaAccumulator area = new AreaAccumulator();
    PointNode endNode = this._list[0];
    for (int i = this._list.length - 1; i >= 0; --i) {
      PointNode startNode = this._list[i];
      area.addPoints(startNode, endNode);
      endNode = startNode;
    }
    return area;
  }

  /// Calculates the boundary of all the points in the vertex.
  Boundary get bounds {
    Boundary bounds = null;
    for (int i = this._list.length - 1; i >= 0; --i) {
      bounds = Boundary.expandWithPoint(bounds, this._list[i]);
    }
    return bounds;
  }

  /// Converts the vertex into a set.
  PointNodeSet toSet() {
    PointNodeSet newSet = new PointNodeSet();
    for (int i = this._list.length - 1; i >= 0; --i) {
      newSet.nodes.add(this._list[i]);
    }
    return newSet;
  }
}
