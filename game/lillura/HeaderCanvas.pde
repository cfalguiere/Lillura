class HeaderCanvas extends Being {
  HashMap<String, Rectangle>  boundingBoxes;

  HeaderCanvas(Rectangle boundingBox, HashMap<String, Rectangle>  allBoundingBoxes) {
        super(boundingBox);
        boundingBoxes = allBoundingBoxes;
        println("header canvas created");
  }
  
  public void update() {
    //_stroke = false;
  }

  public void draw() {
      fill(160, 200, 160);
      textSize(48);
      text("Lillura", 5, 40); 
  }
}

