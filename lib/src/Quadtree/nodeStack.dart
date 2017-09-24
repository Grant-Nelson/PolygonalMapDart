part of PolygonalMapDart.Quadtree;

/// A stack of nodes.
class NodeStack extends ArrayDeque<INode> {
  /// Creates a new stack.
  /// The initial sets of [nodes] is pushed in order.
  NodeStack(List<INode> nodes) {
    for (INode node in nodes) {
      this.push(node);
    }
  }

  /// Pushes a set of nodes onto the stack.
  void pushAll(List<INode> nodes) {
    for (INode node in nodes) {
      this.push(node);
    }
  }

  /// Pushes the children of the given branch onto this stack.
  void pushChildren(BranchNode node) {
    // Push in reverse order from typical searches so that they
    // are processed in the order: NE, NW, SE, then SW.
    this.push(node.sw);
    this.push(node.se);
    this.push(node.nw);
    this.push(node.ne);
  }

  /// Pushes the children of the given branch onto this stack in reverse order.
  void pushReverseChildren(BranchNode node) {
    // Push in normal order from typical searches so that they
    // are processed in the order: SW, SE, NW, then NE.
    this.push(node.ne);
    this.push(node.nw);
    this.push(node.se);
    this.push(node.sw);
  }
}
