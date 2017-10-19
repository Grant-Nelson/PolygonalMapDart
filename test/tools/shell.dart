part of tests;

void shell(html.Element elem) {
  html.BodyElement body = html.document.body;
  body.style
    ..backgroundColor = "#FFFFFF"
    ..margin = "40px"
    ..padding = "0";

  html.DivElement scrollTop = new html.DivElement();
  scrollTop.style
    ..position = "fixed"
    ..width = "100%"
    ..height = "100%"
    ..left = "0px"
    ..top = "0px"
    ..zIndex = "-1"
    ..backgroundColor = "rgb(10,100,100)";
  body.append(scrollTop);

  html.DivElement scrollPage = new html.DivElement();
  scrollPage.style
    ..position = "relative"
    ..textAlign = "center";
  body.append(scrollPage);

  html.DivElement pageCenter = new html.DivElement();
  pageCenter.style
    ..textAlign = "center"
    ..marginLeft = "auto"
    ..marginRight = "auto"
    ..marginTop = "40px"
    ..marginBottom = "40px"
    ..padding = "40px"
    ..background = "rgba(255,255,255,0.8)"
    ..boxShadow = "3px 3px 4px 2px rgba(0,0,0,0.5)";
  scrollPage.append(pageCenter);

  html.document.title = "Unit-tests";

  if (elem != null) {
    html.DivElement elemContainer = new html.DivElement();
    pageCenter.append(elemContainer);
    elemContainer.append(elem);

    html.DivElement endPage = new html.DivElement();
    endPage.style
      ..display = "block"
      ..clear = "both";
    elemContainer.append(endPage);
  }

  html.document.onScroll.listen((_) {
    scrollTop.style.top = "${-0.05*body.scrollTop}px";
  });
}
