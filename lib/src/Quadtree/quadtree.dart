library PolygonalMapDart.Quadtree;

part 'EdgeNode.dart';
part 'EdgeNodeSet.dart';
part 'EdgePointIgnorer.dart';
part 'EdgeSet.dart';
part 'EmptyNode.dart';
part 'FirstLeftEdgeArgs.dart';
part 'IBoundary.dart';
part 'IEdge.dart';
part 'IEdgeHandler.dart';
part 'IFormatter.dart';
part 'INode.dart';
part 'INodeHandler.dart';
part 'InsertEdgeResult.dart';
part 'InsertPointResult.dart';
part 'IntersectionLocation.dart';
part 'IntersectionResult.dart';
part 'IntersectionSet.dart';
part 'IntersectionType.dart';
part 'IPoint.dart';
part 'IPointHandler.dart';
part 'NearestEdgeArgs.dart';
part 'NeighborEdgeIgnorer.dart';
part 'NodeStack.dart';
part 'PassNode.dart';
part 'Point.dart';
part 'PointCollectorHandle.dart';
part 'PointNode.dart';
part 'PointNodeSet.dart';
part 'PointNodeVector.dart';
part 'PointOnEdgeResult.dart';
part 'PointSet.dart';
part 'Quadrant.dart';
part 'Side.dart';
part 'StringParts.dart';

/// ValidateHandler is an assistant method to the validate method.
class ValidateHandler implements IPointHandler {
  Boundary bounds = null;
  int pointCount = 0;
  int edgeCount = 0;

  @Override
  bool handle(PointNode point) {
    this.bounds = Boundary.expand(this.bounds, point);
    this.pointCount++;
    this.edgeCount += point.startEdges().size();
    return true;
  }
}

/// A polygon mapping quad-tree for storing edges and
/// points in a two dimensional logarithmic data structure.
class QuadTree {
  /// The root node of the quad-tree.
  INode _root;

  /// The tight bounding box of all the data.
  Boundary _boundary;

  /// The number of points in the tree.
  int _pointCount;

  /// The number of edges in the tree.
  int _edgeCount;

  /// Creates a new quad-tree.
  QuadTree() {
    this._root = EmptyNode.getInstance();
    this._boundary = new Boundary(0, 0, 0, 0);
    this._pointCount = 0;
    this._edgeCount = 0;
  }

  /// The root node of the quad-tree.
  INode get root => this._root;

  /// Gets the tight bounding box of all the data.
  Boundary get boundary => this._boundary;

  /// Gets the number of points in the tree.
  int get pointCount => this._pointCount;

  /// Gets the number of edges in the tree.
  int get edgeCount => this._edgeCount;

  /// Clears all the points, edges, and nodes from the quad-tree.
  /// Does not clear the additional data.
  void clear() {
    this._root = EmptyNode.getInstance();
    this._boundary = new Boundary(0, 0, 0, 0);
    this._pointCount = 0;
    this._edgeCount = 0;
  }

  /// Finds a point node from this node for the given point.
  PointNode find(IPoint point) => this.find(point.x, point.y);

  /// Finds a point node from this node for the given point.
  PointNode find(int x, int y) {
    if (!this._boundary.contains(x, y)) return null;
    INode node = this._root;
    while (true) {
      if (node is PointNode) {
        if (Point.equals(node, x, y))
          return node;
        else
          return null;
      } else if (node is BranchNode) {
        Quadrant quad = node.childQuad(x, y);
        node = node.child(quad);
      } else
        return null; // Pass nodes and empty nodes have no points.
    }
  }

  /// This will locate the smallest non-empty node containing the given point.
  /// Returns this is the smallest non-empty node containing the given point.
  /// If no non-empty node could be found from this node then null is returned.
  BaseNode nodeContainingPoint(IPoint point) => this.nodeContainingPoint(point.x, point.y);

  /// This will locate the smallest non-empty node containing the given point.
  /// Returns this is the smallest non-empty node containing the given point.
  /// If no non-empty node could be found from this node then null is returned.
  BaseNode nodeContainingPoint(int x, int y) {
    if (!this._boundary.contains(x, y)) return null;
    INode node = this._root;
    while (true) {
      if (node is BranchNode) {
        Quadrant quad = node.childQuad(x, y);
        node = node.child(quad);
        if (node is EmptyNode) return node;
      } else if (node is EmptyNode)
        return null;
      else
        return node; // The pass or point node.
    }
  }

  /// Finds an edge node from this node for the given edge.
  /// Set [undirected] to true if the opposite edge may also be returned, false if not.
  EdgeNode find(IEdge edge, bool undirected) {
    PointNode node = this.find(edge.x1, edge.y1);
    if (node == null) return null;
    EdgeNode result = node.findEdgeTo(edge.x2, edge.y2);
    if ((result == null) && undirected) {
      result = node.findEdgeFrom(edge.x2, edge.y2);
    }
    return result;
  }

