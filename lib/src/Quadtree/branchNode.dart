part of PolygonalMapDart.Quadtree;

/// The branch node is a quad-tree branching node with four children nodes.
class BranchNode extends BaseNode {
  /// The north-east child node.
  INode _ne;

  /// The north-west child node.
  INode _nw;

  /// The south-east child node.
  INode _se;

  /// The south-west child node.
  INode _sw;

  /// Creates a new branch node.
  BranchNode() : super._() {
    _ne = EmptyNode.instance;
    _nw = EmptyNode.instance;
    _se = EmptyNode.instance;
    _sw = EmptyNode.instance;
  }

  /// Adds an edge to this node and/or children nodes.
  /// Returns the node that should be the new root of the subtree that was
  /// defined by this node.
  INode insertEdge(EdgeNode edge) {
    bool changed = false;
    if (overlapsEdge(edge)) {
      for (int quad in Quadrant.All) {
        INode node = child(quad);
        INode newChild;
        if (node is EmptyNode) {
          newChild = EmptyNode.instance
              .addEdge(childX(quad), childY(quad), width ~/ 2, edge);
        } else
          newChild = (node as BaseNode).insertEdge(edge);
        if (setChild(quad, newChild)) {
          changed = true;
        }
      }
    }

    if (changed)
      return reduce();
    else
      return this;
  }

  /// Adds a point to this node.
  /// Returns the node that should be the new root of the subtree that was
  /// defined by this node.
  INode insertPoint(PointNode point) {
    int quad = childQuad(point);
    INode node = child(quad);
    if (node is EmptyNode) {
      INode child = EmptyNode.instance
          .addPoint(childX(quad), childY(quad), width ~/ 2, point);
      if (setChild(quad, child)) return reduce();
    } else {
      INode child = (node as BaseNode).insertPoint(point);
      if (setChild(quad, child)) return reduce();
    }
    return this;
  }

  /// Removes a edge from the tree at this node.
  /// [trimTree] indicates if the end points of the edge should be
  /// removed if no other edges begins or ends at that point.
  /// Returns the node that should be the new root of the subtree that was
  /// defined by this node.
  INode removeEdge(EdgeNode edge, bool trimTree) {
    bool changed = false;
    if (overlapsEdge(edge)) {
      for (int quad in Quadrant.All) {
        INode node = child(quad);
        if (node is! EmptyNode) {
          if (setChild(quad, (node as BaseNode).removeEdge(edge, trimTree))) {
            changed = true;
            // Even if child changes don't skip others.
          }
        }
      }
    }

    if (changed)
      return reduce();
    else
      return this;
  }

  /// This handles the first found intersecting edge.
  IntersectionResult findFirstIntersection(IEdge edge, IEdgeHandler hndl) {
    if (overlapsEdge(edge)) {
      IntersectionResult result;
      result = _ne.findFirstIntersection(edge, hndl);
      if (result != null) return result;
      result = _nw.findFirstIntersection(edge, hndl);
      if (result != null) return result;
      result = _se.findFirstIntersection(edge, hndl);
      if (result != null) return result;
      result = _sw.findFirstIntersection(edge, hndl);
      if (result != null) return result;
    }
    return null;
  }

  /// This handles all the intersections.
  bool findAllIntersections(
      IEdge edge, IEdgeHandler hndl, IntersectionSet intersections) {
    bool result = false;
    if (overlapsEdge(edge)) {
      if (_ne.findAllIntersections(edge, hndl, intersections)) result = true;
      if (_nw.findAllIntersections(edge, hndl, intersections)) result = true;
      if (_se.findAllIntersections(edge, hndl, intersections)) result = true;
      if (_sw.findAllIntersections(edge, hndl, intersections)) result = true;
    }
    return result;
  }

  /// Gets the north-east child node.
  INode get ne => _ne;

  /// Gets the north-west child node.
  INode get nw => _nw;

  /// Gets the south-east child node.
  INode get se => _se;

  /// Gets the south-west child node.
  INode get sw => _sw;

  /// Handles each point node reachable from this node in the boundary.
  /// Returns true if all points in the boundary were run, false if stopped.
  bool foreachPoint(IPointHandler handle, [IBoundary bounds = null]) {
    if ((bounds == null) || overlapsBoundary(bounds)) {
      return _ne.foreachPoint(handle, bounds) &&
          _nw.foreachPoint(handle, bounds) &&
          _se.foreachPoint(handle, bounds) &&
          _sw.foreachPoint(handle, bounds);
    }
    return true;
  }

