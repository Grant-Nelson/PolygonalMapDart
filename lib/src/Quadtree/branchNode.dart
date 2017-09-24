part of PolygonalMapDart.Quadtree;

/// The branch node is a quad-tree branching node with four children nodes.
class BranchNode extends BaseNode {
  /// Determine if the given node is an instance of the branch node.
  /// Returns true if the instance is the branch node, false otherwise.
  static bool IsInstance(INode node) => node is BranchNode;

  /// The north-east child node.
  INode _ne;

  /// The north-west child node.
  INode _nw;

  /// The south-east child node.
  INode _se;

  /// The south-west child node.
  INode _sw;

  /// Creates a new branch node.
  BranchNode() {
    this._ne = EmptyNode.getInstance();
    this._nw = EmptyNode.getInstance();
    this._se = EmptyNode.getInstance();
    this._sw = EmptyNode.getInstance();
  }

  /// Adds an edge to this node and/or children nodes.
  /// Returns the node that should be the new root of the subtree that was
  /// defined by this node.
  @Override
  INode insertEdge(EdgeNode edge) {
    bool changed = false;
    if (this.overlaps(edge)) {
      for (Quadrant quad in Quadrant.values()) {
        INode node = this.child(quad);
        INode newChild;
        if (EmptyNode.IsInstance(node)) {
          newChild = EmptyNode.getInstance().addEdge(this.childX(quad), this.childY(quad), this.width / 2, edge);
        } else
          newChild = (node as BaseNode).insertEdge(edge);
        if (this.setChild(quad, newChild)) {
          changed = true;
        }
      }
    }

    if (changed)
      return this.reduce();
    else
      return this;
  }

  /// Adds a point to this node.
  /// Returns the node that should be the new root of the subtree that was
  /// defined by this node.
  @Override
  INode insertPoint(PointNode point) {
    Quadrant quad = this.childQuad(point.x(), point.y());
    INode node = this.child(quad);
    if (EmptyNode.IsInstance(node)) {
      INode child = EmptyNode.getInstance().addPoint(this.childX(quad), this.childY(quad), width() / 2, point);
      if (this.setChild(quad, child)) return this.reduce();
    } else {
      INode child = (node as BaseNode).insertPoint(point);
      if (this.setChild(quad, child)) return this.reduce();
    }
    return this;
  }

  /// Removes a edge from the tree at this node.
  /// [trimTree] indicates if the end points of the edge should be
  /// removed if no other edges begins or ends at that point.
  /// Returns the node that should be the new root of the subtree that was
  /// defined by this node.
  @Override
  INode removeEdge(EdgeNode edge, bool trimTree) {
    bool changed = false;
    if (this.overlaps(edge)) {
      for (Quadrant quad in Quadrant.values()) {
        INode node = this.child(quad);
        if (!EmptyNode.IsInstance(node)) {
          if (this.setChild(quad, (node as BaseNode).removeEdge(edge, trimTree))) {
            changed = true;
            // Even if child changes don't skip others.
          }
        }
      }
    }

    if (changed)
      return this.reduce();
    else
      return this;
  }

  /// This handles the first found intersecting edge.
  @Override
  IntersectionResult findFirstIntersection(IEdge edge, IEdgeHandler hndl) {
    if (this.overlaps(edge)) {
      IntersectionResult result;
      result = this._ne.findFirstIntersection(edge, hndl);
      if (result != null) return result;
      result = this._nw.findFirstIntersection(edge, hndl);
      if (result != null) return result;
      result = this._se.findFirstIntersection(edge, hndl);
      if (result != null) return result;
      result = this._sw.findFirstIntersection(edge, hndl);
      if (result != null) return result;
    }
    return null;
  }

  /// This handles all the intersections.
  @Override
  bool findAllIntersections(IEdge edge, IEdgeHandler hndl, IntersectionSet intersections) {
    bool result = false;
    if (this.overlaps(edge)) {
      if (this._ne.findAllIntersections(edge, hndl, intersections)) result = true;
      if (this._nw.findAllIntersections(edge, hndl, intersections)) result = true;
      if (this._se.findAllIntersections(edge, hndl, intersections)) result = true;
      if (this._sw.findAllIntersections(edge, hndl, intersections)) result = true;
    }
    return result;
  }

