part of PolygonalMapDart.Quadtree;

/// The set of string parts used when formatting.
class StringParts {
  /// The separator between lines of the tree output.
  static final String Sep = "\n";

  /// The indent part of the last child.
  static final String Last = "'-";

  /// The indent part of a child which is not the last child.
  static final String Child = "|-";

  /// The space indent for a line in the tree output.
  static final String Space = "  ";

  /// The continuing indent for a line in the tree output.
  static final String Bar = "| ";

  /// Keep this class from being constructed.
  StringParts._();
}
