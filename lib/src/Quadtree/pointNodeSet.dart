part of PolygonalMapDart.Quadtree;

/// A set of point nodes.
class PointNodeSet extends Set<PointNode> {
  /// Create a set of point nodes.
  PointNodeSet();

  /// Formats the points into a string.
  /// [children] indicates any child should also be concatenated.
  /// [contained] indicates this node is part of another part.
  void toBuffer(StringBuffer sout,
      {String indent: "", bool children: true, bool contained: false, IFormatter format: null}) {
    int count = this.size();
    int index = 0;
    for (PointNode point in this) {
      if (index > 0) {
        sout.append(StringParts.Sep);
        sout.append(indent);
      }
      index++;
      point.toString(sout, indent, children, contained, index >= count, format);
    }
  }
}
