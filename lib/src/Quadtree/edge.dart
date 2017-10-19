part of PolygonalMapDart.Quadtree;

/// An edge represents a directed line segment between two integer points.
class Edge implements IEdge, Comparable<Edge> {
  /// Gets the squared length of this edge.
  static double length2(IEdge edge) =>
      Point.distance2(edge.start, edge.end);

  /// Determines if the start and end points are the same.
  /// Returns true if the edge has no length, false otherwise.
  static bool degenerate(IEdge edge) =>
      (edge.x1 == edge.x2) && (edge.y1 == edge.y2);

  /// Compares the two given lines.
  /// Returns 1 if the first line is greater than the the second line,
  /// -1 if the first line is less than the the second line,
  /// 0 if the first line is the same as the the second line.
  static int compare(IEdge a, IEdge b) {
    if (a.x1 > b.x1)
      return 1;
    else if (a.x1 < b.x1)
      return -1;
    else if (a.y1 > b.y1)
      return 1;
    else if (a.y1 < b.y1)
      return -1;
    else if (a.x2 > b.x2)
      return 1;
    else if (a.x2 < b.x2)
      return -1;
    else if (a.y2 > b.y2)
      return 1;
    else if (a.y2 < b.y2)
      return -1;
    else
      return 0;
  }

  /// Checks the equality of the two given edges.
  /// [undirected] indicates if true to compare the edges undirected, false to compare directed.
  static bool equals(IEdge a, IEdge b, bool undirected) {
    if (a == null) return b == null;
    if (b == null) return false;
    if ((a.x1 == b.x1) && (a.y1 == b.y1) && (a.x2 == b.x2) && (a.y2 == b.y2))
      return true;
    if (undirected)
      return (a.x1 == b.x2) &&
          (a.y1 == b.y2) &&
          (a.x2 == b.x1) &&
          (a.y2 == b.y1);
    return false;
  }

  /// Checks if one edge is the opposite of the other edge.
  static bool opposites(IEdge a, IEdge b) {
    if (a == null) return b == null;
    if (b == null) return false;
    return (a.x1 == b.x2) && (a.y1 == b.y2) && (a.x2 == b.x1) && (a.y2 == b.y1);
  }

  /// Gets the minimum squared distance between the point and the edge.
  static double distance2(IEdge edge, IPoint point) {
    double dx, dy;
    double leng2 = Edge.length2(edge);
    if (leng2 <= 0.0) {
      dx = (edge.x1 - point.x).toDouble();
      dy = (edge.y1 - point.y).toDouble();
    } else {
      double r = ((point.x - edge.x1) * edge.dx + (point.y - edge.y1) * edge.dy) / leng2;
      if (r <= 0.0) {
        dx = (edge.x1 - point.x).toDouble();
        dy = (edge.y1 - point.y).toDouble();
      } else if (r >= 1.0) {
        dx = (edge.x2 - point.x).toDouble();
        dy = (edge.y2 - point.y).toDouble();
      } else {
        dx = edge.x1 + r * edge.dx - point.x;
        dy = edge.y1 + r * edge.dy - point.y;
      }
    }
    return dx * dx + dy * dy;
  }

  /// Finds the start point based cross product for the given edges.
  /// Returs the z component of the cross product vector for the two given edges.
  static double cross(IEdge edge1, IEdge edge2) =>
      Point.cross(new Point(edge1.dx, edge1.dy), new Point(edge2.dx, edge2.dy));

  /// Finds the start point based dot product for the given edges.
  /// Returns the dot product vector for the two given edges.
  static double dot(IEdge edge1, IEdge edge2) =>
      Point.dot(new Point(edge1.dx, edge1.dy), new Point(edge2.dx, edge2.dy));

  /// Determines if the two edges are acute or not.
  /// Returns true if the two edges are acute (<90), false if not.
  static bool acute(IEdge edge1, IEdge edge2) => dot(edge1, edge2) > 0.0;

