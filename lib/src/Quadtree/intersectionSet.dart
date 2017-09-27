part of PolygonalMapDart.Quadtree;

/// A set of edge nodes.
class IntersectionSet extends Set<IntersectionResult> {
  /// Create a set of edge nodes.
  IntersectionSet();

  /// Contains an edge in the first, "A", intersection edge.
  bool constainsA(IEdge edge) {
    for (IntersectionResult inter in this) {
      if (inter.edgeA.equals(edge)) {
        return true;
      }
    }
    return false;
  }

  /// Contains an edge in the second, "B", intersection edge.
  bool constainsB(IEdge edge) {
    for (IntersectionResult inter in this) {
      if (inter.edgeB.equals(edge)) {
        return true;
      }
    }
    return false;
  }

  /// Formats the intersections into a string.
  void toBuffer(StringBuffer sout, String indent) {
    bool first = true;
    for (IntersectionResult inter in this) {
      if (first) {
        first = false;
      } else {
        sout.append("\n" + indent);
      }
      sout.append(inter.toString("\n" + indent + "   "));
    }
  }

  /// Formats the set into a string.
  String toString() {
    StringBuffer sout = new StringBuffer();
    this.toString(sout, "");
    return sout.toString();
  }
}
