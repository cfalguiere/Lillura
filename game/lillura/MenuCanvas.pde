class MenuCanvas extends Being {
  
  MenuCanvas(int x, int y, int w, int h) {
        super(new Rectangle(x, y, w, h));
        println("creating menu canvas");
  }
  
  public void update() {
    //_stroke = false;
  }

  public void draw() {
        fill(LIGHT_GREY);
        noStroke();
        _shape.draw();
  }
}

