part of main;

enum Tool { AddPoints, RemovePoints, AddLines, RemoveLines }

class Driver {
  plotter.Plotter _plot;
  qt.QuadTree _tree;

  BoolValue _points;
  BoolValue _lines;
  BoolValue _emptyNodes;
  BoolValue _branchNodes;
  BoolValue _passNodes;
  BoolValue _pointNodes;

  BoolValue _addPoints;
  BoolValue _removePoints;
  BoolValue _addLines;
  BoolValue _removeLines;

  Tool _selectedTool;

  Driver(this._plot) {
    this._tree = new qt.QuadTree();

    _points = new BoolValue(true);
    _lines = new BoolValue(true);
    _emptyNodes = new BoolValue(true);
    _branchNodes = new BoolValue(true);
    _passNodes = new BoolValue(true);
    _pointNodes = new BoolValue(true);

    _addPoints = new BoolValue(false, true);
    _removePoints = new BoolValue(false);
    _addLines = new BoolValue(false);
    _removeLines = new BoolValue(false);

    _selectedTool = Tool.AddPoints;

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
