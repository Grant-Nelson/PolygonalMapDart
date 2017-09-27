part of PolygonalMapDart.Quadtree;

/// The boundary regions are a set of values that can be used to
class BoundaryRegion {
  /// Don't allow the boundary region to be created.
  BoundaryRegion._();

  /// Indicates that the point is inside of the boundary.
  static const int Inside = 0x00;

  /// Indicates that the point is south (-Y) of the boundary.
  static const int South = 0x01;

  /// Indicates that the point is south (+Y) of the boundary.
  static const int North = 0x02;

  /// Indicates that the point is either north, south, or inside the boundary.
  /// This is a combination of North and South.
  static const int Vertical = 0x03;

  /// Indicates that the point is west (-X) of the boundary.
  static const int West = 0x04;

  /// Indicates that the point is south west of the boundary.
  /// This is a combination of South and West.
  static const int SouthWest = 0x05;

  /// Indicates that the point is south west of the boundary.
  /// This is a combination of North and West.
  static const int NorthWest = 0x06;

  /// Indicates that the point is east (+X) of the boundary.
  static const int East = 0x08;

  /// Indicates that the point is south west of the boundary.
  /// This is a combination of South and East.
  static const int SouthEast = 0x09;

  /// Indicates that the point is south west of the boundary.
  /// This is a combination of North and East.
  static const int NorthEast = 0x0A;

  /// Indicates that the point is either east, west, or inside the boundary.
  /// This is a combination of East and West.
  static const int Horizontal = 0x0C;

  /// Gets the string for the given boundary region.
  static String boundaryRegionToString(int region) {
    switch (region) {
      case BoundaryRegion.Inside:
        return "Inside";
      case BoundaryRegion.South:
        return "South";
      case BoundaryRegion.North:
        return "North";
      case BoundaryRegion.Vertical:
        return "Vertical";
      case BoundaryRegion.West:
        return "West";
      case BoundaryRegion.SouthWest:
        return "SouthWest";
      case BoundaryRegion.NorthWest:
        return "NorthWest";
      case BoundaryRegion.East:
        return "East";
      case BoundaryRegion.SouthEast:
        return "SouthEast";
      case BoundaryRegion.NorthEast:
        return "NorthEast";
      case BoundaryRegion.Horizontal:
        return "Horizontal";
      default:
        return "Unknown($region)";
    }
  }
}
