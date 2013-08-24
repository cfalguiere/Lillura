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

  
  public void addBlock(PVector aPosition, float aWidth, float aHeight) {
      color randomColor = pickColor();
      Block b = new Block(aPosition, aWidth, aHeight, randomColor);
      _world.register(b);
      add(b);
      blocks.add(b);
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