  /// Handles each edge node reachable from this node in the boundary.
  /// [exclusive] indicates that only edge which have both end points
  /// inside the region are collected, otherwise any edge which
  /// exists even partially in the region are collected.
  /// Returns true if all edges in the boundary were run, false if stopped.
  bool foreachEdge(IEdgeHandler handle,
      [IBoundary bounds = null, bool exclusive = false]) {
    if ((bounds == null) || overlapsBoundary(bounds)) {
      return _ne.foreachEdge(handle, bounds, exclusive) &&
          _nw.foreachEdge(handle, bounds, exclusive) &&
          _se.foreachEdge(handle, bounds, exclusive) &&
          _sw.foreachEdge(handle, bounds, exclusive);
    }
    return true;
  }

  /// Handles each node reachable from this node in the boundary.
  /// Returns true if all nodes in the boundary were run,
  /// false if stopped.
  bool foreachNode(INodeHandler handle, [IBoundary bounds = null]) {
    if ((bounds == null) || overlapsBoundary(bounds)) {
      return handle.handle(this) &&
          _ne.foreachNode(handle, bounds) &&
          _nw.foreachNode(handle, bounds) &&
          _se.foreachNode(handle, bounds) &&
          _sw.foreachNode(handle, bounds);
    }
    return true;
  }

  /// Determines if the node has any point nodes inside it.
  /// Returns true if this node has any points in it, false otherwise.
  ///
  /// The only way this branch hasn't been reduced is
  /// because there is at least two points in it.
  bool get hasPoints => true;

  /// Determines if the node has any edge nodes inside it.
  /// Returns true if this edge has any edges in it, false otherwise.
  bool get hasEdges =>
      _ne.hasEdges && _nw.hasEdges && _se.hasEdges && _sw.hasEdges;

  /// Gets the first edge to the left of the given point.
  void firstLeftEdge(FirstLeftEdgeArgs args) {
    if ((args.queryPoint.y <= ymax) && (args.queryPoint.y >= ymin)) {
      int quad = childQuad(args.queryPoint);
      switch (quad) {
        case BoundaryRegion.NorthEast:
          _ne.firstLeftEdge(args);
          if (args.found) {
            // If no edges in the NW child could have a larger right value, skip.
            if (args.rightValue > (xmin + width / 2)) break;
          }
          _nw.firstLeftEdge(args);
          break;

        case BoundaryRegion.NorthWest:
          _nw.firstLeftEdge(args);
          break;

        case BoundaryRegion.SouthEast:
          _se.firstLeftEdge(args);
          if (args.found) {
            // If no edges in the SW child could have a larger right value, skip.
            if (args.rightValue > (xmin + width / 2)) break;
          }
          _sw.firstLeftEdge(args);
          break;

        case BoundaryRegion.SouthWest:
          _sw.firstLeftEdge(args);
          break;
      }
    }
  }

  /// Handles all the edges to the left of the given point.
  /// Returns true if all the edges were processed,
  /// false if the handle stopped early.
  bool foreachLeftEdge(IPoint point, IEdgeHandler hndl) {
    bool result = true;
    if ((point.y <= ymax) && (point.y >= ymin)) {
      int quad = childQuad(point);
      switch (quad) {
        case BoundaryRegion.NorthEast:
          result = _ne.foreachLeftEdge(point, hndl);
          if (!result) break;
          result = _nw.foreachLeftEdge(point, hndl);
          break;

        case BoundaryRegion.NorthWest:
          result = _nw.foreachLeftEdge(point, hndl);
          break;

        case BoundaryRegion.SouthEast:
          result = _se.foreachLeftEdge(point, hndl);
          if (!result) break;
          result = _sw.foreachLeftEdge(point, hndl);
          break;

        case BoundaryRegion.SouthWest:
          result = _sw.foreachLeftEdge(point, hndl);
          break;
      }
    }
    return result;
  }

