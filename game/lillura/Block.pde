/**
 * Block placed on the terrain
 */
class Block extends Being {
  final color RED = color(256,0,0);
  color _c;
  boolean _stroke = false;
  
  Polygon house;

  Block(PVector aPosition, float aWidth, float aHeight, color pc) {
        super(new Rectangle(aPosition, aWidth, aHeight));
        _c = pc;
        //Add your constructor info here
        println("creating bloc at " + aPosition);
        
        initializeHouse(aWidth, aHeight);
  }
  
  void initializeHouse(float aWidth, float aHeight) { //FIXME create HouseShape
        ArrayList<PVector> points = new ArrayList<PVector>();
        points.add(new PVector(0, aHeight)); // bottom  left
        int roofHeight = (int)aHeight*2/5;
        points.add(new PVector(0, roofHeight)); // left wall
        points.add(new PVector((int)aWidth/2, 0)); // left side of the roof
        points.add(new PVector((int)aWidth*4/6, (int)roofHeight/3)); // right side of the roof
        points.add(new PVector((int)aWidth*4/6, 0)); // left side of chimney
        points.add(new PVector((int)aWidth*5/6, 0)); // top of chimney
        points.add(new PVector((int)aWidth*5/6, roofHeight*2/3)); // right side of chimney
        points.add(new PVector(aWidth, roofHeight)); // right side of the roof
        points.add(new PVector(aWidth, aHeight)); // bottom  right
        house =  new Polygon(new Rectangle(_shape.getPosition(), aWidth, aHeight).getCenter(), points);
  }


  public void update() {
    //_stroke = false;
  }

  public void draw() {
        fill(_c);
        if(_stroke) {
            strokeWeight(5);
            stroke(RED);
        } else {
            noStroke();
        }       
        //_shape.draw();
        house.draw();
  }
  
  public void handleProtect() {
    _stroke = true;
  }
 
  public void reset() {
    _stroke = false;
  }
 
}

//
// BlockGroup
//

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
  

  public void resetAllBlocks() {
      for (Block b : getObjects()) {
          b.reset();
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

