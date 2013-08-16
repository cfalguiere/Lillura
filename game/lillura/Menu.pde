class Menu extends Being {
  
  Menu(int x, int y) {
        super(new Rectangle(x, y, LEFT_PANEL_WIDTH , TERRAIN_HEIGHT));
        println("creating menu");
  }
  
  public void update() {
    //_stroke = false;
  }

  public void draw() {
        fill(color(64,64,64));
        noStroke();
        _shape.draw();
  }

  public PVector getPosition() {
    return _position;
  }
}

