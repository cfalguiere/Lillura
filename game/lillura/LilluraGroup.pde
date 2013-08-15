class LilluraGroup extends Group<LilluraBeing> {
   LilluraGroup(World w) {
    super(w);
  }

  public void update() {
  }

  
  private color pickColor() {
     return color(int(random(256)), int(random(256)), int(random(256)));
  }

  public void addSquare() {
    int x = (int) random(WINDOW_WIDTH - 50);
    int y = (int) random(WINDOW_HEIGHT - 50);
    color randomColor = pickColor();
    LilluraBeing b = new LilluraBeing(x, y, randomColor);
    _world.register(b);
    add(b);
  }

}

