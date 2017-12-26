part of main;

enum Tool { None, PanView, AddPoints, RemovePoints, AddLines, RemoveLines, RemoveLinesAndTrim }

class Driver {
  plotSvg.PlotSvg _svgPlot;
  qtPlot.QuadTreePlotter _plot;
  qt.QuadTree _tree;
  qtPlot.QuadTree _plotItem;

  BoolValue _centerView;
  BoolValue _points;
  BoolValue _lines;
  BoolValue _emptyNodes;
  BoolValue _branchNodes;
  BoolValue _passNodes;
  BoolValue _pointNodes;
  BoolValue _boundary;
  BoolValue _rootBoundary;

  BoolValue _panView;
  BoolValue _addPoints;
  BoolValue _removePoints;
  BoolValue _addLines;
  BoolValue _removeLines;
  BoolValue _removeLinesAndTrim;
  BoolValue _validate;
  BoolValue _printTree;
  BoolValue _clearAll;

  Tool _selectedTool;
  plotter.MousePan _shiftPanViewTool;
  plotter.MousePan _panViewTool;
  PointAdder _pointAdderTool;
  PointRemover _pointRemoverTool;
  LineAdder _lineAdderTool;
  LineRemover _lineRemoverTool;
  LineRemover _lineRemoverAndTrimTool;

  Driver(this._svgPlot, this._plot) {
    _tree = new qt.QuadTree();

    _plotItem = _plot.addTree(_tree);
    _selectedTool = Tool.None;

    _centerView = new BoolValue(false)..onChange.add(_onCenterViewChange);
    _points = new BoolValue(true, true)..onChange.add(_onPointsChange);
    _lines = new BoolValue(true, true)..onChange.add(_onLinesChange);
    _emptyNodes = new BoolValue(true)..onChange.add(_onEmptyNodesChange);
    _branchNodes = new BoolValue(true)..onChange.add(_onBranchNodesChange);
    _passNodes = new BoolValue(true, true)..onChange.add(_onPassNodesChange);
    _pointNodes = new BoolValue(true, true)..onChange.add(_onPointNodesChange);
    _boundary = new BoolValue(true, true)..onChange.add(_onBoundaryChange);
    _rootBoundary = new BoolValue(true, true)..onChange.add(_onRootBoundaryChange);

    _panView = new BoolValue(false)..onChange.add(_onPanViewChange);
    _addPoints = new BoolValue(false, true)..onChange.add(_onAddPointsChange);
    _removePoints = new BoolValue(false)..onChange.add(_onRemovePointsChange);
    _addLines = new BoolValue(false)..onChange.add(_onAddLinesChange);
    _removeLines = new BoolValue(false)..onChange.add(_onRemoveLinesChange);
    _removeLinesAndTrim = new BoolValue(false)..onChange.add(_onRemoveLinesAndTrimChange);
    _validate = new BoolValue(false)..onChange.add(_onValidateChange);
    _printTree = new BoolValue(false)..onChange.add(_onPrintTreeChange);
    _clearAll = new BoolValue(false)..onChange.add(_onClearAllChange);

    _shiftPanViewTool = new plotter.MousePan(_plot, new plotter.MouseButtonState(0, shiftKey: true));
    plotter.MouseButtonState leftMsButton = new plotter.MouseButtonState(0);
    _panViewTool = new plotter.MousePan(_plot, leftMsButton);
    _pointAdderTool = new PointAdder(_tree, _plot, _plotItem, leftMsButton);
    _pointRemoverTool = new PointRemover(_tree, _plot, _plotItem, leftMsButton);
    _lineAdderTool = new LineAdder(_tree, _plot, _plotItem, leftMsButton);
    _lineRemoverTool = new LineRemover(_tree, _plot, _plotItem, leftMsButton, false);
    _lineRemoverAndTrimTool = new LineRemover(_tree, _plot, _plotItem, leftMsButton, true);

    _plot.MouseHandles
      ..clear()
      ..add(_shiftPanViewTool)
      ..add(_panViewTool)
      ..add(_pointAdderTool)
      ..add(_pointRemoverTool)
      ..add(_lineAdderTool)
      ..add(_lineRemoverTool)
      ..add(_lineRemoverAndTrimTool);
    _plot.focusOnBounds(new plotter.Bounds(-100.0, -100.0, 100.0, 100.0));
    _setTool(Tool.AddPoints, true);
  }