  /// Gets the quadrant of the child in the direction of the given point.
  /// This doesn't check that the point is actually contained by the child indicated,
  /// only the child in the direction of the point.
  int childQuad(IPoint pnt) {
    int half = width ~/ 2;
    bool south = (pnt.y < (ymin + half));
    bool west = (pnt.x < (xmin + half));
    if (south) {
      if (west)
        return Quadrant.SouthWest;
      else
        return Quadrant.SouthEast;
    } else {
      if (west)
        return Quadrant.NorthWest;
      else
        return Quadrant.NorthEast;
    }
  }

  /// Gets the quadrant of the given child node.
  int childNodeQuad(INode node) {
    if (_ne == node)
      return Quadrant.NorthEast;
    else if (_nw == node)
      return Quadrant.NorthWest;
    else if (_se == node)
      return Quadrant.SouthEast;
    else
      /*  this._sw == node */
      return Quadrant.SouthWest;
  }

  /// Gets the minimum x location of the child of the given quadrant.
  int childX(int quad) {
    switch (quad) {
      case Quadrant.NorthEast:
      case Quadrant.SouthEast:
        return xmin + width ~/ 2;
      case Quadrant.NorthWest:
      case Quadrant.SouthWest:
        return xmin;
      default:
        return 0;
    }
  }

  /// Gets the minimum y location of the child of the given quadrant.
  int childY(int quad) {
    switch (quad) {
      case Quadrant.NorthEast:
      case Quadrant.NorthWest:
        return ymin + width ~/ 2;
      case Quadrant.SouthEast:
      case Quadrant.SouthWest:
        return ymin;
      default:
        return 0;
    }
  }

  /// Gets the child at a given quadrant.
  INode child(int childQuad) {
    switch (childQuad) {
      case Quadrant.NorthEast:
        return _ne;
      case Quadrant.NorthWest:
        return _nw;
      case Quadrant.SouthEast:
        return _se;
      case Quadrant.SouthWest:
        return _sw;
      default:
        return null;
    }
  }

  /// This sets the child at a given quadrant.
  /// Returns true if the child was changed, false if there was not change.
  bool setChild(int childQuad, INode node) {
    assert(node != this);
    switch (childQuad) {
      case Quadrant.NorthEast:
        if (_ne == node) return false;
        _ne = node;
        break;

      case Quadrant.NorthWest:
        if (_nw == node) return false;
        _nw = node;
        break;

      case Quadrant.SouthEast:
        if (_se == node) return false;
        _se = node;
        break;

      case Quadrant.SouthWest:
        if (_sw == node) return false;
        _sw = node;
        break;

      default:
        return false;
    }
    if (node is! EmptyNode) {
      (node as BaseNode).parent = this;
    }
    return true;
  }

  /// Returns the first point within the given boundary in this node.
  /// The given [boundary] is the boundary to search within,
  /// or null for no boundary.
  /// Returns the first point node in the given boundary,
  /// or null if none was found.
  PointNode findFirstPoint(IBoundary boundary, IPointHandler handle) {
    if ((boundary == null) || overlapsBoundary(boundary)) {
      for (int quad in Quadrant.All) {
        INode node = child(quad);
        if (node is PointNode) {
          if ((boundary == null) || boundary.containsPoint(node)) {
            if ((handle != null) && (!handle.handle(node))) continue;
            return node;
          }
        } else if (node is BranchNode) {
          PointNode result = node.findFirstPoint(boundary, handle);
          if (result != null) return result;
        }
      }
    }
    return null;
  }

  /// Returns the last point within the given boundary in this node.
  /// The given [boundary] is the boundary to search within,
  /// or null for no boundary.
  /// Returns the last point node in the given boundary,
  /// or null if none was found.
  PointNode findLastPoint(IBoundary boundary, IPointHandler handle) {
    if ((boundary == null) || overlapsBoundary(boundary)) {
      for (int quad in Quadrant.All) {
        INode node = child(quad);
        if (node is PointNode) {
          if ((boundary == null) || boundary.containsPoint(node)) {
            if ((handle != null) && (!handle.handle(node))) continue;
            return node;
          }
        } else if (node is BranchNode) {
          PointNode result = node.findLastPoint(boundary, handle);
          if (result != null) return result;
        }
      }
    }
    return null;
  }

