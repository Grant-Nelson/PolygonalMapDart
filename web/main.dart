library main;

import 'dart:html' as html;

void addExamples(html.DivElement elem) {
  addExample(elem, "pointsLines");
}

void main() {
  html.DivElement elem = new html.DivElement();
  addExamples(elem);

  html.DivElement scrollPage = new html.DivElement();
  scrollPage.className = "scroll_page";

  html.DivElement pageCenter = new html.DivElement();
  pageCenter.className = "page_center";
  scrollPage.append(pageCenter);

  html.DivElement elemContainer = new html.DivElement();
  pageCenter.append(elemContainer);
  elemContainer.append(elem);

  html.DivElement endPage = new html.DivElement();
  endPage.className = "end_page";
  elemContainer.append(endPage);

  html.document.title = "Examples";
  html.BodyElement body = html.document.body;
  body.append(scrollPage);
}

void addExample(html.Element elem, String expName) {
  html.ImageElement img = new html.ImageElement()
    ..alt = "$expName"
    ..src = "./$expName/tn.png";

  html.AnchorElement a = new html.AnchorElement()
    ..href = "./$expName/"
    ..children.add(img);

  html.DivElement innerBox = new html.DivElement()
    ..className = "exp-link"
    ..children.add(a);

  html.DivElement outterBox = new html.DivElement()
    ..className = "exp-box"
    ..children.add(innerBox);

  elem.children.add(outterBox);
}