  /// Finds the nearest point to the given point.
  /// [queryPoint] is the query point to find a point nearest to.
  /// [cutoffDist2] is the maximum allowable distance squared to the nearest point.
  /// [handle] is the handle to filter acceptable points with, or null to not filter.
  PointNode findNearestPoint(IPoint queryPoint, {double cutoffDist2: Double.MAX_VALUE, IPointHandler handle: null}) {
    PointNode result = null;
    NodeStack stack = new NodeStack(this._root);
    while (!stack.isEmpty()) {
      INode node = stack.pop();
      if (node is PointNode) {
        double dist2 = Point.distance2(queryPoint, node);
        if (dist2 < cutoffDist2) {
          if ((handle == null) || handle.handle(node)) {
            result = node;
            cutoffDist2 = dist2;
          }
        }
      } else if (node is BranchNode) {
        double dist2 = node.distance2(queryPoint);
        if (dist2 <= cutoffDist2) stack.pushChildren(node);
      }
      // else, Pass nodes and empty nodes have no points.
    }
    return result;
  }

  /// Finds the nearest point to the given edge.
  /// [queryEdge] is the query edge to find a point nearest to.
  /// [cutoffDist2] is the maximum allowable distance squared to the nearest point.
  /// [handle] is the handle to filter acceptable points with, or null to not filter.
  PointNode findNearestPoint(IEdge queryEdge, {double cutoffDist2: Double.MAX_VALUE, IPointHandler handle: null}) {
    PointNode result = null;
    NodeStack stack = new NodeStack(this._root);
    while (!stack.isEmpty()) {
      INode node = stack.pop();
      if (node is PointNode) {
        double dist2 = Edge.distance2(queryEdge, node);
        if (dist2 < cutoffDist2) {
          if ((handle == null) || handle.handle(node)) {
            result = node;
            cutoffDist2 = dist2;
          }
        }
      } else if (node is BranchNode) {
        int width = node.width;
        int x = node.xmin + width / 2;
        int y = node.ymin + width / 2;
        double diagDist2 = 2.0 * width * width;
        double dist2 = Edge.distance2(queryEdge, x, y) - diagDist2;
        if (dist2 <= cutoffDist2) stack.pushChildren(node);
      }
      // else, Pass nodes and empty nodes have no points.
    }
    return result;
  }

  /// Finds the point close to the given edge.
  /// [queryEdge] is the query edge to find a close point to.
  /// [handle] is the handle to filter acceptable points with, or null to not filter.
  PointNode findClosePoint(IEdge queryEdge, IPointHandler handle) {
    NodeStack stack = new NodeStack(this._root);
    while (!stack.isEmpty()) {
      INode node = stack.pop();
      if (node is PointNode) {
        PointOnEdgeResult pnt = Edge.pointOnEdge(queryEdge, node);
        if (pnt.onEdge) {
          if ((handle == null) || handle.handle(node)) {
            return node;
          }
        }
      } else if (node is BranchNode) {
        int width = node.width;
        int x = node.xmin + width / 2;
        int y = node.ymin + width / 2;
        double diagDist2 = 2.0 * width * width;
        double dist2 = Edge.distance2(queryEdge, x, y) - diagDist2;
        if (dist2 <= 1.415) stack.pushChildren(node);
      }
      // else, Pass nodes and empty nodes have no points.
    }
    return null;
  }

  /// Returns the edge nearest to the given query point, which has been matched
  /// by the given matcher, and is within the given cutoff distance.
  /// [point] is the point to find the nearest edge to.
  /// [cutoffDist2] is the maximum distance squared edges may be
  /// away from the given point to be an eligible result.
  /// [handler] is the matcher to filter eligible edges, if null all edges are accepted.
  EdgeNode findNearestEdge(IPoint point, {double cutoffDist2: Double.MAX_VALUE, IEdgeHandler handler: null}) {
    NearestEdgeArgs args = new NearestEdgeArgs(point, cutoffDist2, handler);
    args.run(this._root);
    return args.result();
  }

  /// Returns the first left edge to the given query point.
  /// [point] is the point to find the first left edge from.
  /// [handle] is the matcher to filter eligible edges. If null all edges are accepted.
  EdgeNode firstLeftEdge(IPoint point, {IEdgeHandler handle: null}) {
    FirstLeftEdgeArgs args = new FirstLeftEdgeArgs(point, handle);
    this._root.firstLeftEdge(args);
    return args.result();
  }

  /// Handle all the edges to the left of the given point.
  /// [point] is the point to find the left edges from.
  /// [handle] is the handle to process all the edges with.
  bool foreachLeftEdge(IPoint point, IEdgeHandler handle) => this._root.foreachLeftEdge(point, handle);

