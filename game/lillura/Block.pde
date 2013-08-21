/**
 * Block placed on the terrain
 */
class Block extends Being {
  static final int WIDTH = 50;
  static final int HEIGHT = 50;
  final color RED = color(256,0,0);
  color _c;
  boolean _stroke = false;
  
  Polygon house;

  Block(int x, int y, color pc) {
        super(new Rectangle(x, y, WIDTH, HEIGHT));
        _c = pc;
        //Add your constructor info here
        println("creating bloc at " + x + " " + y);
        
        initializeHouse();
  }
  
  void initializeHouse() {
        ArrayList<PVector> points = new ArrayList<PVector>();
        points.add(new PVector(0, HEIGHT)); // bottom  left
        int roofHeight = (int)HEIGHT*2/5;
        points.add(new PVector(0, roofHeight)); // left wall
        points.add(new PVector((int)WIDTH/2, 0)); // left side of the roof
        points.add(new PVector((int)WIDTH*4/6, (int)roofHeight/3)); // right side of the roof
        points.add(new PVector((int)WIDTH*4/6, 0)); // left side of chimney
        points.add(new PVector((int)WIDTH*5/6, 0)); // top of chimney
        points.add(new PVector((int)WIDTH*5/6, roofHeight*2/3)); // right side of chimney
        points.add(new PVector(WIDTH, roofHeight)); // right side of the roof
        points.add(new PVector(WIDTH, HEIGHT)); // bottom  right
        house =  new Polygon(new Rectangle(_shape.getPosition(), WIDTH, HEIGHT).getCenter(), points);
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

