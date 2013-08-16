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
    int x = (int) (random(TERRAIN_WIDTH - 50) + _terrain.getPosition().x);
    int y = (int) random(TERRAIN_HEIGHT - 50);
    color randomColor = pickColor();
    LilluraBeing b = new LilluraBeing(x, y, randomColor);
    _world.register(b);
    add(b);
  }

}

