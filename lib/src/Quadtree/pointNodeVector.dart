part of PolygonalMapDart.Quadtree;

/// A vector of point nodes which can represent
/// a polygon, poly-line, or point stack.
class PointNodeVector extends List<PointNode> {
  /// Creates a new point node vector.
  PointNodeVector();

  /// Creates a new point node vector.
  /// The [count] is the initial capacity of the vector.
  PointNodeVector(int count) : super(count);

  /// Gets the edge between the point at the given index and the next index.
  Edge edge(int index) {
    PointNode startNode = this.get(index);
    PointNode endNode = this.get((index + 1) % this.size());
    return new Edge(startNode, endNode);
  }

  /// Reverses the location of all the points in the vector.
  void reverse() {
    final int count = this.size();
    for (int i = 0, j = count - 1; i < j; ++i, --j) {
      PointNode temp = this.get(i);
      this.set(i, this.get(j));
      this.set(j, temp);
    }
  }

  /// Calculates the area of the polygon in the vector.
  AreaAccumulator get area {
    AreaAccumulator area = new AreaAccumulator();
    PointNode endNode = this.get(0);
    for (int i = this.size() - 1; i >= 0; --i) {
      PointNode startNode = this.get(i);
      area.add(startNode, endNode);
      endNode = startNode;
    }
    return area;
  }

  /// Calculates the boundary of all the points in the vertex.
  Boundary get bounds {
    Boundary bounds = null;
    for (int i = this.size() - 1; i >= 0; --i) {
      bounds = Boundary.expand(bounds, this.get(i));
    }
    return bounds;
  }

  /// Converts the vertex into a set.
  PointNodeSet toSet() {
    PointNodeSet newSet = new PointNodeSet();
    for (int i = this.size() - 1; i >= 0; --i) {
      newSet.add(this.get(i));
    }
    return newSet;
  }
}
