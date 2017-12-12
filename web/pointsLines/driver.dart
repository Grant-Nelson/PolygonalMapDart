part of main;

class Driver {

  plotter.Plotter _plot;
  qt.QuadTree _tree;

  Driver(this._plot) {
    this._tree = new qt.QuadTree();
  }

}
