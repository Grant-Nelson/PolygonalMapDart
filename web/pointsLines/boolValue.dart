part of main;

typedef void OnBoolValueChange(bool newValue);

class BoolValue {
  bool _toggle;
  bool _value;
  List<OnBoolValueChange> _changed;

  BoolValue(bool toggle, [bool value = false]) {
    _toggle = toggle;
    _value = value;
    _changed = new List<OnBoolValueChange>();
  }

  void onClick() {
    if (_toggle) {
      value = !_value;
    } else {
      value = true;
    }
  }

  void set value(bool value) {
    if (_value != value) {
      _value = value;
      for (OnBoolValueChange hndl in _changed) {
        hndl(_value);
      }
    }
  }

  bool get value => _value;

  List<OnBoolValueChange> get onChange => _changed;
}
