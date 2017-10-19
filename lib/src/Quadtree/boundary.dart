part of PolygonalMapDart.Quadtree;

/// The geometric boundary in a quad-tree.
class Boundary implements IBoundary {
  /// Returns the given boundary expanded with the new point.
  static Boundary expand(IBoundary boundary, IPoint point) {
    if (boundary == null) {
      return new Boundary(point.x, point.y, point.x, point.y);
    } else {
      int xmin = boundary.xmin, xmax = boundary.xmax;
      if (point.x < xmin)
        xmin = point.x;
      else if (point.x > xmax) xmax = point.x;

      int ymin = boundary.ymin, ymax = boundary.ymax;
      if (point.y < ymin)
        ymin = point.y;
      else if (point.y > ymax) ymax = point.y;

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
  Boundary._(this._xmin, this._ymin, this._xmax, this._ymax);

  /// Gets the minimum x component.
  int get xmin => _xmin;

  /// Gets the minimum y component.
  int get ymin => _ymin;

  /// Gets the maximum x component.
  int get xmax => _xmax;

  /// Gets the maximum y component.
  int get ymax => _ymax;

  /// Gets the width of boundary.
  int get width => _xmax - _xmin + 1;

  /// Gets the height of boundary.
  int get height => _ymax - _ymin + 1;

  /// Gets the boundary region the given point was in.
  int region(IPoint point) {
    if (_xmin > point.x) {
      if (_ymin > point.y)
        return BoundaryRegion.SouthWest;
      else if (_ymax >= point.y)
        return BoundaryRegion.West;
      else
        return BoundaryRegion.NorthWest;
    } else if (_xmax >= point.x) {
      if (_ymin > point.y)
        return BoundaryRegion.South;
      else if (_ymax >= point.y)
        return BoundaryRegion.Inside;
      else
        return BoundaryRegion.North;
    } else {
      if (_ymin > point.y)
        return BoundaryRegion.SouthEast;
      else if (_ymax >= point.y)
        return BoundaryRegion.East;
      else
        return BoundaryRegion.NorthEast;
    }
  }

  /// Checks if the given point is completely contained within this boundary.
  bool _contains(int x, int y) =>
      !((_xmin > x) || (_xmax < x) || (_ymin > y) || (_ymax < y));

  /// Checks if the given point is completely contained within this boundary.
  /// Returns true if the point is fully contained, false otherwise.
  bool containsPoint(IPoint point) => _contains(point.x, point.y);

  /// Checks if the given edge is completely contained within this boundary.
  /// Returns true if the edge is fully contained, false otherwise.
  bool containsEdge(IEdge edge) =>
      _contains(edge.x1, edge.y1) && _contains(edge.x2, edge.y2);

  /// Checks if the given boundary is completely contains by this boundary.
  /// @Returns true if the boundary is fully contained, false otherwise.
  bool containsBoundary(IBoundary boundary) =>
      _contains(boundary.xmin, boundary.ymin) &&
      _contains(boundary.xmax, boundary.ymax);

  /// Checks if the given edge overlaps this boundary.
  /// Returns true if the edge is overlaps, false otherwise.
  bool overlapsEdge(IEdge edge) {
    int region1 = region(edge.start);
    if (region1 == BoundaryRegion.Inside) return true;

    int region2 = region(edge.end);
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
      int y = ((_xmin - edge.x1) * (edge.dy / edge.dx) + edge.y1).round();
      if ((y >= _ymin) && (y <= _ymax)) return true;
    }
    if ((orRegion & BoundaryRegion.East) == BoundaryRegion.East) {
      int y = ((_xmax - edge.x1) * (edge.dy / edge.dx) + edge.y1).round();
      if ((y >= _ymin) && (y <= _ymax)) return true;
    }
    if ((orRegion & BoundaryRegion.North) == BoundaryRegion.North) {
      int x = ((_ymin - edge.y1) * (edge.dx / edge.dy) + edge.x1).round();
      if ((x >= _xmin) && (x <= _xmax)) return true;
    }
    if ((orRegion & BoundaryRegion.South) == BoundaryRegion.South) {
      int x = ((_ymax - edge.y1) * (edge.dx / edge.dy) + edge.x1).round();
      if ((x >= _xmin) && (x <= _xmax)) return true;
    }
    return false;
  }

  /// Checks if the given boundary overlaps this boundary.
  /// Returns true if the given boundary overlaps this boundary, false otherwise.
  bool overlapsBoundary(IBoundary boundary) => !((_xmax < boundary.xmin) ||
      (_ymax < boundary.ymin) ||
      (_xmin > boundary.xmax) ||
      (_ymin > boundary.ymax));

  /// Gets the distance squared from this boundary to the given point.
  double distance2(IPoint point) {
    if (_xmin > point.x) {
      if (_ymin > point.y) {
        return Point.distance2(new Point(_xmin, _ymin), point);
      } else if (_ymax >= point.y) {
        double dx = _xmin.toDouble() - point.x.toDouble();
        return dx * dx;
      } else {
        return Point.distance2(new Point(_xmin, _ymax), point);
      }
    } else if (_xmax >= point.x) {
      if (_ymin > point.y) {
        double dy = _ymin.toDouble() - point.y.toDouble();
        return dy * dy;
      } else if (_ymax >= point.y) {
        return 0.0;
      } else {
        double dy = point.y.toDouble() - _ymax.toDouble();
        return dy * dy;
      }
    } else {
      if (_ymin > point.y) {
        return Point.distance2(new Point(_xmax, _ymin), point);
      } else if (_ymax >= point.y) {
        double dx = point.x.toDouble() - _xmax.toDouble();
        return dx * dx;
      } else {
        return Point.distance2(new Point(_xmax, _ymax), point);
      }
    }
  }

  /// Determines if the given object is equal to this boundary.
  /// Returns true if the object is equal to this edge, false otherwise.
  bool equals(Object o) {
    if (o == null) return false;
    if (o is Boundary) return false;
    Boundary boundary = o as Boundary;
    return (_xmin == boundary._xmin) &&
        (_ymin == boundary._ymin) &&
        (_xmax == boundary._xmax) &&
        (_ymax == boundary._ymax);
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
