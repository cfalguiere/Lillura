/**
 * materializes the exit 
 */
class Goal extends Being  {
  static final int WIDTH = 50;
  static final int HEIGHT = 35;
  static final int DEFAULT_COLOR = 127; 
  
  boolean isCompleted = false;
  color _c;
  Rectangle  parentBoundingBox;
  
  Goal(PVector position, Rectangle theParentBoundingBox) {
        super(new Rectangle(position, WIDTH, HEIGHT));
        _c = color(DEFAULT_COLOR );
        println("creating goal");
        parentBoundingBox = theParentBoundingBox;
  }

  public void draw() {
    //drawBoxForDebug();
    noFill();
    strokeWeight(3);
    stroke(_c);
    //_shape.draw();
    float w =  _shape.getBoundingBox().getWidth();
    float h =  _shape.getBoundingBox().getHeight();
    //line(0, 0, w, 0);
    line(0, 0, 0, h);
    line(w, 0, w, h);
  }

  private void drawBoxForDebug() {
      stroke(color(256,0,0));
      noFill();
      _shape.draw();
  }

  public void handleWin() {
     isCompleted = true;
  }

  public void handleReset(PVector aNewPosition) {
     isCompleted = false;
     
     _position.set(aNewPosition);
  }

  boolean contains(Being being) {
      boolean b = getShape().getBoundingBox().contains(being.getShape().getBoundingBox());
      if (b) println("goal contains " + being);
      return b;
  }
  
  boolean collide(Being being) {
      return getShape().collide(being.getShape());
  }
  

}