  /// Determines if the two edges are obtuse or not.
  /// Returns true if the two edges are obtuse (>90), false if not.
  static bool obtuse(IEdge edge1, IEdge edge2) => dot(edge1, edge2) < 0.0;

  /// Gets the side of the edge the given point is on.
  static int side(IEdge edge, IPoint point) {
    double value =
        Point.cross(new Point(edge.dx, edge.dy), new Point(point.x - edge.x1, point.y - edge.y1));
    double epsilon = 1.0e-12;
    if (value.abs() <= epsilon)
      return Side.Inside;
    else if (value < 0.0)
      return Side.Right;
    else
      return Side.Left; // value > 0.0
  }

  /// Gets the intersection location of the given point on the edge.
  static PointOnEdgeResult pointOnEdge(IEdge edge, IPoint point) {
    if (Edge.degenerate(edge))
      return null;
    else if (Point.equals(point, edge.start))
      return new PointOnEdgeResult(
          edge, point, IntersectionLocation.AtStart, point, true, point, true);
    else if (Point.equals(point, edge.end))
      return new PointOnEdgeResult(
          edge, point, IntersectionLocation.AtEnd, point, true, point, true);
    else {
      // Calculate closest point on the edge's line.
      // The denominator can't be zero because the edge isn't degenerate.
      double dx = edge.dx.toDouble();
      double dy = edge.dy.toDouble();
      double numer = (point.x - edge.x1) * dx + (point.y - edge.y1) * dy;
      double denom = dx * dx + dy * dy;
      double t = numer / denom;
      int x = (edge.x1 + t * dx).round();
      int y = (edge.y1 + t * dy).round();
      IPoint closestOnLine = new Point(x, y);
      bool onLine = false;
      if (Point.equals(closestOnLine, point)) {
        closestOnLine = point;
        onLine = true;
      }
      IPoint closestOnEdge = closestOnLine;
      bool onEdge = onLine;

      int location;
      if (Point.equals(closestOnLine, edge.start)) {
        location = IntersectionLocation.AtStart;
      } else if (Point.equals(closestOnLine, edge.end)) {
        location = IntersectionLocation.AtEnd;
      } else if (t <= 0.0) {
        location = IntersectionLocation.BeforeStart;
        closestOnLine = edge.start;
        onEdge = false;
      } else if (t >= 1.0) {
        location = IntersectionLocation.PastEnd;
        closestOnLine = edge.end;
        onEdge = false;
      } else {
        location = IntersectionLocation.InMiddle;
      }

      return new PointOnEdgeResult(
          edge, point, location, closestOnEdge, onEdge, closestOnLine, onLine);
    }
  }