  /// Returns the next point in this node after the given child.
  /// The [curNode] is the child node to find the next from.
  /// Returns the next point node in the given region,
  /// or null if none was found.
  PointNode findNextPoint(
      INode curNode, IBoundary boundary, IPointHandler handle) {
    List<int> others = null;
    switch (childNodeQuad(curNode)) {
      case Quadrant.NorthWest:
        others = [Quadrant.NorthEast, Quadrant.SouthWest, Quadrant.SouthEast];
        break;
      case Quadrant.NorthEast:
        others = [Quadrant.SouthWest, Quadrant.SouthEast];
        break;
      case Quadrant.SouthWest:
        others = [Quadrant.SouthEast];
        break;
      case Quadrant.SouthEast:
        others = [];
        break;
      default:
        return null;
    }

    for (int quad in others) {
      INode node = child(quad);
      if (node is PointNode) {
        if ((boundary == null) || boundary.containsPoint(node)) {
          if ((handle != null) && (!handle.handle(node)))
            continue;
          else
            return node;
        }
      } else if (node is BranchNode) {
        PointNode result = node.findFirstPoint(boundary, handle);
        if (result != null) return result;
      }
    }

    if (parent == null)
      return null;
    else
      return parent.findNextPoint(this, boundary, handle);
  }

  /// Returns the previous point in this node after the given child.
  /// The [curNode] is the child node to find the next from.
  /// Returns the previous point node in the given region,
  /// or null if none was found.
  PointNode findPreviousPoint(
      INode curNode, IBoundary boundary, IPointHandler handle) {
    List<int> others = null;
    switch (childNodeQuad(curNode)) {
      case Quadrant.NorthWest:
        others = [];
        break;
      case Quadrant.NorthEast:
        others = [Quadrant.NorthWest];
        break;
      case Quadrant.SouthWest:
        others = [Quadrant.NorthWest, Quadrant.NorthEast];
        break;
      case Quadrant.SouthEast:
        others = [Quadrant.NorthWest, Quadrant.NorthEast, Quadrant.SouthWest];
        break;
      default:
        return null;
    }

    for (int quad in others) {
      INode node = child(quad);
      if (node is PointNode) {
        if ((boundary == null) || boundary.containsPoint(node)) {
          if ((handle != null) && (!handle.handle(node)))
            continue;
          else
            return node;
        }
      } else if (node is BranchNode) {
        PointNode result = node.findLastPoint(boundary, handle);
        if (result != null) return result;
      }
    }

    if (parent == null)
      return null;
    else
      return parent.findPreviousPoint(this, boundary, handle);
  }

  /// Determine if this node can be reduced.
  /// Returns this grey node if not reduced,
  /// or the reduced node to replace this node with.
  INode reduce() {
    // A branch node can be reduced any time the all of the children
    // contain no points or only one point.
    int pointCount = _pointWeight(_ne) +
        _pointWeight(_nw) +
        _pointWeight(_se) +
        _pointWeight(_sw);
    if (pointCount == 0) {
      // Find a dark node and populate it with the other dark nodes' lines.
      PassNode pass = null;
      for (int quad in Quadrant.All) {
        INode node = child(quad);
        if (node is PassNode) {
          if (pass == null) {
            pass = node;
            pass.setLocation(xmin, ymin, width);
            pass.parent = null;
            setChild(quad, EmptyNode.instance);
          } else {
            // Copy all edges from this pass node into the already found pass node.
            pass.passEdges.addAll(node.passEdges);
          }
        }
      }

      // Return either the found pass node or the empty node.
      if (pass != null)
        return pass;
      else
        return EmptyNode.instance;
    } else if (pointCount == 1) {
      // Find the point node in the children.
      PointNode point = null;
      for (int quad in Quadrant.All) {
        INode node = child(quad);
        if (node is PointNode) {
          // Point node found, relocate and remove the node
          // from this parent node so that it isn't deleted later.
          point = node;
          point.setLocation(xmin, ymin, width);
          point.parent = null;
          setChild(quad, EmptyNode.instance);
          break;
        }
      }
      if (point == null) return EmptyNode.instance;

      // Find any dark nodes and copy all lines into the black node.
      for (int quad in Quadrant.All) {
        INode node = child(quad);
        if (node is PassNode) {
          // Add all passing lines to black node unless the line starts or ends
          // on the black node, since the line will already be in the start or end line lists.
          for (EdgeNode edge in node.passEdges) {
            if ((edge.startNode != point) && (edge.endNode != point))
              point.passEdges.add(edge);
          }
        }
      }

      // Return found point node.
      return point;
    } else {
      // Can't reduce so return this node.
      return this;
    }
  }

