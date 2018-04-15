part of main;

enum Tool { None, PanView, AddPolygon, CheckRegion }

class Driver {
  plotSvg.PlotSvg _svgPlot;
  qtPlot.QuadTreePlotter _plot;
  maps.Regions _regions;
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
  BoolValue _addPolygon1;
  BoolValue _addPolygon2;
  BoolValue _addPolygon3;
  BoolValue _addPolygon4;
  BoolValue _addPolygon5;
  BoolValue _checkRegion;
  BoolValue _validate;
  BoolValue _printTree;
  BoolValue _clearAll;

  Tool _selectedTool;
  plotter.MousePan _shiftPanViewTool;
  plotter.MousePan _panViewTool;
  PolygonAdder _polygonAdderTool;
  RegionChecker _regionCheckTool;

  Driver(this._svgPlot, this._plot) {
    _regions = new maps.Regions();

    _plotItem = _plot.addTree(_regions.tree);
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
    _addPolygon1 = new BoolValue(false)..onChange.add(_onAddPolygon1Change);
    _addPolygon2 = new BoolValue(false)..onChange.add(_onAddPolygon2Change);
    _addPolygon3 = new BoolValue(false)..onChange.add(_onAddPolygon3Change);
    _addPolygon4 = new BoolValue(false)..onChange.add(_onAddPolygon4Change);
    _addPolygon5 = new BoolValue(false)..onChange.add(_onAddPolygon5Change);
    _checkRegion = new BoolValue(false)..onChange.add(_onCheckRegion);
    _validate = new BoolValue(false)..onChange.add(_onValidateChange);
    _printTree = new BoolValue(false)..onChange.add(_onPrintTreeChange);
    _clearAll = new BoolValue(false)..onChange.add(_onClearAllChange);

    _shiftPanViewTool = new plotter.MousePan(_plot, new plotter.MouseButtonState(0, shiftKey: true));
    _panViewTool = new plotter.MousePan(_plot, new plotter.MouseButtonState(0));
    _polygonAdderTool = new PolygonAdder(_regions, _plot, _plotItem,
      new plotter.MouseButtonState(0), new plotter.MouseButtonState(0, ctrlKey: true));
    _regionCheckTool = new RegionChecker(_regions, _plot, _plotItem);

    _plot.MouseHandles
      ..clear()
      ..add(_shiftPanViewTool)
      ..add(_panViewTool)
      ..add(_polygonAdderTool)
      ..add(_regionCheckTool)
      ..add(new plotter.MouseCoords(_plot));
    _plot.focusOnBounds(new plotter.Bounds(-100.0, -100.0, 100.0, 100.0));
    _setTool(Tool.AddPolygon, true, 1);
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
  BoolValue get addPolygon1 => _addPolygon1;
  BoolValue get addPolygon2 => _addPolygon2;
  BoolValue get addPolygon3 => _addPolygon3;
  BoolValue get addPolygon4 => _addPolygon4;
  BoolValue get addPolygon5 => _addPolygon5;
  BoolValue get checkRegion => _checkRegion;
  BoolValue get validate => _validate;
  BoolValue get printTree => _printTree;
  BoolValue get clearAll => _clearAll;

  void _onCenterViewChange(bool value) {
    if (value) {
      _centerView.value = false;
      qt.Boundary bounds = _regions.tree.boundary;
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

  void _onAddPolygon1Change(bool value) {
    _setTool(Tool.AddPolygon, value, 1);
  }

  void _onAddPolygon2Change(bool value) {
    _setTool(Tool.AddPolygon, value, 2);
  }

  void _onAddPolygon3Change(bool value) {
    _setTool(Tool.AddPolygon, value, 3);
  }

  void _onAddPolygon4Change(bool value) {
    _setTool(Tool.AddPolygon, value, 4);
  }

  void _onAddPolygon5Change(bool value) {
    _setTool(Tool.AddPolygon, value, 5);
  }

  void _onCheckRegion(bool value) {
    _setTool(Tool.CheckRegion, value);
  }

  void _setTool(Tool newTool, bool value, [int regionId = 0]) {
    if (!value) return;
    _selectedTool = newTool;

    _panView.value = (_selectedTool == Tool.PanView);
    _addPolygon1.value = (_selectedTool == Tool.AddPolygon) && (regionId == 1);
    _addPolygon2.value = (_selectedTool == Tool.AddPolygon) && (regionId == 2);
    _addPolygon3.value = (_selectedTool == Tool.AddPolygon) && (regionId == 3);
    _addPolygon4.value = (_selectedTool == Tool.AddPolygon) && (regionId == 4);
    _addPolygon5.value = (_selectedTool == Tool.AddPolygon) && (regionId == 5);
    _checkRegion.value = (_selectedTool == Tool.CheckRegion);

    _panViewTool.enabled = (_selectedTool == Tool.PanView);
    _polygonAdderTool.enabled = (_selectedTool == Tool.AddPolygon);
    _polygonAdderTool.enabled = (_selectedTool == Tool.AddPolygon);
    _regionCheckTool.enabled = (_selectedTool == Tool.CheckRegion);
    
    if (_selectedTool == Tool.AddPolygon) {
      _polygonAdderTool.finishRegion();
      _polygonAdderTool.regionId = regionId;
      _svgPlot.refresh();
    }
  }

  void _onValidateChange(bool value) {
    if (value) {
      _validate.value = false;
      _regions.tree.validate();
    }
  }

  void _onPrintTreeChange(bool value) {
    if (value) {
      _printTree.value = false;
      print(_regions.tree.toString());
    }
  }

  void _onClearAllChange(bool value) {
    if (value) {
      _clearAll.value = false;
      _regions.tree.clear();
      _polygonAdderTool.reset();
      _plotItem.updateTree();
      _svgPlot.refresh();
    }
  }
}
