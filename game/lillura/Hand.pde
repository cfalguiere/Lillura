
class Hand extends Being  {
  static final int WIDTH = 30;
  static final int HEIGHT = 50;
  
  int col;
  int handX;
  int handY;
  int handW;
  
  Hand(int x, int y, int w, int h) {
    super(new Rectangle(x, y, w, h));
  }


 /*
  synchronized public void receivePerCMessage(PXCMGesture.GeoNode handSensor) {
    println(handSensor);
    float openness = map(handSensor.openness, 0, 100, 0, 255);
    col = (int)openness;
    
    handX = flipXAxisAndScale(handSensor.positionImage.x); 
    handY = scaleYAxis(handSensor.positionImage.y); 
    
    handW = (int)map(handSensor.positionWorld.y, 0, 1, 30, 0);

  }*/

  int flipXAxisAndScale(float x) { //flip our X axis by using the map fuction
    int canvasWidth = (int)getBoundingBox().getWidth();
    return (int)map(x, 0, CAMERA_WIDTH/2, canvasWidth, 0);
  }
  int scaleYAxis(float y) { //flip our X axis by using the map fuction
    int canvasHeight = (int)getBoundingBox().getHeight();
    return (int)map(y*2, 0, CAMERA_HEIGHT, 0, canvasHeight); 
  }

  public void update() {
  }

  public void draw() {
    fill(col, 90, 30); 
    ellipse(handX, handY, handW, handW*2);
  }
}

