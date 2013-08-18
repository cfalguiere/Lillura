class BlockGroup extends Group<Block> {
  Rectangle boundingBox;
  
  BlockGroup(World aParentWorld, Rectangle aBoundingBox) {
    super(aParentWorld);
    boundingBox = aBoundingBox;
  }

  public void update() {
  }

  
  public void addBlock() {
    int x = (int) (random(boundingBox.getWidth() -50) + boundingBox.getAbsMin().x);
    int y = (int) (random(boundingBox.getHeight() -50) + boundingBox.getAbsMin().y);
    color randomColor = pickColor();
    Block b = new Block(x, y, randomColor);
    _world.register(b);
    add(b);
  }

  private color pickColor() {
     return color(int(random(256)), int(random(256)), int(random(256)));
  }


}

