part of tests;

class points {
  points._();

  static List<qt.Point> parse(String pnts) {
    RegExp exp = new RegExp(r"(-?[0-9]+)");
    Iterable<Match> matches = exp.allMatches(pnts);
    List<qt.Point> result = new List<qt.Point>();
    for (int i = 1; i < matches.length; i += 2) {
      String xStr = matches.elementAt(i - 1).group(0).toString();
      String yStr = matches.elementAt(i).group(0).toString();
      int x = int.parse(xStr.trim());
      int y = int.parse(yStr.trim());
      result.add(new qt.Point(x, y));
    }
    return result;
  }

  static String format(List<qt.Point> pnts) {
    String result = "{";
    int pntsLen = pnts.length;
    for (int i = 0; i < pntsLen; ++i) {
      if (i != 0) result += ", ";
      result += "[${pnts[i].x}, ${pnts[i].y}]";
    }
    return result + "}";
  }

  static bool equals(List<qt.Point> a, List<qt.Point> b) {
    int aLen = a.length;
    if (aLen != b.length) return false;
    for (int i = 0; i < aLen; ++i) {
      if (a[i].x != b[i].x) return false;
      if (a[i].y != b[i].y) return false;
    }
    return true;
  }
}
