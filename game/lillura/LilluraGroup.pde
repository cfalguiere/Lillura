class LilluraGroup extends Group<LilluraBeing> {
  Terrain _terrain;
  
  LilluraGroup(World w, Terrain terrain) {
    super(w);
    _terrain = terrain;
  }

  public void update() {
  }

  
  private color pickColor() {
     return color(int(random(256)), int(random(256)), int(random(256)));
  }

  public void addSquare() {
    int x = (int) (random(_terrain.getBoundingBox().getWidth() -50) + _terrain.getBoundingBox().getAbsMin().x);
    int y = (int) (random(_terrain.getBoundingBox().getHeight() -50) + _terrain.getBoundingBox().getAbsMin().y);
    color randomColor = pickColor();
    LilluraBeing b = new LilluraBeing(x, y, randomColor);
    _world.register(b);
    add(b);
  }

}