  /// Gets the first point in the tree.
  /// [boundary] is the boundary of the tree to get the point from, or null for whole tree.
  /// [handle] is the point handler to filter points with, or null for no filter.
  PointNode firstPoint(IBoundary boundary, IPointHandler handle) {
    PointNode result = null;
    NodeStack stack = new NodeStack(this._root);
    while (!stack.isEmpty()) {
      INode node = stack.pop();
      if (node is PointNode) {
        if ((boundary == null) || boundary.contains(node)) return node;
      } else if (node is BranchNode) {
        if ((boundary == null) || boundary.overlaps(node)) stack.pushChildren(node);
      }
      // else, Pass nodes and empty nodes have no points.
    }
    return result;
  }

  /// Gets the last point in the tree.
  /// [boundary] is the boundary of the tree to get the point from, or null for whole tree.
  /// [handle] is the point handler to filter points with, or null for no filter.
  PointNode lastPoint(IBoundary boundary, IPointHandler handle) {
    PointNode result = null;
    NodeStack stack = new NodeStack(this._root);
    while (!stack.isEmpty()) {
      INode node = stack.pop();
      if (node is PointNode) {
        if ((boundary == null) || boundary.contains(node)) return node;
      } else if (node is BranchNode) {
        if ((boundary == null) || boundary.overlaps(node)) stack.pushReverseChildren(node);
      }
      // else, Pass nodes and empty nodes have no points.
    }
    return result;
  }

  /// Handles each point node.
  bool foreach(IPointHandler handle) => this._root.foreach(handle);

  /// Handles each point node in the boundary.
  bool foreach(IPointHandler handle, IBoundary bounds) => this._root.foreach(handle, bounds);

  /// Handles each edge node.
  bool foreach(IEdgeHandler handle) => this._root.foreach(handle);

  /// Handles each edge node in the boundary.
  /// [handle] is the handler to run on each edge in the boundary.
  /// [bounds] is the boundary containing the edges to handle.
  /// [exclusive] indicates that only edge which have both end points
  /// inside the region are collected, otherwise any edge which
  /// exists even partially in the region are collected.
  /// Returns true if all edges in the boundary were run, false if stopped.
  bool foreach(IEdgeHandler handle, IBoundary bounds, bool exclusive) => this._root.foreach(handle, bounds, exclusive);

  /// Handles each node.
  /// Returns true if all nodes were run, false if stopped.
  bool foreach(INodeHandler handle) => this._root.foreach(handle);

  /// Handles each node in the boundary.
  /// [handle] is the handler to run on each node in the boundary.
  /// [bounds] is the boundary containing the nodes to handle.
  /// Returns true if all nodes in the boundary were run, false if stopped.
  bool foreach(INodeHandler handle, IBoundary bounds) => this._root.foreach(handle, bounds);

  /// Calls given handle for the all the near points to the given point.
  /// [handle] is the handle to handle all near points with.
  /// [queryPoint] is the query point to find the points near to.
  /// [cutoffDist2] is the maximum allowable distance squared to the near points.
  /// Returns true if all points handled, false if the handled returned false and stopped early.
  bool forNearPoints(IPointHandler handle, IPoint queryPoint, double cutoffDist2) {
    NodeStack stack = new NodeStack(this._root);
    while (!stack.isEmpty()) {
      INode node = stack.pop();
      if (node is PointNode) {
        double dist2 = Point.distance2(queryPoint, node);
        if (dist2 < cutoffDist2) {
          if (!handle.handle(node)) return false;
        }
      } else if (node is BranchNode) {
        int width = node.width;
        int x = node.xmin + width / 2;
        int y = node.ymin + width / 2;
        double diagDist2 = 2.0 * width * width;
        double dist2 = Point.distance2(queryPoint, x, y) - diagDist2;
        if (dist2 <= cutoffDist2) stack.pushChildren(node);
      }
      // else, Pass nodes and empty nodes have no points.
    }
    return true;
  }

  /// Finds the near points to the given edge.
  /// [handle] is the callback to handle the near points.
  /// [queryEdge] is the query edge to find all points near to.
  /// [cutoffDist2] is the maximum allowable distance squared to the near points.
  /// Returns true if all points handled,
  /// false if the handled returned false and stopped early.
  bool forNearPoints(IPointHandler handle, IEdge queryEdge, double cutoffDist2) {
    NodeStack stack = new NodeStack(this._root);
    while (!stack.isEmpty()) {
      INode node = stack.pop();
      if (node is PointNode) {
        double dist2 = Edge.distance2(queryEdge, node);
        if (dist2 < cutoffDist2) {
          if (!handle.handle(node)) return false;
        }
      } else if (node is BranchNode) {
        int width = node.width();
        int x = node.xmin() + width / 2;
        int y = node.ymin() + width / 2;
        double diagDist2 = 2.0 * width * width;
        double dist2 = Edge.distance2(queryEdge, x, y) - diagDist2;
        if (dist2 <= cutoffDist2) stack.pushChildren(node);
      }
      // else, Pass nodes and empty nodes have no points.
    }
    return true;
  }

