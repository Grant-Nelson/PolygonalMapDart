part of PolygonalMapDart.Quadtree;

/// A stack of nodes.
class NodeStack {
  /// The internal stack of nodes.
  List<INode> _stack;

  /// Creates a new stack.
  /// The initial sets of [nodes] is pushed in order.
  NodeStack([List<INode> nodes = null]) {
    _stack = new List<INode>();
    for (INode node in nodes) {
      push(node);
    }
  }

  /// Indicates if the stask is empty.
  bool get isEmpty => _stack.isEmpty;

  /// Pops the the top node off the stack.
  INode get pop => _stack.removeLast();

  /// Pushes the given node onto the top of the stack.
  void push(INode node) => _stack.add(node);

  /// Pushes a set of nodes onto the stack.
  void pushAll(List<INode> nodes) {
    for (INode node in nodes) push(node);
  }

  /// Pushes the children of the given branch onto this stack.
  void pushChildren(BranchNode node) {
    // Push in reverse order from typical searches so that they
    // are processed in the order: NE, NW, SE, then SW.
    push(node.sw);
    push(node.se);
    push(node.nw);
    push(node.ne);
  }

  /// Pushes the children of the given branch onto this stack in reverse order.
  void pushReverseChildren(BranchNode node) {
    // Push in normal order from typical searches so that they
    // are processed in the order: SW, SE, NW, then NE.
    push(node.ne);
    push(node.nw);
    push(node.se);
    push(node.sw);
  }
}