  /// Gets the north-east child node.
  INode get ne => this._ne;

  /// Gets the north-west child node.
  INode get nw => this._nw;

  /// Gets the south-east child node.
  INode get se => this._se;

  /// Gets the south-west child node.
  INode get sw => this._sw;

  /// Handles each point node reachable from this node.
  /// Returns true if all points were run, false if stopped.
  @Override
  bool foreach(IPointHandler handle) =>
      this._ne.foreach(handle) && this._nw.foreach(handle) && this._se.foreach(handle) && this._sw.foreach(handle);

  /// Handles each point node reachable from this node in the boundary.
  /// Returns true if all points in the boundary were run, false if stopped.
  @Override
  bool foreach(IPointHandler handle, IBoundary bounds) {
    if (this.overlaps(bounds)) {
      return this._ne.foreach(handle, bounds) &&
          this._nw.foreach(handle, bounds) &&
          this._se.foreach(handle, bounds) &&
          this._sw.foreach(handle, bounds);
    }
    return true;
  }

  /// Handles each edge node reachable from this node.
  /// Returns true if all edges were run, false if stopped.
  @Override
  bool foreach(IEdgeHandler handle) {
    return this._ne.foreach(handle) && this._nw.foreach(handle) && this._se.foreach(handle) && this._sw.foreach(handle);
  }

  /// Handles each edge node reachable from this node in the boundary.
  /// [exclusive] indicates that only edge which have both end points
  /// inside the region are collected, otherwise any edge which
  /// exists even partially in the region are collected.
  /// Returns true if all edges in the boundary were run, false if stopped.
  @Override
  bool foreach(IEdgeHandler handle, IBoundary bounds, bool exclusive) {
    if (this.overlaps(bounds)) {
      return this._ne.foreach(handle, bounds, exclusive) &&
          this._nw.foreach(handle, bounds, exclusive) &&
          this._se.foreach(handle, bounds, exclusive) &&
          this._sw.foreach(handle, bounds, exclusive);
    }
    return true;
  }

  /// Handles each node reachable from this node.
  /// Returns true if all nodes were run, false if stopped.
  @Override
  bool foreach(INodeHandler handle) =>
      handle.handle(this) &&
      this._ne.foreach(handle) &&
      this._nw.foreach(handle) &&
      this._se.foreach(handle) &&
      this._sw.foreach(handle);

  /// Handles each node reachable from this node in the boundary.
  /// Returns true if all nodes in the boundary were run,
  /// false if stopped.
  @Override
  bool foreach(INodeHandler handle, IBoundary bounds) {
    if (this.overlaps(bounds)) {
      return handle.handle(this) &&
          this._ne.foreach(handle, bounds) &&
          this._nw.foreach(handle, bounds) &&
          this._se.foreach(handle, bounds) &&
          this._sw.foreach(handle, bounds);
    }
    return true;
  }

  /// Determines if the node has any point nodes inside it.
  /// Returns true if this node has any points in it, false otherwise.
  ///
  /// The only way this branch hasn't been reduced is
  /// because there is at least two points in it.
  @Override
  bool get hasPoints => true;

  /// Determines if the node has any edge nodes inside it.
  /// Returns true if this edge has any edges in it, false otherwise.
  @Override
  bool get hasEdges => this._ne.hasEdges && this._nw.hasEdges && this._se.hasEdges && this._sw.hasEdges;