  /// Finds the close points to the given edge.
  /// [handle] is the callback to handle the close points.
  /// [queryEdge] is the query edge to find all points close to.
  /// Returns true if all points handled,
  /// false if the handled returned false and stopped early.
  bool forClosePoints(IPointHandler handle, IEdge queryEdge) {
    NodeStack stack = new NodeStack(this._root);
    while (!stack.isEmpty()) {
      INode node = stack.pop();
      if (node is PointNode) {
        PointOnEdgeResult pnt = Edge.pointOnEdge(queryEdge, node);
        if (pnt.onEdge) {
          if (!handle.handle(node)) return false;
        }
      } else if (node is BranchNode) {
        int width = node.width();
        int x = node.xmin() + width / 2;
        int y = node.ymin() + width / 2;
        double diagDist2 = 2.0 * width * width;
        double dist2 = Edge.distance2(queryEdge, x, y) - diagDist2;
        if (dist2 <= 1.415) stack.pushChildren(node);
      }
      // else, Pass nodes and empty nodes have no points.
    }
    return true;
  }

  /// Calls given handle for all the edges near to the given query point.
  /// [handler] is the handle to handle all near edges with.
  /// [queryPoint] is the point to find the near edges to.
  /// [cutoffDist2] is the maximum distance for near edges.
  /// Returns true if all edges handled,
  /// false if the handled returned false and stopped early.
  bool forNearEdges(IEdgeHandler handler, IPoint queryPoint, double cutoffDist2) {
    NodeStack stack = new NodeStack();
    stack.push(this._root);
    while (!stack.isEmpty()) {
      INode node = stack.pop();
      if (node is PointNode) {
        for (EdgeNode edge in node.startEdges) {
          if (Edge.distance2(edge, queryPoint) <= cutoffDist2) {
            if (!handler.handle(edge)) return false;
          }
        }
        for (EdgeNode edge in node.endEdges) {
          if (Edge.distance2(edge, queryPoint) <= cutoffDist2) {
            if (!handler.handle(edge)) return false;
          }
        }
        for (EdgeNode edge in node.passEdges) {
          if (Edge.distance2(edge, queryPoint) <= cutoffDist2) {
            if (!handler.handle(edge)) return false;
          }
        }
      } else if (node is PassNode) {
        for (EdgeNode edge in node.passEdges) {
          if (Edge.distance2(edge, queryPoint) <= cutoffDist2) {
            if (!handler.handle(edge)) return false;
          }
        }
      } else if (node is BranchNode) {
        int width = node.width;
        int x = node.xmin + width / 2;
        int y = node.ymin + width / 2;
        double diagDist2 = 2.0 * width * width;
        double dist2 = Point.distance2(queryPoint, x, y) - diagDist2;
        if (dist2 <= cutoffDist2) stack.pushChildren(node);
      }
      // else, empty nodes have no edges.
    }
    return true;
  }

  /// Calls given handle for all the edges close to the given query point.
  /// [handler] is the handle to handle all close edges with.
  /// [queryPoint] is the point to find the close edges to.
  /// Returns true if all edges handled,
  /// false if the handled returned false and stopped early.
  bool forCloseEdges(IEdgeHandler handler, IPoint queryPoint) {
    NodeStack stack = new NodeStack();
    stack.push(this._root);
    while (!stack.isEmpty()) {
      INode node = stack.pop();
      if (node is PointNode) {
        for (EdgeNode edge in node.startEdges) {
          PointOnEdgeResult pnt = Edge.pointOnEdge(edge, queryPoint);
          if (pnt.onEdge) {
            if (!handler.handle(edge)) return false;
          }
        }
        for (EdgeNode edge in node.endEdges) {
          PointOnEdgeResult pnt = Edge.pointOnEdge(edge, queryPoint);
          if (pnt.onEdge) {
            if (!handler.handle(edge)) return false;
          }
        }
        for (EdgeNode edge in node.passEdges) {
          PointOnEdgeResult pnt = Edge.pointOnEdge(edge, queryPoint);
          if (pnt.onEdge) {
            if (!handler.handle(edge)) return false;
          }
        }
      } else if (node is PassNode) {
        for (EdgeNode edge in node.passEdges) {
          PointOnEdgeResult pnt = Edge.pointOnEdge(edge, queryPoint);
          if (pnt.onEdge) {
            if (!handler.handle(edge)) return false;
          }
        }
      } else if (node is BranchNode) {
        int width = node.width;
        int x = node.xmin + width / 2;
        int y = node.ymin + width / 2;
        double diagDist2 = 2.0 * width * width;
        double dist2 = Point.distance2(queryPoint, x, y) - diagDist2;
        if (dist2 <= 1.415) stack.pushChildren(node);
      }
      // else, empty nodes have no edges.
    }
    return true;
  }

