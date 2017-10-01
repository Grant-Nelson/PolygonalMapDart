part of PolygonalMapDart.Quadtree;

/// A set of edge nodes.
class EdgeNodeSet {
  // The internal set of edge nodes.
  Set<EdgeNode> _set;

  /// Create a set of edge nodes.
  EdgeNodeSet() {
    this._set = new Set<EdgeNode>();
  }

  /// Gets the set of edge nodes.
  Set<EdgeNode> get nodes => this._set;

  /// Formats the edges into a string.
  /// [contained] indicates this output is part of another part.
  /// [last] indicate this is the last set in a list of parents.
  void toBuffer(StringBuffer sout,
      {String indent: "",
      bool contained: false,
      bool last: true,
      IFormatter format: null}) {
    int count = this._set.length;
    int index = 0;
    for (EdgeNode edge in this._set) {
      if (index > 0) {
        sout.write(StringParts.Sep);
        sout.write(indent);
      }
      index++;
      edge.toBuffer(sout,
          indent: indent,
          contained: contained,
          last: last && (index >= count),
          format: format);
    }
  }
}
