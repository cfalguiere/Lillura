class Terrain extends Being {
  
  Terrain(int x, int y) {
        super(new Rectangle(x, y, TERRAIN_WIDTH, TERRAIN_HEIGHT));
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

