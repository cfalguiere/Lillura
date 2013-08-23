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
    if (isCompleted) {
      fill(0, 102, 153, 204);
      textSize(64);
      text("You Win !", -parentBoundingBox.getWidth()/4, parentBoundingBox.getHeight()/2); 
    }
  }

  public void handleWin() {
     isCompleted = true;
  }

  public void handleReset() {
     isCompleted = false;
  }

}