  /// Finds the first intersection between the given line and lines in the tree which
  /// match the given handler. When multiple intersections exist, which intersection
  /// is discovered is not specific.
  /// [edge] is the edge to find intersections with.
  /// [hndl] is the edge handle to filter possible intersecting edges.
  /// Returns the first found intersection.
  IntersectionResult findFirstIntersection(IEdge edge, IEdgeHandler hndl) =>
      this._root.findFirstIntersection(edge, hndl);

  /// This handles all the intersections.
  /// [edge] is the edge to look for intersections with.
  /// [hndl] is the handler to match valid edges with.
  /// [intersections] is the set of intersections to add to.
  /// Returns true if a new intersection was found.
  bool findAllIntersections(IEdge edge, IEdgeHandler hndl, IntersectionSet intersections) {
    if (this._edgeCount > 0) {
      return (this._root as BaseNode).findAllIntersections(edge, hndl, intersections);
    }
    return false;
  }

  /// This handles all the intersections.
  /// [edge] is the edge to look for intersections with.
  /// [hndl] is the handler to match valid edges with.
  /// Returns the set of intersections to add to.
  IntersectionSet findAllIntersections(IEdge edge, IEdgeHandler hndl) {
    IntersectionSet intersections = new IntersectionSet();
    this.findAllIntersections(edge, hndl, intersections);
    return intersections;
  }

  /// This inserts an edge or finds an existing edge in the quad-tree.
  /// [edge] is the edge to insert into the tree.
  /// Returns the edge in the tree.
  EdgeNode insertEdge(IEdge edge) => this.insertEdge(edge.start(), edge.end());

  /// This inserts an edge or finds an existing edge in the quad-tree.
  /// [edge] is the edge to insert into the tree.
  /// Returns a pair containing the edge in the tree, and true if the edge is
  /// new or false if the edge already existed in the tree.
  InsertEdgeResult tryInsertEdge(IEdge edge) => this.tryInsertEdge(edge.start(), edge.end());

  /// This inserts an edge or finds an existing edge in the quad-tree.
  /// If the start and/or end point are PointNodes they must be from this
  /// tree. Using the PointNodes is significantly faster.
  /// [startPoint] is the starting point for the edge.
  /// [endPoint] is the ending point for the edge.
  /// Returns the edge in the tree.
  EdgeNode insertEdge(IPoint startPoint, IPoint endPoint) => this.tryInsertEdge(startPoint, endPoint).edge;

  /// This inserts an edge or finds an existing edge in the quad-tree.
  /// If the start and/or end point are PointNodes they must be from this
  /// tree. Using the PointNodes is significantly faster.
  /// [startPoint] is the starting point for the edge.
  /// [endPoint] is the ending point for the edge.
  /// Returns a pair containing the edge in the tree, and true if the edge is
  /// new or false if the edge already existed in the tree.
  InsertEdgeResult tryInsertEdge(IPoint startPoint, IPoint endPoint) {
    PointNode startNode, endNode;
    bool startNew, endNew;

    if ((startPoint is PointNode) && (startPoint.root == this._root)) {
      startNode = startPoint;
      startNew = false;
    } else {
      InsertPointResult pair = this.tryInsertPoint(startPoint);
      startNode = pair.point;
      startNew = pair.existed;
    }

    if ((endPoint is PointNode) && (endPoint.root == this._root)) {
      endNode = endPoint;
      endNew = false;
    } else {
      InsertPointResult pair = this.tryInsertPoint(endPoint);
      endNode = pair.point;
      endNew = pair.existed;
    }

    // Check for degenerate edges.
    if (startNode == endNode) return new InsertEdgeResult(null, false);

    // If both points already existed check if edge exists.
    if (!(startNew || endNew)) {
      EdgeNode edge = startNode.findEdgeTo(endNode);
      if (edge != null) return new InsertEdgeResult(edge, false);
    }

    // Insert new edge.
    BranchNode ancestor = startNode.commonAncestor(endNode);
    if (ancestor == null) {
      assert(this.validate());
      assert(startNode.root() == this._root);
      assert(endNode.root() == this._root);
      assert(ancestor != null);
      return null;
    }
    EdgeNode newEdge = new EdgeNode(startNode, endNode);

    INode replacement = ancestor.insertEdge(newEdge);
    this.reduceBranch(ancestor, replacement);
    this._edgeCount++;
    return new InsertEdgeResult(newEdge, true);
  }

