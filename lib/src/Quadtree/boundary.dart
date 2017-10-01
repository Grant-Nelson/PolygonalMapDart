part of PolygonalMapDart.Quadtree;

/// The geometric boundary in a quad-tree.
class Boundary implements IBoundary {
  /// Returns the given boundary expanded with the new point.
  static Boundary expandWithPoint(IBoundary boundary, IPoint point) {
    return expand(boundary, point.x, point.y);
  }

  /// Returns this boundary expanded with the new point.
  static Boundary expand(IBoundary boundary, int x, int y) {
    if (boundary == null) {
      return new Boundary(x, y, x, y);
    } else {
      int xmin = boundary.xmin, xmax = boundary.xmax;
      if (x < xmin)
        xmin = x;
      else if (x > xmax) xmax = x;

      int ymin = boundary.ymin, ymax = boundary.ymax;
      if (y < ymin)
        ymin = y;
      else if (y > ymax) ymax = y;

      return new Boundary(xmin, ymin, xmax, ymax);
    }
  }

  /// The minimum x component.
  final int _xmin;

  /// The minimum y component.
  final int _ymin;

  /// The maximum x component.
  final int _xmax;

  /// The maximum y component.
  final int _ymax;

  /// Creates a new boundary.
  factory Boundary(int x1, int y1, int x2, int y2) {
    if (x2 < x1) {
      int temp = x1;
      x1 = x2;
      x2 = temp;
    }
    if (y2 < y1) {
      int temp = y1;
      y1 = y2;
      y2 = temp;
    }
    return new Boundary._(x1, y1, x2, y2);
  }

  /// Creates a new boundary.
  factory Boundary.Corners(IPoint pnt1, IPoint pnt2) {
    return new Boundary(pnt1.x, pnt1.y, pnt2.x, pnt2.y);
  }

  /// Creates a new boundary.
  Boundary._(int this._xmin, int this._ymin, int this._xmax, int this._ymax);

  /// Gets the minimum x component.
  int get xmin => this._xmin;

  /// Gets the minimum y component.
  int get ymin => this._ymin;

  /// Gets the maximum x component.
  int get xmax => this._xmax;

  /// Gets the maximum y component.
  int get ymax => this._ymax;

  /// Gets the width of boundary.
  int get width => this._xmax - this._xmin + 1;

  /// Gets the height of boundary.
  int get height => this._ymax - this._ymin + 1;

  /// Gets the boundary region the given point was in.
  int region(int x, int y) {
    if (this._xmin > x) {
      if (this._ymin > y)
        return BoundaryRegion.SouthWest;
      else if (this._ymax >= y)
        return BoundaryRegion.West;
      else
        return BoundaryRegion.NorthWest;
    } else if (this._xmax >= x) {
      if (this._ymin > y)
        return BoundaryRegion.South;
      else if (this._ymax >= y)
        return BoundaryRegion.Inside;
      else
        return BoundaryRegion.North;
    } else {
      if (this._ymin > y)
        return BoundaryRegion.SouthEast;
      else if (this._ymax >= y)
        return BoundaryRegion.East;
      else
        return BoundaryRegion.NorthEast;
    }
  }

  /// Gets the boundary region the given point was in.
  int regionPoint(IPoint point) => this.region(point.x, point.y);

  /// Checks if the given point is completely contained within this boundary.
  bool contains(int x, int y) => !((this._xmin > x) ||
      (this._xmax < x) ||
      (this._ymin > y) ||
      (this._ymax < y));

  /// Checks if the given point is completely contained within this boundary.
  /// Returns true if the point is fully contained, false otherwise.
  bool containsPoint(IPoint point) => this.contains(point.x, point.y);

  /// Checks if the given edge is completely contained within this boundary.
  /// Returns true if the edge is fully contained, false otherwise.
  bool containsEdge(IEdge edge) =>
      this.contains(edge.x1, edge.y1) && this.contains(edge.x2, edge.y2);

  /// Checks if the given boundary is completely contains by this boundary.
  /// @Returns true if the boundary is fully contained, false otherwise.
  bool containsBoundary(IBoundary boundary) =>
      this.contains(boundary.xmin, boundary.ymin) &&
      this.contains(boundary.xmax, boundary.ymax);

