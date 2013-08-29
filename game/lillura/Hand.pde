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
  
  String label = "";
  int state = -1;

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
        pushMatrix();
        fill(_c); 
        noStroke();
        if (state == 1) {
            drawThumbUp();
        } else if (state == 2) {
            drawPeace();
        } else {
            ellipse(handX, handY, handW, handH);
        }
        
        textSize(10);
        text(label, handX + handW*0.7, handY); // FIXME magic numbers
        popMatrix();
    }
  
    public void drawThumbUp() {
        ellipse(handX, handY, handW, handW*.8);
        stroke(_c);
        strokeWeight(5);
        line(handX + handW*.2 , handY, handX + handW*.2, handY  - handW*0.7);
    }
    
    public void drawPeace() {
        ellipse(handX, handY, handW, handW*.8);
        stroke(_c);
        strokeWeight(5);
        line(handX + handW*.2 , handY, handX + handW*.2, handY  - handW*0.8);
        line(handX - handW*.2 , handY, handX - handW*.2, handY  - handW*0.8);
    }
    
    //
    // behavior
    //
  
    void actionSent(ActionMessage message) {
        switch(message.eventType) {
            case PERCEPTUAL_HAND_OPEN:
                openness = 90;
                state = 8;
                break;
            case PERCEPTUAL_HAND_CLOSE:
                openness = 10;
                state = 0;
                break;
            case PERCEPTUAL_THUMB_UP:
                label = "T";
                state = 1;
                break;
            case PERCEPTUAL_PEACE:
                label = "P";
                state = 2;
                break;
            case PERCEPTUAL_HAND_MOVED_CLOSER:
                label = "_";
                break;
            default:
                label = "";
                break;
        }
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
  boolean isPerceptualOn = true;
  
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
        
        if (isPerceptualOn) 
            fill(color(0,256,0));
        else 
            fill(color(256,0,0));
        textSize(10);  
        text((isPerceptualOn?"ON":"OFF"), 5, 10);
        
  }
  
    void actionSent(ActionMessage message) {
        switch(message.eventType) {
            case PERCEPTUAL_MODE_ON:
                isPerceptualOn = true;
                break;
            case PERCEPTUAL_MODE_OFF:
                isPerceptualOn = false;
                break;
        }
    }
    
    void perCChanged(PerCMessage handSensor) {
    }

}


