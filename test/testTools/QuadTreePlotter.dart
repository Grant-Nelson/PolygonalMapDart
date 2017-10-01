part of testTools;

/**
 * A plotter customized to work with quad-trees.
 */
class QuadTreePlotter extends Plotter {

    /**
     * Shows a quad-tree in a plot panel.
     * @param tree The tree to show.
     */
    static void Show(QuadTree tree) {
        QuadTreePlotter plot = new QuadTreePlotter();
        plot.addTree("Tree", tree);
        plot.show();
    }

    /**
     * Creates a new quad-tree plotter.
     */
    public QuadTreePlotter() {
        // Do Nothing
    }

    /**
     * Shows the plot in a panel.
     */
    public void show() {
        this.updateBounds();
        this.focusOnData();
        PlotPanel.show(this);
    }

    /**
     * Adds a point to the given point list.
     * @param points The list of points to add to.
     * @param point The point to add to the list.
     * @return The given list of points.
     */
    public Points addPoint(Points points, IPoint point) {
        if (points != null) {
            points.add(point.x(), point.y());
        }
        return points;
    }

    /**
     * Adds a set of points to the given point list.
     * @param points The list of points to add to.
     * @param pointSet The set of points to add to the list.
     * @return The given list of points.
     */
    public Points addPoints(Points points, PointNodeSet pointSet) {
    	for (quadtree.PointNode point : pointSet) {
            points.add(point.x(), point.y());
    	}
        return points;
    }

    /**
     * Adds an edge to the given line list.
     * @param lines The list of lines to add to.
     * @param edge The edge to add to the list.
     * @return The given list of lines.
     */
    public Lines addLine(Lines lines, IEdge edge) {
        if (lines != null) {
            lines.add(edge.x1(), edge.y1(), edge.x2(), edge.y2());
        }
        return lines;
    }

    /**
     * Adds a boundary to the given rectangle list.
     * @param rects The list of the rectangles to add to.
     * @param bound The boundary to add to the list.
     * @param inset The amount to in-set the boundary.
     * @return The given list of rectangles.
     */
    public Rectangles addBound(Rectangles rects, Boundary bound, double inset) {
        if (rects != null) {
            double inset2 = 1.0 - inset*2.0;
            rects.add(bound.xmin()-inset, bound.ymin()-inset, bound.width()-inset2, bound.height()-inset2);
        }
        return rects;
    }

    /**
     * Adds a quad-tree to this plotter.
     * @param label The label of the group to show the tree under.
     * @param tree The quad-tree to add.
     * @return The group for this tree.
     */
    public Group addTree(String label, QuadTree tree) {
        Group group = this.addGroup(label);
        this.addTree(group, tree, true, true, false, false, true, true);
        return group;
    }

    /**
     * Adds a quad-tree to this plotter.
     * @param group The group to show the tree under.
     * @param tree The quad-tree to add.
     * @param showPassNodes True to show the pass nodes in the tree.
     * @param showPointNodes True to show the point nodes in the tree.
     * @param showEmptyNodes True to show the empty nodes in the tree.
     * @param showBranchNodes True to show the branch nodes in the tree.
     * @param showEdges True to show the edges in the tree.
     * @param showPoints True to show the points in the tree.
     */
    public void addTree(Group group, QuadTree tree, boolean showPassNodes, boolean showPointNodes,
            boolean showEmptyNodes, boolean showBranchNodes, boolean showEdges, boolean showPoints) {

        Rectangles passRects = new Rectangles();
        passRects.addColor(0.0, 1.0, 0.0);
        passRects.addFillColor(0.0, 1.0, 0.0, 0.3);
        group.addGroup("Pass Nodes").setEnabled(showPassNodes).add(passRects);

        Rectangles pointRects = new Rectangles();
        pointRects.addColor(0.0, 0.6, 0.2);
        pointRects.addFillColor(0.0, 0.6, 0.2, 0.3);
        group.addGroup("Point Nodes").setEnabled(showPointNodes).add(pointRects);

        Rectangles emptyRects = new Rectangles();
        emptyRects.addColor(0.8, 0.8, 0.0);
        emptyRects.addFillColor(0.8, 0.8, 0.0, 0.3);
        group.addGroup("Empty Nodes").setEnabled(showEmptyNodes).add(emptyRects);

        Rectangles branchRects = new Rectangles();
        branchRects.addColor(0.0, 0.8, 0.0);
        branchRects.addFillColor(0.0, 0.4, 0.8, 0.3);
        group.addGroup("Branch Nodes").setEnabled(showBranchNodes).add(branchRects);

        Lines edges = new Lines();
        edges.addColor(0.0, 0.0, 0.0);
        edges.addDirected(true);
        group.addGroup("Lines").setEnabled(showEdges).add(edges);

        Points points = new Points();
        points.addPointSize(3.0);
        points.addColor(0.0, 0.0, 0.0);
        group.addGroup("Points").setEnabled(showPoints).add(points);

        this.addTree(tree, passRects, pointRects, emptyRects, branchRects, edges, points);
    }

    /**
     * Adds a quad-tree to this plotter.
     * @param tree The quad-tree to add.
     * @param passRects The set or rectangles to add the pass nodes in the tree to, or null.
     * @param pointRects The set or rectangles to add the point nodes in the tree to, or null.
     * @param emptyRects The set or rectangles to add the empty nodes in the tree to, or null.
     * @param branchRects The set or rectangles to add the branch nodes in the tree to, or null.
     * @param edges The set of lines to add the edges in the tree to, or null.
     * @param points The set of points to add the points in the tree to, or null.
     */
    public void addTree(QuadTree tree, final Rectangles passRects, final Rectangles pointRects,
            final Rectangles emptyRects, final Rectangles branchRects,
            final Lines edges, final Points points) {

        final double pad = 0.45;
        final QuadTreePlotter plot = this;
        tree.foreach(new INodeHandler() {
            @Override
            public boolean handle(INode node) {
                if (PassNode.IsInstance(node)) {
                    plot.addBound(passRects, ((PassNode)node).boundary(), pad);
                } else if (PointNode.IsInstance(node)) {
                    plot.addBound(pointRects, ((PointNode)node).boundary(), pad);
                } else if (BranchNode.IsInstance(node)) {
                    BranchNode branch = (BranchNode)node;
                    if (emptyRects != null) {
                        for (Quadrant quad : Quadrant.values()) {
                            INode child = branch.child(quad);
                            if (EmptyNode.IsInstance(child)) {
                                double width = branch.width()/2 - 1.0 + pad*2.0;
                                emptyRects.add(branch.childX(quad)-pad, branch.childY(quad)-pad, width, width);
                            }
                        }
                    }
                    plot.addBound(branchRects, branch.boundary(), pad);
                }
                return true;
            }
        });

        if (edges != null) {
            tree.foreach(new IEdgeHandler(){
                public boolean handle(EdgeNode edge) {
                    plot.addLine(edges, edge);
                    return true;
                }
            });
        }

        if (points != null) {
            tree.foreach(new IPointHandler(){
                public boolean handle(PointNode point) {
                    plot.addPoint(points, point);
                    return true;
                }
            });
        }
    }
}