  /// Gets the first edge to the left of the given point.
  @Override
  void firstLeftEdge(FirstLeftEdgeArgs args) {
    if ((args.queryPoint().y() <= this.ymax()) && (args.queryPoint().y() >= this.ymin())) {
      Quadrant quad = this.childQuad(args.queryPoint().x(), args.queryPoint().y());
      switch (quad) {
        case NorthEast:
          this._ne.firstLeftEdge(args);
          if (args.found()) {
            // If no edges in the NW child could have a larger right value, skip.
            if (args.rightValue() > (this.xmin() + width() / 2)) break;
          }
          this._nw.firstLeftEdge(args);
          break;

        case NorthWest:
          this._nw.firstLeftEdge(args);
          break;

        case SouthEast:
          this._se.firstLeftEdge(args);
          if (args.found()) {
            // If no edges in the SW child could have a larger right value, skip.
            if (args.rightValue() > (this.xmin() + width() / 2)) break;
          }
          this._sw.firstLeftEdge(args);
          break;

        case SouthWest:
          this._sw.firstLeftEdge(args);
          break;
      }
    }
  }

  /// Handles all the edges to the left of the given point.
  /// Returns true if all the edges were processed,
  /// false if the handle stopped early.
  @Override
  bool foreachLeftEdge(IPoint point, IEdgeHandler hndl) {
    bool result = true;
    if ((point.y() <= this.ymax()) && (point.y() >= this.ymin())) {
      Quadrant quad = this.childQuad(point.x(), point.y());
      switch (quad) {
        case NorthEast:
          result = this._ne.foreachLeftEdge(point, hndl);
          if (!result) break;
          result = this._nw.foreachLeftEdge(point, hndl);
          break;

        case NorthWest:
          result = this._nw.foreachLeftEdge(point, hndl);
          break;

        case SouthEast:
          result = this._se.foreachLeftEdge(point, hndl);
          if (!result) break;
          result = this._sw.foreachLeftEdge(point, hndl);
          break;

        case SouthWest:
          result = this._sw.foreachLeftEdge(point, hndl);
          break;
      }
    }
    return result;
  }

