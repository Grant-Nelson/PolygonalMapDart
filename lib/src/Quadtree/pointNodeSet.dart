part of PolygonalMapDart.Quadtree;

/// A set of point nodes.
class PointNodeSet  {
  /// The internal set of nodes.
  Set<PointNode> _set;

  /// Create a set of point nodes.
  PointNodeSet() {
    this._set = new Set<PointNode>();
  }

  /// Gets the internal node set.
  Set<PointNode> get nodes => this._set;

  /// Formats the points into a string.
  /// [children] indicates any child should also be concatenated.
  /// [contained] indicates this node is part of another part.
  void toBuffer(StringBuffer sout,
      {String indent: "", bool children: true, bool contained: false, IFormatter format: null}) {
    int count = this._set.length;
    int index = 0;
    for (PointNode point in this._set) {
      if (index > 0) {
        sout.write(StringParts.Sep);
        sout.write(indent);
      }
      index++;
      point.toBuffer(sout, indent: indent, children:children, contained:contained, last:index >= count, format:format);
    }
  }
}
