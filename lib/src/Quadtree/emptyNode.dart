part of PolygonalMap.Quadtree;

/// The empty node represents a node which has no data, no points nor edges.
/// It is a leaf in all locations that have no information in the tree.
class EmptyNode implements INode {
  /// The singleton instance of the empty node.
  static EmptyNode _singleton = null;

  /// This gets the single instance of the empty node.
  static EmptyNode get instance {
    if (_singleton == null) _singleton = new EmptyNode();
    return _singleton;
  }

  /// Creates a new empty node.
  EmptyNode._();

  /// Adds a point to this location in the tree.
  INode addPoint(int xmin, int ymin, int size, PointNode point) {
    point.setLocation(xmin, ymin, size);
    return point;
  }

  /// Adds an edge to this location in the tree.
  INode addEdge(int xmin, int ymin, int size, EdgeNode edge) {
    Boundary boundary = new Boundary(xmin, ymin, xmin + size - 1, ymin + size - 1);
    if (boundary.overlaps(edge)) {
      PassNode node = new PassNode();
      node.setLocation(xmin, ymin, size);
      node.passEdges.add(edge);
      return node;
    } else
      return this;
  }

  /// Handles each point node reachable from this node.
  @Override
  bool foreach(IPointHandler handle, {IBoundary bounds: null}) => true;

  /// Handles each edge node reachable from this node in the boundary.
  /// [exclusive] indicates that only edge which have both end points
  /// inside the region are collected, otherwise any edge which
  /// exists even partially in the region are collected.
  @Override
  bool foreach(IEdgeHandler handle, {IBoundary bounds: null, bool exclusive: false}) => true;

  /// Handles each node reachable from this node.
  @Override
  bool foreach(INodeHandler handle, {IBoundary bounds: null}) => true;

  /// Determines if the node has any point nodes inside it.
  @Override
  bool get hasPoints => false;

  /// Determines if the node has any edge nodes inside it.
  @Override
  bool get hasEdges => false;

  /// Gets the first edge to the left of the given point.
  @Override
  void firstLeftEdge(FirstLeftEdgeArgs args);

  /// Handles all the edges to the left of the given point.
  @Override
  bool foreachLeftEdge(IPoint pnt, IEdgeHandler hndl) => true;

  /// This handles the first found intersecting edge.
  @Override
  IntersectionResult findFirstIntersection(IEdge edge, IEdgeHandler hndl) => null;

  /// This handles all the intersections.
  @Override
  bool findAllIntersections(IEdge edge, IEdgeHandler hndl, IntersectionSet intersections) => false;

  /// Validates this node.
  @Override
  bool validate(StringBuffer sout, IFormatter format, bool recursive) => true;

  /// Formats the nodes into a string.
  /// [children] indicates any child should also be stringified.
  /// [contained] indicates this node is part of another node.
  /// [last] indicates this is the last node of the parent.
  @Override
  void toString(StringBuffer sout,
      {String indent: "", bool children: false, bool contained: false, bool last: true, IFormatter format: null}) {
    if (contained) {
      if (last)
        sout.append(StringParts.Last);
      else
        sout.append(StringParts.Child);
    }
    sout.append("EmptyNode");
  }

  /// Gets the string for this node.
  @Override
  String toString() {
    StringBuffer sout = new StringBuffer();
    this.toString(sout);
    return sout.toString();
  }
}