  /// Checks if the given edge overlaps this boundary.
  /// Returns true if the edge is overlaps, false otherwise.
  bool overlapsEdge(IEdge edge) {
    int region1 = this.region(edge.x1, edge.y1);
    if (region1 == BoundaryRegion.Inside) return true;

    int region2 = this.region(edge.x2, edge.y2);
    if (region2 == BoundaryRegion.Inside) return true;

    // If the edge is directly above and below or to the left and right,
    // then it will result in a contained segment.
    int orRegion = region1 | region2;
    if ((orRegion == BoundaryRegion.Horizontal) ||
        (orRegion == BoundaryRegion.Vertical)) return true;

    // Check if both points are on the same side so the edge cannot be
    // contained.
    int andRegion = region1 & region2;
    if (((andRegion & BoundaryRegion.West) == BoundaryRegion.West) ||
        ((andRegion & BoundaryRegion.East) == BoundaryRegion.East) ||
        ((andRegion & BoundaryRegion.North) == BoundaryRegion.North) ||
        ((andRegion & BoundaryRegion.South) == BoundaryRegion.South))
      return false;

    // Check for edge intersection point.
    if ((orRegion & BoundaryRegion.West) == BoundaryRegion.West) {
      int y = ((this._xmin - edge.x1) * (edge.dy / edge.dx) + edge.y1).round();
      if ((y >= this._ymin) && (y <= this._ymax)) return true;
    }
    if ((orRegion & BoundaryRegion.East) == BoundaryRegion.East) {
      int y = ((this._xmax - edge.x1) * (edge.dy / edge.dx) + edge.y1).round();
      if ((y >= this._ymin) && (y <= this._ymax)) return true;
    }
    if ((orRegion & BoundaryRegion.North) == BoundaryRegion.North) {
      int x = ((this._ymin - edge.y1) * (edge.dx / edge.dy) + edge.x1).round();
      if ((x >= this._xmin) && (x <= this._xmax)) return true;
    }
    if ((orRegion & BoundaryRegion.South) == BoundaryRegion.South) {
      int x = ((this._ymax - edge.y1) * (edge.dx / edge.dy) + edge.x1).round();
      if ((x >= this._xmin) && (x <= this._xmax)) return true;
    }
    return false;
  }

  /// Checks if the given boundary overlaps this boundary.
  /// Returns true if the given boundary overlaps this boundary, false otherwise.
  bool overlapsBoundary(IBoundary boundary) => !((this._xmax < boundary.xmin) ||
      (this._ymax < boundary.ymin) ||
      (this._xmin > boundary.xmax) ||
      (this._ymin > boundary.ymax));

  /// Gets the distance squared from this boundary to the given point.
  double distance2(int x, int y) {
    if (this._xmin > x) {
      if (this._ymin > y) {
        return Point.distance2(this._xmin, this._ymin, x, y);
      } else if (this._ymax >= y) {
        double dx = this._xmin.toDouble() - x.toDouble();
        return dx * dx;
      } else {
        return Point.distance2(this._xmin, this._ymax, x, y);
      }
    } else if (this._xmax >= x) {
      if (this._ymin > y) {
        double dy = this._ymin.toDouble() - y.toDouble();
        return dy * dy;
      } else if (this._ymax >= y) {
        return 0.0;
      } else {
        double dy = y.toDouble() - this._ymax.toDouble();
        return dy * dy;
      }
    } else {
      if (this._ymin > y) {
        return Point.distance2(this._xmax, this._ymin, x, y);
      } else if (this._ymax >= y) {
        double dx = x.toDouble() - this._xmax.toDouble();
        return dx * dx;
      } else {
        return Point.distance2(this._xmax, this._ymax, x, y);
      }
    }
  }

  /// Gets the distance squared from this boundary to the given point.
  double distance2Point(IPoint point) => this.distance2(point.x, point.y);

  /// Determines if the given object is equal to this boundary.
  /// Returns true if the object is equal to this edge, false otherwise.
  bool equals(Object o) {
    if (o == null) return false;
    if (o is Boundary) return false;
    Boundary boundary = o as Boundary;
    return (this._xmin == boundary._xmin) &&
        (this._ymin == boundary._ymin) &&
        (this._xmax == boundary._xmax) &&
        (this._ymax == boundary._ymax);
  }

  /// Gets the string for this boundary.
  /// The given [format] is the formatting to use or null to use default.
  String toString({IFormatter format: null}) {
    if (format == null)
      return "[$_xmin, $_ymin, $_xmax, $_ymax]";
    else
      return format.toBoundaryString(this);
  }
}