  /// This inserts a point or finds an existing point in the quad-tree.
  /// [point] is the point to insert into the tree.
  /// Returns the point node for the point inserted into the tree, or
  /// the point node which already existed.
  PointNode insertPoint(IPoint point) => this.tryInsertPoint(point.x(), point.y()).point;

  /// This inserts a point or finds an existing point in the quad-tree.
  /// [point] is the point to insert into the tree.
  /// Returns a pair containing the point node in the tree, and true if the
  /// point is new or false if the point already existed in the tree.
  InsertPointResult tryInsertPoint(IPoint point) => this.tryInsertPoint(point.x(), point.y());

  /// This inserts a point or finds an existing point in the quad-tree.
  /// [x] is the first component of the point to insert into the tree.
  /// [y] is the second component of the point to insert into the tree.
  /// Returns the point node for the point inserted into the tree, or
  /// the point node which already existed.
  PointNode insertPoint(int x, int y) => this.tryInsertPoint(x, y).point;

  /// This inserts a point or finds an existing point in the quad-tree.
  /// [x] is the first component of the point to insert into the tree.
  /// [y] is the second component of the point to insert into the tree.
  /// Returns a pair containing the point node in the tree, and true if the
  /// point is new or false if the point already existed in the tree.
  InsertPointResult tryInsertPoint(int x, int y) {
    // Attempt to find the point first.
    PointNode point;
    BaseNode node = this.nodeContainingPoint(x, y);
    if (node != null) {
      // A node containing the point has been found.
      if (node is PointNode) {
        if (Point.equals(node, x, y)) {
          return new InsertPointResult(node, true);
        }
      }
      point = new PointNode(x, y);
      BranchNode parent = node.parent();
      if (parent != null) {
        Quadrant quad = parent.childNodeQuad(node);
        INode replacement = node.insertPoint(point);
        parent.setChild(quad, replacement);
        replacement = parent.reduce();
        this.reduceBranch(parent, replacement);
      } else {
        INode replacement = node.insertPoint(point);
        this.setRoot(replacement);
      }
    } else if (this._root is EmptyNode) {
      // Tree is empty so create a new tree.
      int initialTreeWidth = 256;
      int centerX = (x / initialTreeWidth) * initialTreeWidth;
      int centerY = (y / initialTreeWidth) * initialTreeWidth;
      if (x < 0) centerX -= (initialTreeWidth - 1);
      if (y < 0) centerY -= (initialTreeWidth - 1);
      point = new PointNode(x, y);
      this.setRoot(this._root.addPoint(centerX, centerY, initialTreeWidth, point));
    } else {
      // Point outside of tree, expand the tree.
      BaseNode root = this.expandFootprint(this._root as BaseNode, x, y);
      point = new PointNode(x, y);
      this.setRoot(root.insertPoint(point));
    }

    assert(this._root is! EmptyNode);
    this._pointCount++;
    this.expandBoundingBox(x, y);
    return new InsertPointResult(point, false);
  }

  /// This removes an edge from the tree.
  /// [edge] is the edge to remove from the tree.
  /// [trimTree] indicates if the end points of the edge should be
  /// removed if no other edge begins or ends at that point.
  void removeEdge(EdgeNode edge, bool trimTree) {
    BranchNode ancestor = edge.startNode().commonAncestor(edge.endNode());
    assert(ancestor != null);

    INode replacement = ancestor.removeEdge(edge, trimTree);
    this.reduceBranch(ancestor, replacement);
    --this._edgeCount;

    // If trimming the tree, see if the black nodes need to be deleted.
    if (trimTree) {
      if (edge.startNode().orphan()) {
        this.removePoint(edge.startNode());
      }
      if (edge.endNode().orphan()) {
        this.removePoint(edge.endNode());
      }
    }
  }

  /// This removes a point from the tree.
  /// [point] is the point to removed from the tree.
  void removePoint(PointNode point) {
    // Remove any edges on the point.
    for (EdgeNode edge in point.startEdges()) {
      this.removeEdge(edge, false);
    }
    for (EdgeNode edge in point.endEdges()) {
      this.removeEdge(edge, false);
    }

    // The point node must not have any edges beginning
    // nor ending on by the time is is removed.
    assert(point.orphan());

    // Remove the point from the tree.
    if (this._root == point) {
      // If the only thing in the tree is the point, simply replace it
      // with an empty node.
      this._root = EmptyNode.getInstance();
    } else {
      BranchNode parent = point.parent();
      INode replacement = point.replacement();
      Quadrant quad = parent.childNodeQuad(point);
      parent.setChild(quad, replacement);
      replacement = parent.reduce();
      this.reduceBranch(parent, replacement);
    }
    --this._pointCount;
    this.collapseBoundingBox(point);
  }