  /// Determines the way the two given edges intersect.
  static IntersectionResult intersect(IEdge edgeA, IEdge edgeB) {
    if ((edgeA == null) || Edge.degenerate(edgeA)) return null;
    if ((edgeA == null) || Edge.degenerate(edgeA)) return null;

    PointOnEdgeResult startBOnEdgeA = pointOnEdge(edgeA, edgeB.start);
    PointOnEdgeResult endBOnEdgeA = pointOnEdge(edgeA, edgeB.end);
    PointOnEdgeResult startAOnEdgeB = pointOnEdge(edgeB, edgeA.start);
    PointOnEdgeResult endAOnEdgeB = pointOnEdge(edgeB, edgeA.end);

    bool intersects;
    int intType;
    IPoint intPnt;
    int locA;
    int locB;

    int dAx = edgeA.dx, dAy = edgeA.dy;
    int dBx = edgeB.dx, dBy = edgeB.dy;
    int denom = (dAx * dBy) - (dAy * dBx);

    if (startBOnEdgeA.onEdge) {
      if (endBOnEdgeA.onEdge) {
        if (startAOnEdgeB.onEdge) {
          if (endAOnEdgeB.onEdge) {
            // OnEdge: startBOnEdgeA, endBOnEdgeA, startAOnEdgeB, and endAOnEdgeB
            // The only way that all four points could be on the edges
            // is if the edges are the same or opposite.
            intersects = true;
            locA = IntersectionLocation.None;
            locB = IntersectionLocation.None;
            intPnt = null;
            if (startBOnEdgeA.location == IntersectionLocation.AtStart) {
              intType = IntersectionType.Same;
              assert(Point.equals(edgeA.start, edgeB.start));
              assert(Point.equals(edgeA.end, edgeB.end));
            } else {
              intType = IntersectionType.Opposite;
              assert(Point.equals(edgeA.start, edgeB.end));
              assert(Point.equals(edgeA.end, edgeB.start));
            }
          } else {
            // OnEdge: startBOnEdgeA, endBOnEdgeA, and startAOnEdgeB
            // If there are three points on an edge, then the edges coincide.
            intersects = true;
            locA = IntersectionLocation.None;
            locB = IntersectionLocation.None;
            intPnt = null;
            intType = IntersectionType.Coincide;
          }
        } else if (endAOnEdgeB.onEdge) {
          // OnEdge: startBOnEdgeA, endBOnEdgeA, and endAOnEdgeB
          // If there are three points on an edge, then the edges coincide.
          intersects = true;
          locA = IntersectionLocation.None;
          locB = IntersectionLocation.None;
          intPnt = null;
          intType = IntersectionType.Coincide;
        } else {
          // OnEdge: startBOnEdgeA, and endBOnEdgeA
          // Since both points on the same edge are on the other one edge is contained by the other.
          intersects = true;
          locA = IntersectionLocation.None;
          locB = IntersectionLocation.None;
          intPnt = null;
          intType = IntersectionType.Coincide;
        }
      } else if (startAOnEdgeB.onEdge) {
        if (endAOnEdgeB.onEdge) {
          // OnEdge: startBOnEdgeA, startAOnEdgeB, and endAOnEdgeB
          // If there are three points on an edge, then the edges coincide.
          intersects = true;
          locA = IntersectionLocation.None;
          locB = IntersectionLocation.None;
          intPnt = null;
          intType = IntersectionType.Coincide;
        } else {
          // OnEdge: startBOnEdgeA, and startAOnEdgeB
          // Since only two points overlap the edges are either partially
          // coincident or they touch at the start point.
          intersects = true;
          if ((startBOnEdgeA.location == IntersectionLocation.InMiddle) ||
              (startAOnEdgeB.location == IntersectionLocation.InMiddle)) {
            locA = IntersectionLocation.None;
            locB = IntersectionLocation.None;
            intPnt = null;
            intType = IntersectionType.Coincide;
          } else {
            locA = IntersectionLocation.AtStart;
            locB = IntersectionLocation.AtStart;
            intPnt = edgeA.start;
            intType = (denom == 0)
                ? IntersectionType.Collinear
                : IntersectionType.Point;
            assert(Point.equals(edgeA.start, edgeB.start));
          }
        }
      } else if (endAOnEdgeB.onEdge) {
        // OnEdge: startBOnEdgeA, and endAOnEdgeB
        // Since only two points overlap the edges are either partially
        // coincident or they touch at the start point.
        intersects = true;
        if ((startBOnEdgeA.location == IntersectionLocation.InMiddle) ||
            (endAOnEdgeB.location == IntersectionLocation.InMiddle)) {
          locA = IntersectionLocation.None;
          locB = IntersectionLocation.None;
          intPnt = null;
          intType = IntersectionType.Coincide;
        } else {
          locA = IntersectionLocation.AtEnd;
          locB = IntersectionLocation.AtStart;
          intPnt = edgeB.start;
          intType = (denom == 0)
              ? IntersectionType.Collinear
              : IntersectionType.Point;
          assert(Point.equals(edgeB.start, edgeA.end));
        }
      } else {
        // OnEdge: startBOnEdgeA
        // Since only one point is on an edge that point must be the
        // intersection in the middle of the edge.
        intersects = true;
        locA = IntersectionLocation.InMiddle;
        locB = IntersectionLocation.AtStart;
        intPnt = edgeB.start;
        intType = IntersectionType.Point;
        assert(startBOnEdgeA.location == IntersectionLocation.InMiddle);
      }
    } else if (endBOnEdgeA.onEdge) {
      if (startAOnEdgeB.onEdge) {
        if (endAOnEdgeB.onEdge) {
          // OnEdge: endBOnEdgeA, startAOnEdgeB, and endAOnEdgeB
          // If there are three points on an edge, then the edges coincide.
          intersects = true;
          locA = IntersectionLocation.None;
          locB = IntersectionLocation.None;
          intPnt = null;
          intType = IntersectionType.Coincide;
        } else {
          // OnEdge: endBOnEdgeA, and startAOnEdgeB
          // Since only two points overlap the edges are either partially
          // coincident or they touch at the start point.
          intersects = true;
          if ((endBOnEdgeA.location == IntersectionLocation.InMiddle) ||
              (startAOnEdgeB.location == IntersectionLocation.InMiddle)) {
            locA = IntersectionLocation.None;
            locB = IntersectionLocation.None;
            intPnt = null;
            intType = IntersectionType.Coincide;
          } else {
            locA = IntersectionLocation.AtStart;
            locB = IntersectionLocation.AtEnd;
            intPnt = edgeA.start;
            intType = (denom == 0)
                ? IntersectionType.Collinear
                : IntersectionType.Point;
            assert(Point.equals(edgeA.start, edgeB.end));
          }
        }
      } else if (endAOnEdgeB.onEdge) {
        // OnEdge: endBOnEdgeA, and endAOnEdgeB
        // Since only two points overlap the edges are either partially
        // coincident or they touch at the start point.
        intersects = true;
        if ((endBOnEdgeA.location == IntersectionLocation.InMiddle) ||
            (endAOnEdgeB.location == IntersectionLocation.InMiddle)) {
          locA = IntersectionLocation.None;
          locB = IntersectionLocation.None;
          intPnt = null;
          intType = IntersectionType.Coincide;
        } else {
          locA = IntersectionLocation.AtEnd;
          locB = IntersectionLocation.AtEnd;
          intPnt = edgeA.end;
          intType = (denom == 0)
              ? IntersectionType.Collinear
              : IntersectionType.Point;
          assert(Point.equals(edgeA.end, edgeB.end));
        }
      } else {
        // OnEdge: endBOnEdgeA
        // Since only one point is on an edge that point must be the
        // intersection in the middle of the edge.
        intersects = true;
        locA = IntersectionLocation.InMiddle;
        locB = IntersectionLocation.AtEnd;
        intPnt = edgeB.end;
        intType = IntersectionType.Point;
        assert(endBOnEdgeA.location == IntersectionLocation.InMiddle);
      }
    } else if (startAOnEdgeB.onEdge) {
      if (endAOnEdgeB.onEdge) {
        // OnEdge: startAOnEdgeB, and endAOnEdgeB
        // Since both points on the same edge are on the other one edge is contained by the other.
        intersects = true;
        locA = IntersectionLocation.None;
        locB = IntersectionLocation.None;
        intPnt = null;
        intType = IntersectionType.Coincide;
      } else {
        // OnEdge: startAOnEdgeB
        // Since only one point is on an edge that point must be the
        // intersection in the middle of the edge.
        intersects = true;
        locA = IntersectionLocation.AtStart;
        locB = IntersectionLocation.InMiddle;
        intPnt = edgeA.start;
        intType = IntersectionType.Point;
        assert(startAOnEdgeB.location == IntersectionLocation.InMiddle);
      }
    } else if (endAOnEdgeB.onEdge) {
      // OnEdge: endAOnEdgeB
      // Since only one point is on an edge that point must be the
      // intersection in the middle of the edge.
      intersects = true;
      locA = IntersectionLocation.AtEnd;
      locB = IntersectionLocation.InMiddle;
      intPnt = edgeA.end;
      intType = IntersectionType.Point;
      assert(endAOnEdgeB.location == IntersectionLocation.InMiddle);
    } else if (denom == 0) {
      // If there are no points on edge but the lines are parallel.
      intersects = false;
      locA = IntersectionLocation.None;
      locB = IntersectionLocation.None;
      intPnt = null;
      if (startBOnEdgeA.onLine) {
        intType = IntersectionType.Collinear;
      } else {
        intType = IntersectionType.Parallel;
      }
    } else {
      // Lines intersect at a point.
      int dABx = edgeA.x1 - edgeB.x1;
      int dABy = edgeA.y1 - edgeB.y1;
      int numA = (dABy * dBx) - (dABx * dBy);
      double rA = numA / denom;

      // Calculate the point of intersection.
      intPnt = new Point(
          (edgeA.x1 + rA * dAx).round(), (edgeA.y1 + rA * dAy).round());

      int numB = (dABy * dAx) - (dABx * dAy);
      double rB = numB / denom;

      // Find location of intersection location on edgeA.
      if (Point.equals(intPnt, edgeA.start)) {
        locA = IntersectionLocation.AtStart;
        intersects = true;
      } else if (Point.equals(intPnt, edgeA.end)) {
        locA = IntersectionLocation.AtEnd;
        intersects = true;
      } else if (rA <= 0.0) {
        locA = IntersectionLocation.BeforeStart;
        intersects = false;
      } else if (rA >= 1.0) {
        locA = IntersectionLocation.PastEnd;
        intersects = false;
      } else {
        locA = IntersectionLocation.InMiddle;
        intersects = true;
      }

      // Find location of intersection location on edgeB.
      if (Point.equals(intPnt, edgeB.start)) {
        locB = IntersectionLocation.AtStart;
      } else if (Point.equals(intPnt, edgeB.end)) {
        locB = IntersectionLocation.AtEnd;
      } else if (rB <= 0.0) {
        locB = IntersectionLocation.BeforeStart;
        intersects = false;
      } else if (rB >= 1.0) {
        locB = IntersectionLocation.PastEnd;
        intersects = false;
      } else {
        locB = IntersectionLocation.InMiddle;
      }

      if (intersects) {
        intType = IntersectionType.Point;
      } else {
        intType = IntersectionType.None;
      }
    }

    return new IntersectionResult(edgeA, edgeB, intersects, intType, intPnt,
        locA, locB, startBOnEdgeA, endBOnEdgeA, startAOnEdgeB, endAOnEdgeB);
  }

