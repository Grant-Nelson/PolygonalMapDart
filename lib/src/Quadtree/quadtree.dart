library PolygonalMapDart.Quadtree;

import 'package:intl/intl.dart';
import 'dart:io';

part 'AreaAccumulator.dart';
part 'BaseNode.dart';
part 'BorderNeighbor.dart';
part 'Boundary.dart';
part 'BoundaryRegion.dart';
part 'BranchNode.dart';
part 'Coordinates.dart';
part 'Edge.dart';
part 'EdgeCollectorHandle.dart';
part 'EdgeNode.dart';
part 'EdgePointIgnorer.dart';
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
part 'PointNodeVector.dart';
part 'PointOnEdgeResult.dart';
part 'Quadrant.dart';
part 'Side.dart';
part 'StringParts.dart';

/// Roughly the distance to the corner of an unit square.
const double _distToCorner = 1.415;

/// ValidateHandler is an assistant method to the validate method.
class ValidateHandler implements IPointHandler {
  Boundary bounds = null;
  int pointCount = 0;
  int edgeCount = 0;

  bool handle(PointNode point) {
    this.bounds = Boundary.expand(this.bounds, point);
    this.pointCount++;
    this.edgeCount += point.startEdges.length;
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
    _root = EmptyNode.instance;
    _boundary = new Boundary(0, 0, 0, 0);
    _pointCount = 0;
    _edgeCount = 0;
  }

  /// The root node of the quad-tree.
  INode get root => _root;

  /// Gets the tight bounding box of all the data.
  Boundary get boundary => _boundary;

  /// Gets the number of points in the tree.
  int get pointCount => _pointCount;

  /// Gets the number of edges in the tree.
  int get edgeCount => _edgeCount;

  /// Clears all the points, edges, and nodes from the quad-tree.
  /// Does not clear the additional data.
  void clear() {
    _root = EmptyNode.instance;
    _boundary = new Boundary(0, 0, 0, 0);
    _pointCount = 0;
    _edgeCount = 0;
  }

  /// Finds a point node from this node for the given point.
  PointNode findPoint(IPoint point) {
    if (!_boundary.containsPoint(point)) return null;
    INode node = _root;
    while (true) {
      if (node is PointNode) {
        if (Point.equals(node, point))
          return node;
        else
          return null;
      } else if (node is BranchNode) {
        BranchNode branch = node as BranchNode;
        int quad = branch.childQuad(point);
        node = branch.child(quad);
      } else
        return null; // Pass nodes and empty nodes have no points.
    }
  }

  /// This will locate the smallest non-empty node containing the given point.
  /// Returns this is the smallest non-empty node containing the given point.
  /// If no non-empty node could be found from this node then null is returned.
  BaseNode nodeContaining(IPoint point) {
    if (!_boundary.containsPoint(point)) return null;
    INode node = _root;
    while (true) {
      if (node is BranchNode) {
        BranchNode branch = node as BranchNode;
        int quad = branch.childQuad(point);
        node = branch.child(quad);
        if (node is EmptyNode) return branch;
      } else if (node is EmptyNode)
        return null;
      else
        return node; // The pass or point node.
    }
  }

  /// Finds an edge node from this node for the given edge.
  /// Set [undirected] to true if the opposite edge may also be returned, false if not.
  EdgeNode findEdge(IEdge edge, bool undirected) {
    PointNode node = findPoint(edge.start);
    if (node == null) return null;
    EdgeNode result = node.findEdgeTo(edge.end);
    if ((result == null) && undirected) result = node.findEdgeFrom(edge.end);
    return result;
  }

  /// Finds the nearest point to the given point.
  /// [queryPoint] is the query point to find a point nearest to.
  /// [cutoffDist2] is the maximum allowable distance squared to the nearest point.
  /// [handle] is the handle to filter acceptable points with, or null to not filter.
  PointNode findNearestPointToPoint(IPoint queryPoint,
      {double cutoffDist2: double.MAX_FINITE, IPointHandler handle: null}) {
    PointNode result = null;
    NodeStack stack = new NodeStack([_root]);
    while (!stack.isEmpty) {
      INode node = stack.pop;
      if (node is PointNode) {
        PointNode point = node;
        double dist2 = Point.distance2(queryPoint, point);
        if (dist2 < cutoffDist2) {
          if ((handle == null) || handle.handle(point)) {
            result = point;
            cutoffDist2 = dist2;
          }
        }
      } else if (node is BranchNode) {
        BranchNode branch = node;
        double dist2 = branch.distance2(queryPoint);
        if (dist2 <= cutoffDist2) stack.pushChildren(branch);
      }
      // else, Pass nodes and empty nodes have no points.
    }
    return result;
  }

