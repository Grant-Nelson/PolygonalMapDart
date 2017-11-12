part of PolygonalMapDart.Quadtree;

/// The boundary regions are a set of values that can be used to
class BoundaryRegion {
  /// Indicates that the point is inside of the boundary.
  static final BoundaryRegion Inside = new BoundaryRegion._(0x00);

  /// Indicates that the point is south (-Y) of the boundary.
  static final BoundaryRegion South = new BoundaryRegion._(0x01);

  /// Indicates that the point is south (+Y) of the boundary.
  static final BoundaryRegion North = new BoundaryRegion._(0x02);

  /// Indicates that the point is either north, south, or inside the boundary.
  /// This is a combination of North and South.
  static final BoundaryRegion Vertical = new BoundaryRegion._(0x03);

  /// Indicates that the point is west (-X) of the boundary.
  static final BoundaryRegion West = new BoundaryRegion._(0x04);

  /// Indicates that the point is south west of the boundary.
  /// This is a combination of South and West.
  static final BoundaryRegion SouthWest = new BoundaryRegion._(0x05);

  /// Indicates that the point is south west of the boundary.
  /// This is a combination of North and West.
  static final BoundaryRegion NorthWest = new BoundaryRegion._(0x06);

  /// Indicates that the point is east (+X) of the boundary.
  static final BoundaryRegion East = new BoundaryRegion._(0x08);

  /// Indicates that the point is south west of the boundary.
  /// This is a combination of South and East.
  static final BoundaryRegion SouthEast = new BoundaryRegion._(0x09);

  /// Indicates that the point is south west of the boundary.
  /// This is a combination of North and East.
  static final BoundaryRegion NorthEast = new BoundaryRegion._(0x0A);

  /// Indicates that the point is either east, west, or inside the boundary.
  /// This is a combination of East and West.
  static final BoundaryRegion Horizontal = new BoundaryRegion._(0x0C);

  /// The value of the boundary region.
  int _value;

  /// Creates a new boundary region.
  BoundaryRegion._(this._value);

  /// Determines if the given [other] BoundaryRegion is partially contained in this BoundaryRegion.
  /// Typically used with North, South, East, and West. Will always return true for Inside.
  bool has(BoundaryRegion other) => (_value & other._value) == other._value;

  /// Checks if this BoundaryRegion is equal to the given [other] BoundaryRegion.
  bool operator ==(BoundaryRegion other) => _value == other._value;

  /// Gets the OR of the two boundary regions.
  BoundaryRegion operator |(BoundaryRegion other) => new BoundaryRegion._(_value | other._value);

  /// Gets the AND of the two boundary regions.
  BoundaryRegion operator &(BoundaryRegion other) => new BoundaryRegion._(_value & other._value);

  /// Gets the string for the given boundary region.
  String toString() {
    switch (_value) {
      case 0x00:
        return "Inside";
      case 0x01:
        return "South";
      case 0x02:
        return "North";
      case 0x03:
        return "Vertical";
      case 0x04:
        return "West";
      case 0x05:
        return "SouthWest";
      case 0x06:
        return "NorthWest";
      case 0x08:
        return "East";
      case 0x09:
        return "SouthEast";
      case 0x0A:
        return "NorthEast";
      case 0x0C:
        return "Horizontal";
      default:
        return "Unknown($_value)";
    }
  }
}
