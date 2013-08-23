class HeaderCanvas extends Being {
  
  HeaderCanvas(Rectangle boundingBox) {
        super(boundingBox);
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

