part of PolygonalMapDart.Quadtree;

/// A set of edge nodes.
@SuppressWarnings("serial")
class EdgeNodeSet extends Set<EdgeNode> {
  /// Create a set of edge nodes.
  EdgeNodeSet();

  /// Formats the edges into a string.
  /// [contained] indicates this output is part of another part.
  /// [last] indicate this is the last set in a list of parents.
  void toString(StringBuffer sout,
      {String indent: "", bool contained: false, bool last: true, IFormatter format: null}) {
    int count = this.size();
    int index = 0;
    for (EdgeNode edge in this) {
      if (index > 0) {
        sout.append(StringParts.Sep);
        sout.append(indent);
      }
      index++;
      edge.toString(sout, indent, contained, last && (index >= count), format);
    }
  }
}
