part of PolygonalMapDart.Quadtree;

/// The geometric boundary in a quad-tree.
class Boundary implements IBoundary {
  /// Returns the given boundary expanded with the new point.
  static Boundary expand(IBoundary boundary, IPoint point) {
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
  Boundary(int x1, int y1, int x2, int y2) {
    if (x2 < x1) {
      this._xmin = x2;
      this._xmax = x1;
    } else {
      this._xmin = x1;
      this._xmax = x2;
    }
    if (y2 < y1) {
      this._ymin = y2;
      this._ymax = y1;
    } else {
      this._ymin = y1;
      this._ymax = y2;
    }
  }

  /// Creates a new boundary.
  Boundary(IPoint pnt1, IPoint pnt2) {
    this(pnt1.x, pnt1.y, pnt2.x, pnt2.y);
  }

  /// Gets the minimum x component.
  @Override
  int get xmin => this._xmin;

  /// Gets the minimum y component.
  @Override
  int get ymin => this._ymin;

  /// Gets the maximum x component.
  @Override
  int get xmax => this._xmax;

  /// Gets the maximum y component.
  @Override
  int get ymax => this._ymax;

  /// Gets the width of boundary.
  @Override
  int get width => this._xmax - this._xmin + 1;

  /// Gets the height of boundary.
  @Override
  int get height => this._ymax - this._ymin + 1;

  /// Gets the boundary region the given point was in.
  @Override
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
  @Override
  int region(IPoint point) => this.region(point.x, point.y);

  /// Checks if the given point is completely contained within this boundary.
  @Override
  bool contains(int x, int y) => !((this._xmin > x) || (this._xmax < x) || (this._ymin > y) || (this._ymax < y));

  /// Checks if the given point is completely contained within this boundary.
  /// Returns true if the point is fully contained, false otherwise.
  @Override
  bool contains(IPoint point) => this.contains(point.x, point.y);

  /// Checks if the given edge is completely contained within this boundary.
  /// Returns true if the edge is fully contained, false otherwise.
  @Override
  bool contains(IEdge edge) => this.contains(edge.x1, edge.y1) && this.contains(edge.x2, edge.y2);

  /// Checks if the given boundary is completely contains by this boundary.
  /// @Returns true if the boundary is fully contained, false otherwise.
  @Override
  bool contains(IBoundary boundary) =>
      this.contains(boundary.xmin, boundary.ymin) && this.contains(boundary.xmax, boundary.ymax);

  /// Checks if the given edge overlaps this boundary.
  /// Returns true if the edge is overlaps, false otherwise.
  @Override
  bool overlaps(IEdge edge) {
    int region1 = this.region(edge.x1, edge.y1);
    if (region1 == BoundaryRegion.Inside) return true;

    int region2 = this.region(edge.x2, edge.y2);
    if (region2 == BoundaryRegion.Inside) return true;

    // If the edge is directly above and below or to the left and right,
    // then it will result in a contained segment.
    int orRegion = region1 | region2;
    if ((orRegion == BoundaryRegion.Horizontal) || (orRegion == BoundaryRegion.Vertical)) return true;

    // Check if both points are on the same side so the edge cannot be
    // contained.
    int andRegion = region1 & region2;
    if (((andRegion & BoundaryRegion.West) == BoundaryRegion.West) ||
        ((andRegion & BoundaryRegion.East) == BoundaryRegion.East) ||
        ((andRegion & BoundaryRegion.North) == BoundaryRegion.North) ||
        ((andRegion & BoundaryRegion.South) == BoundaryRegion.South)) return false;

    // Check for edge intersection point.
    if ((orRegion & BoundaryRegion.West) == BoundaryRegion.West) {
      int y = Math.round((this._xmin - edge.x1) * (edge.dy / edge.dx) + edge.y1);
      if ((y >= this._ymin) && (y <= this._ymax)) return true;
    }
    if ((orRegion & BoundaryRegion.East) == BoundaryRegion.East) {
      int y = Math.round((this._xmax - edge.x1) * (edge.dy / edge.dx) + edge.y1);
      if ((y >= this._ymin) && (y <= this._ymax)) return true;
    }
    if ((orRegion & BoundaryRegion.North) == BoundaryRegion.North) {
      int x = Math.round((this._ymin - edge.y1) * (edge.dx / edge.dy) + edge.x1);
      if ((x >= this._xmin) && (x <= this._xmax)) return true;
    }
    if ((orRegion & BoundaryRegion.South) == BoundaryRegion.South) {
      int x = Math.round((this._ymax - edge.y1) * (edge.dx / edge.dy) + edge.x1);
      if ((x >= this._xmin) && (x <= this._xmax)) return true;
    }
    return false;
  }

  /// Checks if the given boundary overlaps this boundary.
  /// Returns true if the given boundary overlaps this boundary, false otherwise.
  @Override
  bool overlaps(IBoundary boundary) => !((this._xmax < boundary.xmin) ||
      (this._ymax < boundary.ymin) ||
      (this._xmin > boundary.xmax) ||
      (this._ymin > boundary.ymax));

  /// Gets the distance squared from this boundary to the given point.
  @Override
  double distance2(int x, int y) {
    if (this._xmin > x) {
      if (this._ymin > y) {
        return Point.distance2(this._xmin, this._ymin, x, y);
      } else if (this._ymax >= y) {
        double dx = this._xmin - x;
        return dx * dx;
      } else {
        return Point.distance2(this._xmin, this._ymax, x, y);
      }
    } else if (this._xmax >= x) {
      if (this._ymin > y) {
        double dy = this._ymin - y;
        return dy * dy;
      } else if (this._ymax >= y) {
        return 0.0;
      } else {
        double dy = y - this._ymax;
        return dy * dy;
      }
    } else {
      if (this._ymin > y) {
        return Point.distance2(this._xmax, this._ymin, x, y);
      } else if (this._ymax >= y) {
        double dx = x - this._xmax;
        return dx * dx;
      } else {
        return Point.distance2(this._xmax, this._ymax, x, y);
      }
    }
  }

  /// Gets the distance squared from this boundary to the given point.
  @Override
  double distance2(IPoint point) => this.distance2(point.x, point.y);

  /// Determines if the given object is equal to this boundary.
  /// Returns true if the object is equal to this edge, false otherwise.
  @Override
  bool equals(Object o) {
    if (o == null) return false;
    if (o is Boundary) return false;
    return (this._xmin == o._xmin) && (this._ymin == o._ymin) && (this._xmax == o._xmax) && (this._ymax == o._ymax);
  }

  /// Gets the string for this boundary.
  /// The given [format] is the formatting to use or null to use default.
  String toString({IFormatter format: null}) {
    if (format == null)
      return "[$_xmin, $_ymin, $_xmax, $_ymax]";
    else
      return format.toString(this);
  }
}