  /// Validates this quad-tree.
  /// Returns true if valid, false if invalid.
  bool validate() => this.validate(System.out, null);

  /// Validates this quad-tree.
  /// [sout] is the output to write errors to.
  /// [format] is the format used for printing, null to use default.
  /// Returns true if valid, false if invalid.
  bool validate(StringBuffer sout, IFormatter format) {
    bool result = true;
    ValidateHandler vHndl = new ValidateHandler();
    this.foreach(vHndl);

    if (this._pointCount != vHndl.pointCount) {
      sout.append("Error: The point count should have been ");
      sout.append(vHndl.pointCount);
      sout.append(" but it was ");
      sout.append(this._pointCount);
      sout.append(".\n");
      result = false;
    }

    if (this._edgeCount != vHndl.edgeCount) {
      sout.append("Error: The edge count should have been ");
      sout.append(vHndl.edgeCount);
      sout.append(" but it was ");
      sout.append(this._edgeCount);
      sout.append(".\n");
      result = false;
    }

    if (vHndl.bounds == null) {
      vHndl.bounds = new Boundary(0, 0, 0, 0);
    }

    if (!this._boundary.equals(vHndl.bounds)) {
      sout.append("Error: The boundary should have been ");
      sout.append(vHndl.bounds.toString());
      sout.append(" but it was ");
      sout.append(this._boundary.toString());
      sout.append(".\n");
      result = false;
    }

    if (this._root is! EmptyNode) {
      BaseNode root = this._root as BaseNode;
      if (root.parent() != null) {
        sout.append("Error: The root node's parent should be null but it is ");
        root.parent().toString(sout, format);
        sout.append(".\n");
        result = false;
      }
    }

    if (!this._root.validate(sout, format, true)) result = false;
    return result;
  }

  /// Formats the quad-tree into a string.
  /// [sout] is the output to write the formatted string to.
  /// [indent] is the indent for this quad-tree.
  /// [contained] indicates this node is part of another output.
  /// [last] indicates this is the last output of the parent.
  /// [format] is the format used for printing, null to use default.
  void toString(StringBuffer sout,
      {String indent: "", bool contained: false, bool last: true, IFormatter format: null}) {
    if (contained) {
      if (last)
        sout.append(StringParts.Last);
      else
        sout.append(StringParts.Child);
    }
    sout.append("Tree:");

    String childIndent;
    if (contained && !last)
      childIndent = indent + StringParts.Bar;
    else
      childIndent = indent + StringParts.Space;

    sout.append(StringParts.Sep);
    sout.append(indent);
    sout.append(StringParts.Child);
    sout.append("Region: ");
    sout.append(this._boundary.toString(format));

    sout.append(StringParts.Sep);
    sout.append(indent);
    sout.append(StringParts.Child);
    sout.append("Points: ");
    sout.append(this._pointCount);

    sout.append(StringParts.Sep);
    sout.append(indent);
    sout.append(StringParts.Child);
    sout.append("Edges: ");
    sout.append(this._edgeCount);

    sout.append(StringParts.Sep);
    sout.append(indent);
    this._root.toString(sout, childIndent, true, true, true, format);
  }

  /// Gets the string for this quad-tree.
  @Override
  String toString() {
    StringBuffer sout = new StringBuffer();
    this.toString(sout, null);
    return sout.toString();
  }

  /// This reduces the root to the smallest branch needed.
  /// [node] is the original node to reduce.
  /// [replacement] is the node to replace the original node with.
  void _reduceBranch(BaseNode node, INode replacement) {
    while (replacement != node) {
      BranchNode parent = node.parent();
      if (parent == null) {
        this.setRoot(replacement);
        break;
      }
      Quadrant quad = parent.childNodeQuad(node);
      parent.setChild(quad, replacement);
      node = parent;
      replacement = parent.reduce();
    }
  }

  /// This sets the root node of this tree.
  /// [node] is the node to set as the root.
  /// Returns true if root changed, false if no change.
  bool _setRoot(INode node) {
    assert(node != null);
    if (this._root == node) return false;
    this._root = node;
    if (this._root is! EmptyNode) {
      (this._root as BaseNode).setParent(null);
    }
    return true;
  }

