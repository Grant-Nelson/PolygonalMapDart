part of PolygonalMapDart.Quadtree;

/// The child quadrant.
class Quadrant {
  /// Indicates the minimum X and maximum Y child.
  static const int NorthWest = 0;

  /// Indicates the maximum X and minimum Y child.
  static const int SouthWest = 1;

  /// Indicates the minimum X and maximum Y child.
  static const int NorthEast = 2;

  /// Indicates the maximum X and minimum Y child.
  static const int SouthEast = 3;

  /// Gets a list of all quadrants.
  static List<int> get All => [NorthWest, SouthEast, NorthEast, SouthWest];

  // Keep this class from being constructed.
  Quadrant._();
}
