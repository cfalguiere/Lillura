
class Hand extends Being implements PerCSubscriber {
  static final int WIDTH = 30;
  static final int HEIGHT = 50;
  
  int col;
  int handX;
  int handY;
  int handW;
  
  Hand(int x, int y, int w, int h) {
    super(new Rectangle(x, y, w, h));
  }


  int flipXAxisAndScale(float x) { //flip our X axis by using the map fuction
    int canvasWidth = (int)getBoundingBox().getWidth();
    return (int)map(x, 0, CAMERA_WIDTH/2, canvasWidth, 0);
  }
  int scaleYAxis(float y) { //flip our X axis by using the map fuction
    int canvasHeight = (int)getBoundingBox().getHeight();
    return (int)map(y*2, 0, CAMERA_HEIGHT, 0, canvasHeight); 
  }

  void perCChanged(PerCMessage event) {
    println("received perc changed " + event);
  }

  public void draw() {
    fill(col, 90, 30); 
    ellipse(handX, handY, handW, handW*2);
  }
}

