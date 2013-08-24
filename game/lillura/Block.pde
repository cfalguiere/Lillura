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
 
}

