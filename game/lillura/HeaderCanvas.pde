class HeaderCanvas extends Being {
  
  static final int MARKER_HEIGHT = 3;

  HashMap<String, Rectangle>  boundingBoxes;
  HeaderMarker marker;

  HeaderCanvas(Rectangle boundingBox, HashMap<String, Rectangle>  allBoundingBoxes) {
        super(boundingBox);
        boundingBoxes = allBoundingBoxes;
        println("header canvas created");
  }
  
  public void update() {
    Rectangle selectedArea = getSelectedArea();
    
    float x = selectedArea.getAbsMin().x - _shape.getBoundingBox().getAbsMin().x;
    float y = _shape.getBoundingBox().getHeight();
    marker = new HeaderMarker(x, y, selectedArea.getWidth(), MARKER_HEIGHT, GOLD_75);
  }
  
  private Rectangle getSelectedArea() {
    PVector mouseVector = new PVector(mouseX, mouseY);
    Rectangle selectedArea = boundingBoxes.get(GAME_LEVEL_BBOX);
    for(Rectangle  area : boundingBoxes.values()) {
      if (area.contains(mouseX, mouseY)) {
        selectedArea = area;
      }
    }
    return selectedArea;
  }

  public void draw() {
      fill(GOLD);
      textSize(48);
      text("Lillura", 5, 40); 
      if (marker != null) {
        marker.draw();
      }
  }
}

class HeaderMarker  {
  float x;
  float y;
  float w;
  float h;
  color c;
  
  HeaderMarker(float aX, float aY, float aWidth, float aHeight, color aColor) {
    x = aX;
    y = aY;
    w = aWidth;
    h = aHeight;
    c = aColor;
  }
  
  public void draw() {
    stroke(c);
    strokeWeight(h);
    line(x, y, x+w, y);
  }

}

