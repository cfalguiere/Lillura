//
// Hand : manage the hand representation
//

class Hand extends Being implements MessageSubscriber {
  static final int WIDTH = 30;
  static final int HEIGHT = 50;
  
  int handX;
  int handY;
  int handW;
  int handH;
  float openness;
  boolean _isTooFar;
  int _c;

  Hand(int x, int y, int w, int h) {
    super(new Rectangle(x, y, w, h));
    //warning the boundingbox equals the canvas
    _c = color(256,256,256);
    println("hand created");
  }

  
  public void update() {
    if (_isTooFar) {    //_stroke = false;
      _c = color(90, 90, 90); 
    } else {
      int redValue = (int)map(openness, 0, 100, 0, 255);
      _c = color(redValue, 90, 30); 
    }
    handH = (int)(handW*map(openness, 0, 100, 1, 2));
  }

  int flipXAxisAndScale(float x) { //flip our X axis by using the map fuction
    int canvasWidth = (int)getBoundingBox().getWidth();
    return (int)map(x, 0, CAMERA_WIDTH/2, canvasWidth, 0);
  }
  
  int scaleYAxis(float y) { //flip our X axis by using the map fuction
    int canvasHeight = (int)getBoundingBox().getHeight();
    return (int)map(y*2, 0, CAMERA_HEIGHT, 0, canvasHeight); 
  }


  public void draw() {
    fill(_c); 
    ellipse(handX, handY, handW, handH);
  }
  
  //
  // behavior
  //
  
  void actionSent(ActionMessage event) {
    // don't care
  }

  void perCChanged(PerCMessage handSensor) {
    //println("received perc changed " + handSensor);
    openness = handSensor.openness;
    
    handX = flipXAxisAndScale(handSensor.x); 
    handY = scaleYAxis(handSensor.y); 
    
    handW = (int)map(handSensor.depth, 0, 1, 30, 0);
    
    _isTooFar = handSensor.isTooFar();
  }

}

//
// HandCanvas : manage the background
//

class HandCanvas extends Being implements MessageSubscriber {
  boolean isOn = true;
  
  HandCanvas(int x, int y, int w, int h) {
        super(new Rectangle(x, y, w, h));
        println("hand canvas created");
  }
  
  public void update() {
    //_stroke = false;
  }

  public void draw() {
        fill(HAND_BG);
        noStroke();
        _shape.draw();
        
        if (isOn) 
          fill(color(0,256,0));
        else 
          fill(color(256,0,0));
        textSize(10);  
        text((isOn?"ON":"OFF"), 5, 10);
        
  }
  
    void actionSent(ActionMessage message) {
        switch(message.eventType) {
            case PERCEPTUAL_MODE_SWITCH:
                isOn = ! isOn;
                println("Perceptual switched mode");
                break;
        }
    }
    
    void perCChanged(PerCMessage handSensor) {
    }

}


