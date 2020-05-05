part of PolygonalMapDart.Quadtree;

/// The child quadrant.
class Quadrant {
  /// Indicates the minimum X and maximum Y child.
  static final Quadrant NorthWest = new Quadrant._(0, "NorthWest");

  /// Indicates the maximum X and minimum Y child.
  static final Quadrant SouthWest = new Quadrant._(1, "SouthWest");

  /// Indicates the minimum X and maximum Y child.
  static final Quadrant NorthEast = new Quadrant._(2, "NorthEast");

  /// Indicates the maximum X and minimum Y child.
  static final Quadrant SouthEast = new Quadrant._(3, "SouthEast");

  /// Gets a list of all quadrants.
  static List<Quadrant> get All => [NorthWest, SouthEast, NorthEast, SouthWest];

  /// The value of the quadrant.
  final int _value;

  /// The name of the quadrant.
  final String _name;

  /// Creates a new quadrant.
  Quadrant._(this._value, this._name);

  /// Checks if this Quadrant is equal to the given [other] Quadrant.
  bool operator ==(dynamic other) {
    if (other is! Quadrant) return false;
    return _value == other._value;
  }

  /// Gets the name of the quadrant.
  String toString() => _name;
}