  /// Finds the nearest point to the given edge.
  /// [queryEdge] is the query edge to find a point nearest to.
  /// [cutoffDist2] is the maximum allowable distance squared to the nearest point.
  /// [handle] is the handle to filter acceptable points with, or null to not filter.
  PointNode findNearestPointToEdge(IEdge queryEdge,
      {double cutoffDist2: double.MAX_FINITE, IPointHandler handle: null}) {
    PointNode result = null;
    NodeStack stack = new NodeStack([_root]);
    while (!stack.isEmpty) {
      INode node = stack.pop;
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
        int x = node.xmin + width ~/ 2;
        int y = node.ymin + width ~/ 2;
        double diagDist2 = 2.0 * width * width;
        double dist2 = Edge.distance2(queryEdge, new Point(x, y)) - diagDist2;
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
    NodeStack stack = new NodeStack([_root]);
    while (!stack.isEmpty) {
      INode node = stack.pop;
      if (node is PointNode) {
        PointOnEdgeResult pnt = Edge.pointOnEdge(queryEdge, node);
        if (pnt.onEdge) {
          if ((handle == null) || handle.handle(node)) {
            return node;
          }
        }
      } else if (node is BranchNode) {
        int width = node.width;
        int x = node.xmin + width ~/ 2;
        int y = node.ymin + width ~/ 2;
        double diagDist2 = 2.0 * width * width;
        double dist2 = Edge.distance2(queryEdge, new Point(x, y)) - diagDist2;
        if (dist2 <= _distToCorner) stack.pushChildren(node);
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
  EdgeNode findNearestEdge(IPoint point, {double cutoffDist2: double.MAX_FINITE, IEdgeHandler handler: null}) {
    NearestEdgeArgs args = new NearestEdgeArgs(point, cutoffDist2, handler);
    args.run(_root);
    return args.result();
  }

  /// Returns the first left edge to the given query point.
  /// [point] is the point to find the first left edge from.
  /// [handle] is the matcher to filter eligible edges. If null all edges are accepted.
  EdgeNode firstLeftEdge(IPoint point, {IEdgeHandler handle: null}) {
    FirstLeftEdgeArgs args = new FirstLeftEdgeArgs(point, handle);
    _root.firstLeftEdge(args);
    return args.result;
  }

  /// Handle all the edges to the left of the given point.
  /// [point] is the point to find the left edges from.
  /// [handle] is the handle to process all the edges with.
  bool foreachLeftEdge(IPoint point, IEdgeHandler handle) => _root.foreachLeftEdge(point, handle);

  /// Gets the first point in the tree.
  /// [boundary] is the boundary of the tree to get the point from, or null for whole tree.
  /// [handle] is the point handler to filter points with, or null for no filter.
  PointNode firstPoint(IBoundary boundary, IPointHandler handle) {
    PointNode result = null;
    NodeStack stack = new NodeStack([_root]);
    while (!stack.isEmpty) {
      INode node = stack.pop;
      if (node is PointNode) {
        if ((boundary == null) || boundary.containsPoint(node)) return node;
      } else if (node is BranchNode) {
        if ((boundary == null) || boundary.overlapsBoundary(node)) stack.pushChildren(node);
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
    NodeStack stack = new NodeStack([_root]);
    while (!stack.isEmpty) {
      INode node = stack.pop;
      if (node is PointNode) {
        if ((boundary == null) || boundary.containsPoint(node)) return node;
      } else if (node is BranchNode) {
        if ((boundary == null) || boundary.overlapsBoundary(node)) stack.pushReverseChildren(node);
      }
      // else, Pass nodes and empty nodes have no points.
    }
    return result;
  }

  /// Handles each point node in the boundary.
  bool foreachPoint(IPointHandler handle, [IBoundary bounds = null]) => _root.foreachPoint(handle, bounds);

  /// Handles each edge node in the boundary.
  /// [handle] is the handler to run on each edge in the boundary.
  /// [bounds] is the boundary containing the edges to handle.
  /// [exclusive] indicates that only edge which have both end points
  /// inside the region are collected, otherwise any edge which
  /// exists even partially in the region are collected.
  /// Returns true if all edges in the boundary were run, false if stopped.
  bool foreachEdge(IEdgeHandler handle, [IBoundary bounds = null, bool exclusive = false]) =>
      _root.foreachEdge(handle, bounds, exclusive);

  /// Handles each node in the boundary.
  /// [handle] is the handler to run on each node in the boundary.
  /// [bounds] is the boundary containing the nodes to handle.
  /// Returns true if all nodes in the boundary were run, false if stopped.
  bool foreachNode(INodeHandler handle, [IBoundary bounds = null]) => _root.foreachNode(handle, bounds);

  /// Calls given handle for the all the near points to the given point.
  /// [handle] is the handle to handle all near points with.
  /// [queryPoint] is the query point to find the points near to.
  /// [cutoffDist2] is the maximum allowable distance squared to the near points.
  /// Returns true if all points handled, false if the handled returned false and stopped early.
  bool forNearPointPoints(IPointHandler handle, IPoint queryPoint, double cutoffDist2) {
    NodeStack stack = new NodeStack([_root]);
    while (!stack.isEmpty) {
      INode node = stack.pop;
      if (node is PointNode) {
        double dist2 = Point.distance2(queryPoint, node);
        if (dist2 < cutoffDist2) {
          if (!handle.handle(node)) return false;
        }
      } else if (node is BranchNode) {
        int width = node.width;
        int x = node.xmin + width ~/ 2;
        int y = node.ymin + width ~/ 2;
        double diagDist2 = 2.0 * width * width;
        double dist2 = Point.distance2(queryPoint, new Point(x, y)) - diagDist2;
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
  bool forNearEdgePoints(IPointHandler handle, IEdge queryEdge, double cutoffDist2) {
    NodeStack stack = new NodeStack([_root]);
    while (!stack.isEmpty) {
      INode node = stack.pop;
      if (node is PointNode) {
        double dist2 = Edge.distance2(queryEdge, node);
        if (dist2 < cutoffDist2) {
          if (!handle.handle(node)) return false;
        }
      } else if (node is BranchNode) {
        int width = node.width;
        int x = node.xmin + width ~/ 2;
        int y = node.ymin + width ~/ 2;
        double diagDist2 = 2.0 * width * width;
        double dist2 = Edge.distance2(queryEdge, new Point(x, y)) - diagDist2;
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
    NodeStack stack = new NodeStack([_root]);
    while (!stack.isEmpty) {
      INode node = stack.pop;
      if (node is PointNode) {
        PointOnEdgeResult pnt = Edge.pointOnEdge(queryEdge, node);
        if (pnt.onEdge) {
          if (!handle.handle(node)) return false;
        }
      } else if (node is BranchNode) {
        int width = node.width;
        int x = node.xmin + width ~/ 2;
        int y = node.ymin + width ~/ 2;
        double diagDist2 = 2.0 * width * width;
        double dist2 = Edge.distance2(queryEdge, new Point(x, y)) - diagDist2;
        if (dist2 <= _distToCorner) stack.pushChildren(node);
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
    stack.push(_root);
    while (!stack.isEmpty) {
      INode node = stack.pop;
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
        int x = node.xmin + width ~/ 2;
        int y = node.ymin + width ~/ 2;
        double diagDist2 = 2.0 * width * width;
        double dist2 = Point.distance2(queryPoint, new Point(x, y)) - diagDist2;
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
    stack.push(_root);
    while (!stack.isEmpty) {
      INode node = stack.pop;
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
        int x = node.xmin + width ~/ 2;
        int y = node.ymin + width ~/ 2;
        double diagDist2 = 2.0 * width * width;
        double dist2 = Point.distance2(queryPoint, new Point(x, y)) - diagDist2;
        if (dist2 <= _distToCorner) stack.pushChildren(node);
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
  IntersectionResult findFirstIntersection(IEdge edge, IEdgeHandler hndl) => _root.findFirstIntersection(edge, hndl);

  /// This handles all the intersections.
  /// [edge] is the edge to look for intersections with.
  /// [hndl] is the handler to match valid edges with.
  /// [intersections] is the set of intersections to add to.
  /// Returns true if a new intersection was found.
  bool findAllIntersections(IEdge edge, IEdgeHandler hndl, IntersectionSet intersections) {
    if (_edgeCount > 0) {
      return (_root as BaseNode).findAllIntersections(edge, hndl, intersections);
    }
    return false;
  }

  /// This inserts an edge or finds an existing edge in the quad-tree.
  /// [edge] is the edge to insert into the tree.
  /// Returns the edge in the tree.
  EdgeNode insertEdge(IEdge edge) => tryInsertEdge(edge).edge;

  /// This inserts an edge or finds an existing edge in the quad-tree.
  /// [edge] is the edge to insert into the tree.
  /// Returns a pair containing the edge in the tree, and true if the edge is
  /// new or false if the edge already existed in the tree.
  InsertEdgeResult tryInsertEdge(IEdge edge) {
    PointNode startNode, endNode;
    bool startNew, endNew;

    if ((edge.start is PointNode) && ((edge.start as PointNode).root == _root)) {
      startNode = edge.start;
      startNew = false;
    } else {
      InsertPointResult pair = tryInsertPoint(edge.start);
      startNode = pair.point;
      startNew = pair.existed;
    }

    if ((edge.end is PointNode) && ((edge.end as PointNode).root == _root)) {
      endNode = edge.end;
      endNew = false;
    } else {
      InsertPointResult pair = tryInsertPoint(edge.end);
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
      assert(validate());
      assert(startNode.root == _root);
      assert(endNode.root == _root);
      assert(ancestor != null);
      return null;
    }
    EdgeNode newEdge = new EdgeNode._(startNode, endNode);

    INode replacement = ancestor.insertEdge(newEdge);
    _reduceBranch(ancestor, replacement);
    _edgeCount++;
    return new InsertEdgeResult(newEdge, true);
  }

  /// This inserts a point or finds an existing point in the quad-tree.
  /// [point] is the point to insert into the tree.
  /// Returns the point node for the point inserted into the tree, or
  /// the point node which already existed.
  PointNode insertPoint(IPoint point) => tryInsertPoint(point).point;

  /// This inserts a point or finds an existing point in the quad-tree.
  /// [point] is the point to insert into the tree.
  /// Returns a pair containing the point node in the tree, and true if the
  /// point is new or false if the point already existed in the tree.
  InsertPointResult tryInsertPoint(IPoint point) {
    if (point is Point) {
      point = new PointNode(point.x, point.y);
    }
    // Attempt to find the point first.
    BaseNode node = nodeContaining(point);
    if (node != null) {
      // A node containing the point has been found.
      if (node is PointNode) {
        if (Point.equals(node, point)) {
          return new InsertPointResult(node, true);
        }
      }
      BranchNode parent = node.parent;
      if (parent != null) {
        int quad = parent.childNodeQuad(node);
        INode replacement = node.insertPoint(point);
        parent.setChild(quad, replacement);
        replacement = parent.reduce();
        _reduceBranch(parent, replacement);
      } else {
        INode replacement = node.insertPoint(point);
        _setRoot(replacement);
      }
    } else if (_root is EmptyNode) {
      // Tree is empty so create a new tree.
      int initialTreeWidth = 256;
      int centerX = (point.x ~/ initialTreeWidth) * initialTreeWidth;
      int centerY = (point.y ~/ initialTreeWidth) * initialTreeWidth;
      if (point.x < 0) centerX -= (initialTreeWidth - 1);
      if (point.y < 0) centerY -= (initialTreeWidth - 1);
      _setRoot((_root as EmptyNode).addPoint(centerX, centerY, initialTreeWidth, point));
    } else {
      // Point outside of tree, expand the tree.
      BaseNode root = _expandFootprint(_root as BaseNode, point);
      _setRoot(root.insertPoint(point));
    }

    assert(_root is! EmptyNode);
    _pointCount++;
    _expandBoundingBox(point);
    return new InsertPointResult(point, false);
  }

  /// This removes an edge from the tree.
  /// [edge] is the edge to remove from the tree.
  /// [trimTree] indicates if the end points of the edge should be
  /// removed if no other edge begins or ends at that point.
  void removeEdge(EdgeNode edge, bool trimTree) {
    BranchNode ancestor = edge.startNode.commonAncestor(edge.endNode);
    assert(ancestor != null);

    INode replacement = ancestor.removeEdge(edge, trimTree);
    _reduceBranch(ancestor, replacement);
    --_edgeCount;

    // If trimming the tree, see if the black nodes need to be deleted.
    if (trimTree) {
      if (edge.startNode.orphan) {
        removePoint(edge.startNode);
      }
      if (edge.endNode.orphan) {
        removePoint(edge.endNode);
      }
    }
  }

  /// This removes a point from the tree.
  /// [point] is the point to removed from the tree.
  void removePoint(PointNode point) {
    // Remove any edges on the point.
    for (EdgeNode edge in point.startEdges) removeEdge(edge, false);
    for (EdgeNode edge in point.endEdges) removeEdge(edge, false);

    // The point node must not have any edges beginning
    // nor ending on by the time is is removed.
    assert(point.orphan);

    // Remove the point from the tree.
    if (_root == point) {
      // If the only thing in the tree is the point, simply replace it
      // with an empty node.
      _root = EmptyNode.instance;
    } else {
      BranchNode parent = point.parent;
      INode replacement = point.replacement;
      int quad = parent.childNodeQuad(point);
      parent.setChild(quad, replacement);
      replacement = parent.reduce();
      _reduceBranch(parent, replacement);
    }
    --_pointCount;
    _collapseBoundingBox(point);
  }

  /// Validates this quad-tree.
  /// [sout] is the output to write errors to.
  /// [format] is the format used for printing, null to use default.
  /// Returns true if valid, false if invalid.
  bool validate([StringBuffer sout = null, IFormatter format = null]) {
    bool result = true;
    bool toConsole = false;
    if (sout == null) {
      sout = new StringBuffer();
      toConsole = true;
    }

    ValidateHandler vHndl = new ValidateHandler();
    foreachPoint(vHndl);

    if (_pointCount != vHndl.pointCount) {
      sout.write("Error: The point count should have been ");
      sout.write(vHndl.pointCount);
      sout.write(" but it was ");
      sout.write(_pointCount);
      sout.write(".\n");
      result = false;
    }

    if (_edgeCount != vHndl.edgeCount) {
      sout.write("Error: The edge count should have been ");
      sout.write(vHndl.edgeCount);
      sout.write(" but it was ");
      sout.write(_edgeCount);
      sout.write(".\n");
      result = false;
    }

    if (vHndl.bounds == null) {
      vHndl.bounds = new Boundary(0, 0, 0, 0);
    }

    if (!Boundary.equals(_boundary, vHndl.bounds)) {
      sout.write("Error: The boundary should have been ");
      sout.write(vHndl.bounds.toString());
      sout.write(" but it was ");
      sout.write(_boundary.toString());
      sout.write(".\n");
      result = false;
    }

    if (_root is! EmptyNode) {
      BaseNode root = _root as BaseNode;
      if (root.parent != null) {
        sout.write("Error: The root node's parent should be null but it is ");
        root.parent.toBuffer(sout, format: format);
        sout.write(".\n");
        result = false;
      }
    }

    if (!_root.validate(sout, format, true)) result = false;
    if (toConsole) {
      stdout.write(sout.toString());
    }
    return result;
  }

  /// Formats the quad-tree into a string.
  /// [sout] is the output to write the formatted string to.
  /// [indent] is the indent for this quad-tree.
  /// [contained] indicates this node is part of another output.
  /// [last] indicates this is the last output of the parent.
  /// [format] is the format used for printing, null to use default.
  void toBuffer(StringBuffer sout,
      {String indent: "", bool contained: false, bool last: true, IFormatter format: null}) {
    if (contained) {
      if (last)
        sout.write(StringParts.Last);
      else
        sout.write(StringParts.Child);
    }
    sout.write("Tree:");

    String childIndent;
    if (contained && !last)
      childIndent = indent + StringParts.Bar;
    else
      childIndent = indent + StringParts.Space;

    sout.write(StringParts.Sep);
    sout.write(indent);
    sout.write(StringParts.Child);
    sout.write("Region: ");
    sout.write(_boundary.toString(format: format));

    sout.write(StringParts.Sep);
    sout.write(indent);
    sout.write(StringParts.Child);
    sout.write("Points: ");
    sout.write(_pointCount);

    sout.write(StringParts.Sep);
    sout.write(indent);
    sout.write(StringParts.Child);
    sout.write("Edges: ");
    sout.write(_edgeCount);

    sout.write(StringParts.Sep);
    sout.write(indent);
    _root.toBuffer(sout, indent: childIndent, children: true, contained: true, format: format);
  }

  /// Gets the string for this quad-tree.
  String toString() {
    StringBuffer sout = new StringBuffer();
    toBuffer(sout);
    return sout.toString();
  }

  /// This reduces the root to the smallest branch needed.
  /// [node] is the original node to reduce.
  /// [replacement] is the node to replace the original node with.
  void _reduceBranch(BaseNode node, INode replacement) {
    while (replacement != node) {
      BranchNode parent = node.parent;
      if (parent == null) {
        _setRoot(replacement);
        break;
      }
      int quad = parent.childNodeQuad(node);
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
    if (_root == node) return false;
    _root = node;
    if (_root is! EmptyNode) {
      (_root as BaseNode).parent = null;
    }
    return true;
  }

  /// This expands the foot print of the tree to include the given point.
  /// [root] is the original root to expand.
  /// Returns the new expanded root.
  BaseNode _expandFootprint(BaseNode root, IPoint point) {
    while (!root.containsPoint(point)) {
      int xmin = root.xmin;
      int ymin = root.ymin;
      int width = root.width;
      int half = width ~/ 2;
      int oldCenterX = xmin + half;
      int oldCenterY = ymin + half;

      int newXMin = xmin;
      int newYMin = ymin;
      int quad;
      if (point.y > oldCenterY) {
        if (point.x > oldCenterX) {
          // New node is in the 'NorthEast'.
          quad = Quadrant.SouthWest;
        } else {
          // New node is in the 'NorthWest'.
          newXMin = xmin - width;
          quad = Quadrant.SouthEast;
        }
      } else {
        if (point.x > oldCenterX) {
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
  void _expandBoundingBox(IPoint point) {
    if (_pointCount <= 1) {
      _boundary = new Boundary(point.x, point.y, point.x, point.y);
    } else {
      _boundary = Boundary.expand(_boundary, point);
    }
  }

  /// This collapses the boundary with the given point which was just removed.
  /// [point] is the point which was removed.
  void _collapseBoundingBox(IPoint point) {
    if (_pointCount <= 0) {
      _boundary = new Boundary(0, 0, 0, 0);
    } else {
      if (_boundary.xmax <= point.x) {
        _boundary = new Boundary(_boundary.xmin, _boundary.ymin, _determineEastSide(_boundary.xmin), _boundary.ymax);
      }

      if (_boundary.xmin >= point.x) {
        _boundary = new Boundary(_determineWestSide(_boundary.xmax), _boundary.ymin, _boundary.xmax, _boundary.ymax);
      }

      if (_boundary.ymax <= point.y) {
        _boundary = new Boundary(_boundary.xmin, _boundary.ymin, _boundary.xmax, _determineNorthSide(_boundary.ymin));
      }

      if (_boundary.ymin >= point.y) {
        _boundary = new Boundary(_boundary.xmax, _boundary.ymax, _boundary.xmin, _determineSouthSide(_boundary.ymax));
      }
    }
  }

  /// This finds the north side in the tree.
  /// Return is the value of the north side for the given direction.
  int _determineNorthSide(int value) {
    NodeStack stack = new NodeStack([_root]);
    while (!stack.isEmpty) {
      INode node = stack.pop;
      if (node is PointNode) {
        if (value < node.y) value = node.y;
      } else if (node is BranchNode) {
        // The order of the child node calls is important to make this fast.
        if (value < node.ymax) stack.pushAll([node.sw, node.se, node.nw, node.ne]);
      }
    }
    return value;
  }

  /// This finds the east side in the tree.
  /// Returns the value of the east side for the given direction.
  int _determineEastSide(int value) {
    NodeStack stack = new NodeStack([_root]);
    while (!stack.isEmpty) {
      INode node = stack.pop;
      if (node is PointNode) {
        if (value < node.x) value = node.x;
      } else if (node is BranchNode) {
        // The order of the child node calls is important to make this fast.
        if (value < node.xmax) stack.pushAll([node.sw, node.nw, node.se, node.ne]);
      }
    }
    return value;
  }

  /// This finds the south side in the tree.
  /// Returns the value of the south side for the given direction.
  int _determineSouthSide(int value) {
    NodeStack stack = new NodeStack([_root]);
    while (!stack.isEmpty) {
      INode node = stack.pop;
      if (node is PointNode) {
        if (value > node.y) value = node.y;
      } else if (node is BranchNode) {
        // The order of the child node calls is important to make this fast.
        if (value > node.ymin) stack.pushAll([node.nw, node.ne, node.sw, node.se]);
      }
    }
    return value;
  }

  /// This finds the west side in the tree.
  /// Returns the value of the west side for the given direction.
  int _determineWestSide(int value) {
    NodeStack stack = new NodeStack([_root]);
    while (!stack.isEmpty) {
      INode node = stack.pop;
      if (node is PointNode) {
        if (value > node.x) value = node.x;
      } else if (node is BranchNode) {
        // The order of the child node calls is important to make this fast.
        if (value > node.xmin) stack.pushAll([node.se, node.ne, node.sw, node.nw]);
      }
    }
    return value;
  }
}
