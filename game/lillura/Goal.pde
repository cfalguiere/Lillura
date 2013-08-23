/**
 * materializes the exit 
 */
class Goal extends Being  {
  static final int WIDTH = 30;
  static final int HEIGHT = 30;
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
    fill(_c);
    noStroke();
    _shape.draw();
  }

  public void handleWin() {
     isCompleted = true;
  }

  public void handleReset() {
     isCompleted = false;
  }

}

