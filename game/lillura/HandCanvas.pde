class HandCanvas extends Being {
  
  HandCanvas(int x, int y, int w, int h) {
        super(new Rectangle(x, y, w, h));
        println("hand canvas created");
  }
  
  public void update() {
    //_stroke = false;
  }

  public void draw() {
        fill(HAND_BG);
        noStroke();
        _shape.draw();
  }
}