  /// This expands the foot print of the tree to include the given point.
  /// [root] is the original root to expand.
  /// [x] is the first component of the point.
  /// [y] is the second component of the point.
  /// Returns the new expanded root.
  BaseNode _expandFootprint(BaseNode root, int x, int y) {
    while (!root.contains(x, y)) {
      int xmin = root.xmin();
      int ymin = root.ymin();
      int width = root.width();
      int half = width / 2;
      int oldCenterX = xmin + half;
      int oldCenterY = ymin + half;

      int newXMin = xmin;
      int newYMin = ymin;
      Quadrant quad;
      if (y > oldCenterY) {
        if (x > oldCenterX) {
          // New node is in the 'NorthEast'.
          quad = Quadrant.SouthWest;
        } else {
          // New node is in the 'NorthWest'.
          newXMin = xmin - width;
          quad = Quadrant.SouthEast;
        }
      } else {
        if (x > oldCenterX) {
          // New node is in the 'SouthEast'.
          newYMin = ymin - width;
          quad = Quadrant.NorthWest;
        } else {
          // New node is in the 'SouthWest'.
          newXMin = xmin - width;
          newYMin = ymin - width;
          quad = Quadrant.NorthEast;
        }
      }

      BranchNode newRoot = new BranchNode();
      newRoot.setLocation(newXMin, newYMin, width * 2);
      newRoot.setChild(quad, root);

      INode replacement = newRoot.reduce();
      assert(replacement is! EmptyNode);
      root = replacement as BaseNode;
    }
    return root;
  }

  /// Expands the tree's boundary to include the given point.
  /// [x] is the first component of the point to include.
  /// [y] is the second component of the point to include.
  void _expandBoundingBox(int x, int y) {
    if (this._pointCount <= 1) {
      this._boundary = new Boundary(x, y, x, y);
    } else {
      this._boundary = Boundary.expand(this._boundary, x, y);
    }
  }

  /// This collapses the boundary with the given point which was just removed.
  /// [point] is the point which was removed.
  void _collapseBoundingBox(IPoint point) {
    if (this._pointCount <= 0) {
      this._boundary = new Boundary(0, 0, 0, 0);
    } else {
      if (this._boundary.xmax() <= point.x()) {
        this._boundary = new Boundary(this._boundary.xmin(), this._boundary.ymin(),
            this.determineEastSide(this._boundary.xmin()), this._boundary.ymax());
      }

      if (this._boundary.xmin() >= point.x()) {
        this._boundary = new Boundary(this.determineWestSide(this._boundary.xmax()), this._boundary.ymin(),
            this._boundary.xmax(), this._boundary.ymax());
      }

      if (this._boundary.ymax() <= point.y()) {
        this._boundary = new Boundary(this._boundary.xmin(), this._boundary.ymin(), this._boundary.xmax(),
            this.determineNorthSide(this._boundary.ymin()));
      }

      if (this._boundary.ymin() >= point.y()) {
        this._boundary = new Boundary(this._boundary.xmax(), this._boundary.ymax(), this._boundary.xmin(),
            this.determineSouthSide(this._boundary.ymax()));
      }
    }
  }

  /// This finds the north side in the tree.
  /// Return is the value of the north side for the given direction.
  int _determineNorthSide(int value) {
    NodeStack stack = new NodeStack(this._root);
    while (!stack.isEmpty()) {
      INode node = stack.pop();
      if (node is PointNode) {
        if (value < node.y) value = node.y;
      } else if (node is BranchNode) {
        // The order of the child node calls is important to make this fast.
        if (value < node.ymax) stack.pushAll(node.sw, node.se, node.nw, node.ne);
      }
    }
    return value;
  }

  /// This finds the east side in the tree.
  /// Returns the value of the east side for the given direction.
  int _determineEastSide(int value) {
    NodeStack stack = new NodeStack(this._root);
    while (!stack.isEmpty()) {
      INode node = stack.pop();
      if (node is PointNode) {
        if (value < node.x) value = node.x;
      } else if (node is BranchNode) {
        // The order of the child node calls is important to make this fast.
        if (value < node.xmax) stack.pushAll(node.sw, node.nw, node.se, node.ne);
      }
    }
    return value;
  }

  /// This finds the south side in the tree.
  /// Returns the value of the south side for the given direction.
  int _determineSouthSide(int value) {
    NodeStack stack = new NodeStack(this._root);
    while (!stack.isEmpty()) {
      INode node = stack.pop();
      if (node is PointNode) {
        if (value > node.y) value = node.y;
      } else if (node is BranchNode) {
        // The order of the child node calls is important to make this fast.
        if (value > node.ymin) stack.pushAll(node.nw, node.ne, node.sw, node.se);
      }
    }
    return value;
  }

  /// This finds the west side in the tree.
  /// Returns the value of the west side for the given direction.
  int _determineWestSide(int value) {
    NodeStack stack = new NodeStack(this._root);
    while (!stack.isEmpty()) {
      INode node = stack.pop();
      if (node is PointNode) {
        if (value > node.x) value = node.x;
      } else if (node is BranchNode) {
        // The order of the child node calls is important to make this fast.
        if (value > node.xmin) stack.pushAll(node.se, node.ne, node.sw, node.nw);
      }
    }
    return value;
  }
}