  BoolValue get centerView => _centerView;
  BoolValue get points => _points;
  BoolValue get lines => _lines;
  BoolValue get emptyNodes => _emptyNodes;
  BoolValue get branchNodes => _branchNodes;
  BoolValue get passNodes => _passNodes;
  BoolValue get pointNodes => _pointNodes;
  BoolValue get boundary => _boundary;
  BoolValue get rootBoundary => _rootBoundary;

  BoolValue get panView => _panView;
  BoolValue get addPoints => _addPoints;
  BoolValue get removePoints => _removePoints;
  BoolValue get addLines => _addLines;
  BoolValue get removeLines => _removeLines;
  BoolValue get removeLinesAndTrim => _removeLinesAndTrim;
  BoolValue get validate => _validate;
  BoolValue get printTree => _printTree;
  BoolValue get clearAll => _clearAll;

  void _onCenterViewChange(bool value) {
    if (value) {
      _centerView.value = false;
      qt.Boundary bounds = _tree.boundary;
      if (bounds.empty) {
        _plot.focusOnBounds(new plotter.Bounds(-100.0, -100.0, 100.0, 100.0));
      } else {
        _plot.focusOnBounds(new plotter.Bounds(
            bounds.xmin.toDouble(), bounds.ymin.toDouble(), bounds.xmax.toDouble(), bounds.ymax.toDouble()));
      }
      _svgPlot.refresh();
    }
  }

  void _onPointsChange(bool value) {
    _plotItem.showPoints = value;
    _svgPlot.refresh();
  }

  void _onLinesChange(bool value) {
    _plotItem.showEdges = value;
    _svgPlot.refresh();
  }

  void _onEmptyNodesChange(bool value) {
    _plotItem.showEmptyNodes = value;
    _svgPlot.refresh();
  }

  void _onBranchNodesChange(bool value) {
    _plotItem.showBranchNodes = value;
    _svgPlot.refresh();
  }

  void _onPassNodesChange(bool value) {
    _plotItem.showPassNodes = value;
    _svgPlot.refresh();
  }

  void _onPointNodesChange(bool value) {
    _plotItem.showPointNodes = value;
    _svgPlot.refresh();
  }

  void _onBoundaryChange(bool value) {
    _plotItem.showBoundary = value;
    _svgPlot.refresh();
  }

  void _onRootBoundaryChange(bool value) {
    _plotItem.showRootBoundary = value;
    _svgPlot.refresh();
  }

  void _onPanViewChange(bool value) {
    _setTool(Tool.PanView, value);
  }

  void _onAddPointsChange(bool value) {
    _setTool(Tool.AddPoints, value);
  }

  void _onRemovePointsChange(bool value) {
    _setTool(Tool.RemovePoints, value);
  }

  void _onAddLinesChange(bool value) {
    _setTool(Tool.AddLines, value);
  }

  void _onRemoveLinesChange(bool value) {
    _setTool(Tool.RemoveLines, value);
  }

  void _onRemoveLinesAndTrimChange(bool value) {
    _setTool(Tool.RemoveLinesAndTrim, value);
  }

  void _setTool(Tool newTool, bool value) {
    if ((!value) || (_selectedTool == newTool)) return;
    _selectedTool = newTool;

    _panView.value = (_selectedTool == Tool.PanView);
    _addPoints.value = (_selectedTool == Tool.AddPoints);
    _removePoints.value = (_selectedTool == Tool.RemovePoints);
    _addLines.value = (_selectedTool == Tool.AddLines);
    _removeLines.value = (_selectedTool == Tool.RemoveLines);
    _removeLinesAndTrim.value = (_selectedTool == Tool.RemoveLinesAndTrim);

    _panViewTool.enabled = (_selectedTool == Tool.PanView);
    _pointAdderTool.enabled = (_selectedTool == Tool.AddPoints);
    _pointRemoverTool.enabled = (_selectedTool == Tool.RemovePoints);
    _lineAdderTool.enabled = (_selectedTool == Tool.AddLines);
    _lineRemoverTool.enabled = (_selectedTool == Tool.RemoveLines);
    _lineRemoverAndTrimTool.enabled = (_selectedTool == Tool.RemoveLinesAndTrim);
  }

  void _onValidateChange(bool value) {
    if (value) {
      _validate.value = false;
      _tree.validate();
    }
  }

  void _onPrintTreeChange(bool value) {
    if (value) {
      _printTree.value = false;
      print(_tree.toString());
    }
  }

  void _onClearAllChange(bool value) {
    if (value) {
      _clearAll.value = false;
      _tree.clear();
      _plotItem.updateTree();
      _svgPlot.refresh();
    }
  }
}
