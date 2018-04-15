part of PolygonalMapDart.Quadtree;

/// A set of edge nodes.
class IntersectionSet {
  /// The internal set of results.
  Set<IntersectionResult> _set;

  /// Create a set of edge nodes.
  IntersectionSet() {
    _set = new Set<IntersectionResult>();
  }

  /// Gets the internal set of results.
  Set<IntersectionResult> get results => _set;

  /// Contains an edge in the first, "A", intersection edge.
  bool constainsA(IEdge edge) {
    for (IntersectionResult inter in _set) {
      if (Edge.equals(inter.edgeA, edge, false)) {
        return true;
      }
    }
    return false;
  }

  /// Contains an edge in the second, "B", intersection edge.
  bool constainsB(IEdge edge) {
    for (IntersectionResult inter in _set) {
      if (Edge.equals(inter.edgeB, edge, false)) {
        return true;
      }
    }
    return false;
  }

  /// Formats the intersections into a string.
  void toBuffer(StringBuffer sout, String indent) {
    bool first = true;
    for (IntersectionResult inter in _set) {
      if (first) {
        first = false;
      } else {
        sout.write("\n" + indent);
      }
      sout.write(inter.toString("\n" + indent + "   "));
    }
  }

  /// Formats the set into a string.
  String toString() {
    StringBuffer sout = new StringBuffer();
    toBuffer(sout, "");
    return sout.toString();
  }
}