  /// Gets a weighting which indicates the minimum amount
  /// of points which can be in the node.
  int _pointWeight(INode node) {
    if (node is PointNode)
      return 1;
    else if (node is BranchNode)
      return 2;
    else if (node is PassNode)
      return 0;
    else
      /* (node is EmptyNode) */
      return 0;
  }

  //// Validates this node.
  bool validate(StringBuffer sout, IFormatter format, bool recursive) {
    bool result = true;
    if (!_validateChild(sout, format, recursive, _ne, "NE", true, true))
      result = false;
    if (!_validateChild(sout, format, recursive, _nw, "NW", true, false))
      result = false;
    if (!_validateChild(sout, format, recursive, _sw, "SW", false, false))
      result = false;
    if (!_validateChild(sout, format, recursive, _se, "SE", false, true))
      result = false;
    return result;
  }

  /// Validates the given child node.
  bool _validateChild(StringBuffer sout, IFormatter format, bool recursive,
      INode child, String name, bool north, bool east) {
    if (child == null) {
      sout.write("Error in ");
      toBuffer(sout, format: format);
      sout.write(": The ");
      sout.write(name);
      sout.write(" child was null.\n");
      return false;
    }

    bool result = true;
    if (child is! EmptyNode) {
      BaseNode bnode = child as BaseNode;
      if (bnode.parent != this) {
        sout.write("Error in ");
        toBuffer(sout, format: format);
        sout.write(": The ");
        sout.write(name);
        sout.write(" child, ");
        child.toBuffer(sout, format: format);
        sout.write(", parent wasn't this node, it was ");
        (child as BaseNode).parent.toBuffer(sout, format: format);
        sout.write(".\n");
        result = false;
      }

      if (width / 2 != bnode.width) {
        sout.write("Error in ");
        toBuffer(sout, format: format);
        sout.write(": The ");
        sout.write(name);
        sout.write(" child, ");
        child.toBuffer(sout, format: format);
        sout.write(", was ");
        sout.write(bnode.width);
        sout.write(" wide, but should have been ");
        sout.write(width / 2);
        sout.write(".\n");
        result = false;
      }

      int left = east ? (xmin + bnode.width) : xmin;
      int top = north ? (ymin + bnode.width) : ymin;
      if ((left != bnode.xmin) || (top != bnode.ymin)) {
        sout.write("Error in ");
        toBuffer(sout, format: format);
        sout.write(": The ");
        sout.write(name);
        sout.write(" child, ");
        child.toBuffer(sout, format: format);
        sout.write(", was at [");
        sout.write(bnode.xmin);
        sout.write(", ");
        sout.write(bnode.ymin);
        sout.write("], but should have been [");
        sout.write(left);
        sout.write(", ");
        sout.write(top);
        sout.write("].\n");
        result = false;
      }
    }

    if (recursive) {
      if (!child.validate(sout, format, recursive)) result = false;
    }
    return result;
  }

  /// Formats the node into a string.
  /// [children] indicates any child should also be string-ified.
  /// [contained] indicates this node is part of another node.
  /// [last] indicates this is the last node of the parent.
  void toBuffer(StringBuffer sout,
      {String indent: "",
      bool children: false,
      bool contained: false,
      bool last: true,
      IFormatter format: null}) {
    if (contained) {
      if (last)
        sout.write(StringParts.Last);
      else
        sout.write(StringParts.Child);
    }

    sout.write("BranchNode: ");
    sout.write(boundary.toString(format: format));

    if (children) {
      sout.write(StringParts.Sep);
      sout.write(indent);
      _ne.toBuffer(sout,
          indent: indent + StringParts.Bar,
          children: true,
          contained: true,
          last: false,
          format: format);

      sout.write(StringParts.Sep);
      sout.write(indent);
      _nw.toBuffer(sout,
          indent: indent + StringParts.Bar,
          children: true,
          contained: true,
          last: false,
          format: format);

      sout.write(StringParts.Sep);
      sout.write(indent);
      _se.toBuffer(sout,
          indent: indent + StringParts.Bar,
          children: true,
          contained: true,
          last: false,
          format: format);

      sout.write(StringParts.Sep);
      sout.write(indent);
      _sw.toBuffer(sout,
          indent: indent + StringParts.Space,
          children: true,
          contained: true,
          last: true,
          format: format);
    }
  }
}
