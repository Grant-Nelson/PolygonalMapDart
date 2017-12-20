part of main;

enum Tool { AddPoints, RemovePoints, AddLines, RemoveLines }

class Driver {
  plotSvg.PlotSvg _svgPlot;
  plotter.QuadTreePlotter _plot;
  qt.QuadTree _tree;
  plotter.QuadTree _plotItem;

  BoolValue _points;
  BoolValue _lines;
  BoolValue _emptyNodes;
  BoolValue _branchNodes;
  BoolValue _passNodes;
  BoolValue _pointNodes;
  BoolValue _centerView;

  BoolValue _addPoints;
  BoolValue _removePoints;
  BoolValue _addLines;
  BoolValue _removeLines;

  Tool _selectedTool;

  Driver(this._svgPlot, this._plot) {
    _tree = new qt.QuadTree();
    _tree.insertEdge(new qt.Edge(new qt.Point(1, 1), new qt.Point(10, 10)));

    _plotItem = _plot.addTree(_tree);

    _points = new BoolValue(true, true);
    _lines = new BoolValue(true, true);
    _emptyNodes = new BoolValue(true);
    _branchNodes = new BoolValue(true);
    _passNodes = new BoolValue(true, true);
    _pointNodes = new BoolValue(true, true);
    _centerView = new BoolValue(false);

    _addPoints = new BoolValue(false, true);
    _removePoints = new BoolValue(false);
    _addLines = new BoolValue(false);
    _removeLines = new BoolValue(false);

    _selectedTool = Tool.AddPoints;

    _points.onChange.add((bool value) {
      _plotItem.showPoints = value;
      _svgPlot.refresh();
    });
    _lines.onChange.add((bool value) {
      _plotItem.showEdges = value;
      _svgPlot.refresh();
    });
    _emptyNodes.onChange.add((bool value) {
      _plotItem.showEmptyNodes = value;
      _svgPlot.refresh();
    });
    _branchNodes.onChange.add((bool value) {
      _plotItem.showBranchNodes = value;
      _svgPlot.refresh();
    });
    _passNodes.onChange.add((bool value) {
      _plotItem.showPassNodes = value;
      _svgPlot.refresh();
    });
    _pointNodes.onChange.add((bool value) {
      _plotItem.showPointNodes = value;
      _svgPlot.refresh();
    });
    _centerView.onChange.add((bool value) {
      if (value) {
        _centerView.value = false;
    _plot.updateBounds();
    _plot.focusOnData();
      _svgPlot.refresh();
      }
    });

    _addPoints.onChange.add((bool value) {
      _setTool(Tool.AddPoints, value);
    });
    _removePoints.onChange.add((bool value) {
      _setTool(Tool.RemovePoints, value);
    });
    _addLines.onChange.add((bool value) {
      _setTool(Tool.AddLines, value);
    });
    _removeLines.onChange.add((bool value) {
      _setTool(Tool.RemoveLines, value);
    });
  }

  BoolValue get points => _points;
  BoolValue get lines => _lines;
  BoolValue get emptyNodes => _emptyNodes;
  BoolValue get branchNodes => _branchNodes;
  BoolValue get passNodes => _passNodes;
  BoolValue get pointNodes => _pointNodes;
  BoolValue get centerView => _centerView;

  BoolValue get addPoints => _addPoints;
  BoolValue get removePoints => _removePoints;
  BoolValue get addLines => _addLines;
  BoolValue get removeLines => _removeLines;

  void _setTool(Tool newTool, bool value) {
    if ((!value) || (_selectedTool == newTool)) return;
    _selectedTool = newTool;
    _addPoints.value = (_selectedTool == Tool.AddPoints);
    _removePoints.value = (_selectedTool == Tool.RemovePoints);
    _addLines.value = (_selectedTool == Tool.AddLines);
    _removeLines.value = (_selectedTool == Tool.RemoveLines);
  }
}
