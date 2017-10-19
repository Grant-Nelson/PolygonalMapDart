part of PolygonalMapDart.Quadtree;

  /// Formats the edges into a string.
  /// [contained] indicates this output is part of another part.
  /// [last] indicate this is the last set in a list of parents.
  void _edgeNodesToBuffer(Set<EdgeNode> nodes, StringBuffer sout,
      {String indent: "",
      bool contained: false,
      bool last: true,
      IFormatter format: null}) {
    int count = nodes.length;
    int index = 0;
    for (EdgeNode edge in nodes) {
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
