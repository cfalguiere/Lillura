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

  
  public void addBlock(PVector position) {
      color randomColor = pickColor();
      Block b = new Block(position.x, position.y, randomColor);
      _world.register(b);
      add(b);
      blocks.add(b);
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
     float sum = 0;
     float grey = 0;
     color c = color(128);
     while (sat < 64 || sat > 192 || sum < 96 || sum > 192*3 || grey < 32) {
       int r = int(random(0, 256));
       int g = int(random(0, 256));
       int b = int(random(0, 256));
       
       c = color(r, g, b);
       sat = saturation(c);
       sum = r + g + b;
       grey = abs(r-g) + abs(g-b) + abs(b-r); 
     }
     return c;
  }


}