  /// Formats the edges into a string.
  /// [contained] indicates this output is part of another part.
  /// [last] indicate this is the last set in a list of parents.
  static void edgeNodesToBuffer(Set<EdgeNode> nodes, StringBuffer sout,
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

  /// The start point of the edge.
  final IPoint _start;

  /// The end point of the edge.
  final IPoint _end;

  /// Any additional data that this edge should contain.
  Object _data;

  /// Creates a new edge.
  Edge(this._start, this._end, [this._data = null]);

  /// Gets the first component of the start point of the edge.
  int get x1 => _start.x;

  /// Gets the second component of the start point of the edge.
  int get y1 => _start.y;

  /// Gets the first component of the end point of the edge.
  int get x2 => _end.x;

  /// Gets the second component of the end point of the edge.
  int get y2 => _end.y;

  /// Any additional data that this edge should contain.
  Object get data => _data;
  set data(Object data) => _data = data;

  /// Gets the start point for this edge.
  IPoint get start => _start;

  /// Gets the end point for this edge.
  IPoint get end => _end;

  /// Gets the change in the first component, delta X.
  int get dx => x2 - x1;

  /// Gets the change in the second component, delta Y.
  int get dy => y2 - y1;

  /// Gets the opposite direction edge.
  Edge get opposite => new Edge(_end, _start);

  /// Compares the given line with this line.
  /// Returns 1 if this line is greater than the other line,
  /// -1 if this line is less than the other line,
  /// 0 if this line is the same as the other line.
  int compareTo(Edge other) => compare(this, other);

  /// Gets the string for this edge.
  String toString([IFormatter format = null]) {
    if (format == null)
      return "[ $x1, $y1, $x2, $y2]";
    else
      return format.toEdgeString(this);
  }
}