  /// Gets the quadrant of the child in the direction of the given point.
  /// This doesn't check that the point is actually contained by the child indicated,
  /// only the child in the direction of the point.
  Quadrant childQuad(int x, int y) {
    int half = this.width() / 2;
    bool south = (y < (this.ymin() + half));
    bool west = (x < (this.xmin() + half));
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
  Quadrant childNodeQuad(INode node) {
    if (this._ne == node)
      return Quadrant.NorthEast;
    else if (this._nw == node)
      return Quadrant.NorthWest;
    else if (this._se == node)
      return Quadrant.SouthEast;
    else
      /*  this._sw == node */
      return Quadrant.SouthWest;
  }

  /// Gets the minimum x location of the child of the given quadrant.
  int childX(Quadrant quad) {
    switch (quad) {
      case NorthEast:
      case SouthEast:
        return this.xmin() + this.width() / 2;
      case NorthWest:
      case SouthWest:
        return this.xmin();
      default:
        return 0;
    }
  }

  /// Gets the minimum y location of the child of the given quadrant.
  int childY(Quadrant quad) {
    switch (quad) {
      case NorthEast:
      case NorthWest:
        return this.ymin() + this.width() / 2;
      case SouthEast:
      case SouthWest:
        return this.ymin();
      default:
        return 0;
    }
  }

  /// Gets the child at a given quadrant.
  INode child(Quadrant childQuad) {
    switch (childQuad) {
      case NorthEast:
        return this._ne;
      case NorthWest:
        return this._nw;
      case SouthEast:
        return this._se;
      case SouthWest:
        return this._sw;
      default:
        return null;
    }
  }

  /// This sets the child at a given quadrant.
  /// Returns true if the child was changed, false if there was not change.
  bool setChild(Quadrant childQuad, INode node) {
    assert(node != this);
    switch (childQuad) {
      case NorthEast:
        if (this._ne == node) return false;
        this._ne = node;
        break;

      case NorthWest:
        if (this._nw == node) return false;
        this._nw = node;
        break;

      case SouthEast:
        if (this._se == node) return false;
        this._se = node;
        break;

      case SouthWest:
        if (this._sw == node) return false;
        this._sw = node;
        break;

      default:
        return false;
    }
    if (node is! EmptyNode) {
      (node as BaseNode).setParent(this);
    }
    return true;
  }

  /// Returns the first point within the given boundary in this node.
  /// The given [boundary] is the boundary to search within,
  /// or null for no boundary.
  /// Returns the first point node in the given boundary,
  /// or null if none was found.
  PointNode findFirstPoint(IBoundary boundary, IPointHandler handle) {
    if ((boundary == null) || this.overlaps(boundary)) {
      for (Quadrant quad in Quadrant.values()) {
        INode node = this.child(quad);
        if (node is PointNode) {
          if ((boundary == null) || boundary.contains(node)) {
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
    if ((boundary == null) || this.overlaps(boundary)) {
      for (Quadrant quad in Quadrant.values()) {
        INode node = this.child(quad);
        if (node is PointNode) {
          if ((boundary == null) || boundary.contains(node)) {
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
  PointNode findNextPoint(INode curNode, IBoundary boundary, IPointHandler handle) {
    List<Quadrant> others = null;
    switch (this.childNodeQuad(curNode)) {
      case NorthWest:
        others = [Quadrant.NorthEast, Quadrant.SouthWest, Quadrant.SouthEast];
        break;
      case NorthEast:
        others = [Quadrant.SouthWest, Quadrant.SouthEast];
        break;
      case SouthWest:
        others = [Quadrant.SouthEast];
        break;
      case SouthEast:
        others = [];
        break;
      default:
        return null;
    }

    for (Quadrant quad in others) {
      INode node = this.child(quad);
      if (node is PointNode) {
        if ((boundary == null) || boundary.contains(node)) {
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

    if (this.parent == null)
      return null;
    else
      return this.parent.findNextPoint(this, boundary, handle);
  }

  /// Returns the previous point in this node after the given child.
  /// The [curNode] is the child node to find the next from.
  /// Returns the previous point node in the given region,
  /// or null if none was found.
  PointNode findPreviousPoint(INode curNode, IBoundary boundary, IPointHandler handle) {
    List<Quadrant> others = null;
    switch (this.childNodeQuad(curNode)) {
      case NorthWest:
        others = [];
        break;
      case NorthEast:
        others = [Quadrant.NorthWest];
        break;
      case SouthWest:
        others = [Quadrant.NorthWest, Quadrant.NorthEast];
        break;
      case SouthEast:
        others = [Quadrant.NorthWest, Quadrant.NorthEast, Quadrant.SouthWest];
        break;
      default:
        return null;
    }

    for (Quadrant quad in others) {
      INode node = this.child(quad);
      if (node is PointNode) {
        if ((boundary == null) || boundary.contains(node)) {
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

    if (this.parent == null)
      return null;
    else
      return this.parent.findPreviousPoint(this, boundary, handle);
  }

  /// Determine if this node can be reduced.
  /// Returns this grey node if not reduced,
  /// or the reduced node to replace this node with.
  INode reduce() {
    // A branch node can be reduced any time the all of the children
    // contain no points or only one point.
    int pointCount = this.pointWeight(this._ne) +
        this.pointWeight(this._nw) +
        this.pointWeight(this._se) +
        this.pointWeight(this._sw);
    if (pointCount == 0) {
      // Find a dark node and populate it with the other dark nodes' lines.
      PassNode pass = null;
      for (Quadrant quad in Quadrant.values) {
        INode node = this.child(quad);
        if (node is PassNode) {
          if (pass == null) {
            pass = node;
            pass.setLocation(this.xmin, this.ymin, this.width);
            pass.setParent(null);
            this.setChild(quad, EmptyNode.instance);
          } else {
            // Copy all edges from this pass node into the already found pass node.
            pass.passEdges().addAll(node.passEdges());
          }
        }
      }

      // Return either the found pass node or the empty node.
      if (pass != null)
        return pass;
      else
        return EmptyNode.getInstance();
    } else if (pointCount == 1) {
      // Find the point node in the children.
      PointNode point = null;
      for (Quadrant quad in Quadrant.values()) {
        INode node = this.child(quad);
        if (node is PointNode) {
          // Point node found, relocate and remove the node
          // from this parent node so that it isn't deleted later.
          point = node;
          point.setLocation(this.xmin(), this.ymin(), this.width());
          point.setParent(null);
          this.setChild(quad, EmptyNode.getInstance());
          break;
        }
      }
      if (point == null) return EmptyNode.getInstance();

      // Find any dark nodes and copy all lines into the black node.
      for (Quadrant quad in Quadrant.values()) {
        INode node = this.child(quad);
        if (node is PassNode) {
          // Add all passing lines to black node unless the line starts or ends
          // on the black node, since the line will already be in the start or end line lists.
          for (EdgeNode edge in node.passEdges()) {
            if (edge.startNode() == point) continue;
            if (edge.endNode() == point) continue;
            point.passEdges().add(edge);
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
  @Override
  bool validate(StringBuffer sout, IFormatter format, bool recursive) {
    bool result = true;
    if (!this.validateChild(sout, format, recursive, this._ne, "NE", true, true)) result = false;
    if (!this.validateChild(sout, format, recursive, this._nw, "NW", true, false)) result = false;
    if (!this.validateChild(sout, format, recursive, this._sw, "SW", false, false)) result = false;
    if (!this.validateChild(sout, format, recursive, this._se, "SE", false, true)) result = false;
    return result;
  }

  /// Validates the given child node.
  bool _validateChild(
      StringBuffer sout, IFormatter format, bool recursive, INode child, String name, bool north, bool east) {
    if (child == null) {
      sout.append("Error in ");
      this.toString(sout, format);
      sout.append(": The ");
      sout.append(name);
      sout.append(" child was null.\n");
      return false;
    }

    bool result = true;
    if (child is! EmptyNode) {
      BaseNode bnode = child as BaseNode;
      if (bnode.parent() != this) {
        sout.append("Error in ");
        this.toString(sout, format);
        sout.append(": The ");
        sout.append(name);
        sout.append(" child, ");
        child.toString(sout, format);
        sout.append(", parent wasn't this node, it was ");
        child.parent().toString(sout, format);
        sout.append(".\n");
        result = false;
      }

      if (this.width() / 2 != bnode.width()) {
        sout.append("Error in ");
        this.toString(sout, format);
        sout.append(": The ");
        sout.append(name);
        sout.append(" child, ");
        child.toString(sout, format);
        sout.append(", was ");
        sout.append(bnode.width());
        sout.append(" wide, but should have been ");
        sout.append(this.width() / 2);
        sout.append(".\n");
        result = false;
      }

      int left = east ? (this.xmin() + bnode.width()) : this.xmin();
      int top = north ? (this.ymin() + bnode.width()) : this.ymin();
      if ((left != bnode.xmin()) || (top != bnode.ymin())) {
        sout.append("Error in ");
        this.toString(sout, format);
        sout.append(": The ");
        sout.append(name);
        sout.append(" child, ");
        child.toString(sout, format);
        sout.append(", was at [");
        sout.append(bnode.xmin());
        sout.append(", ");
        sout.append(bnode.ymin());
        sout.append("], but should have been [");
        sout.append(left);
        sout.append(", ");
        sout.append(top);
        sout.append("].\n");
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
  @Override
  void toString(StringBuffer sout, String indent, bool children, bool contained, bool last, IFormatter format) {
    if (contained) {
      if (last)
        sout.append(StringParts.Last);
      else
        sout.append(StringParts.Child);
    }

    sout.append("BranchNode: ");
    sout.append(this.boundary().toString(format));

    if (children) {
      sout.append(StringParts.Sep);
      sout.append(indent);
      this._ne.toString(sout, indent + StringParts.Bar, true, true, false, format);

      sout.append(StringParts.Sep);
      sout.append(indent);
      this._nw.toString(sout, indent + StringParts.Bar, true, true, false, format);

      sout.append(StringParts.Sep);
      sout.append(indent);
      this._se.toString(sout, indent + StringParts.Bar, true, true, false, format);

      sout.append(StringParts.Sep);
      sout.append(indent);
      this._sw.toString(sout, indent + StringParts.Space, true, true, true, format);
    }
  }
}
