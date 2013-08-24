class BlockGroup extends Group<Block> {
  Rectangle boundingBox;
  
  ArrayList<Block> blocks; // FIXME getObjects seems empty
  
  BlockGroup(World aParentWorld, Rectangle aBoundingBox) {
    super(aParentWorld);
    boundingBox = aBoundingBox;
    blocks = new ArrayList<Block>();
  }

  public void update() {
  }

  
  public void addBlock() {
    int x = (int) (random(boundingBox.getWidth() -50) + boundingBox.getAbsMin().x);
    int y = (int) (random(boundingBox.getHeight() -200) + boundingBox.getAbsMin().y + 100);
    color randomColor = pickColor();
    Block b = new Block(x, y, randomColor);
    avoidCollision(b);
    _world.register(b);
    add(b);
    blocks.add(b);
  }


  public void avoidCollision(Block newBlock) {
    boolean hasMoved = true;
    int i=0;
    while (hasMoved) {
      hasMoved = false;
      //println(" " + blocks.size() + " blocks");
      for (Block block : blocks) {
          //println("check");
        if (block.getShape().collide(newBlock.getShape())) {
          PVector move = block.getShape().projectionVector(newBlock.getShape());
          newBlock.getPosition().add(move);
          hasMoved = (i<10?true:false);
          println("moved");
        }
      }
      i++;
    }
  }
  

  private color pickColor() {
     float sat = 0;
     color c = color(128);
     while (sat < 64 || sat > 128) {
       c = color(int(random(256)), int(random(256)), int(random(256)));
       sat = saturation(c);
     }
     return c;
  }


}

