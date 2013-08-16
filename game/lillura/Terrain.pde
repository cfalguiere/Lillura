class Terrain extends Being {
  
  Terrain(int x, int y, int w, int h) {
        super(new Rectangle(x, y, w, h));
        println("creating terrain");
  }
  
  public void update() {
    //_stroke = false;
  }

  public void draw() {
        fill(color(256,256,256));
        noStroke();
        _shape.draw();
  }

}

