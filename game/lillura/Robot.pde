/**
 * Template being
 */
class Robot extends Being implements PerCSubscriber {
  static final int WIDTH = 30;
  static final int HEIGHT = 30;
  static final int SPEED = 1;
  static final int DEFAULT_COLOR = 127; 
  color _c;
  boolean _isOn = false;
  boolean _isGameOver = false;
  PVector _velocity = PVector.fromAngle(-HALF_PI); // (0,-1)

  Robot(int x, int y, World w) {
        super(new Rectangle(x, y, WIDTH, HEIGHT));
        _c = color(DEFAULT_COLOR );
        //Add your constructor info here
        println("creating robot at " + x + " " + y);
        
        w.subscribe(this, POCodes.Key.UP);
        w.subscribe(this, POCodes.Key.LEFT);
        w.subscribe(this, POCodes.Key.RIGHT);
        w.subscribe(this, POCodes.Key.SPACE);
        //w.subscribe(this, POCodes.Button.LEFT, robot.getShape());
        w.subscribe(this, POCodes.Button.LEFT);
  }

  public void update() {
    if (_isOn && !_isGameOver) {
      _position.add(_velocity);
    }
  }

  public void draw() {
    if (_isGameOver) {
        fill(color(256,0,0));
    } else {
        fill(_c);
    }
    noStroke();
    _shape.draw();
  }
  
    
  private color defaultColor() {
     return color(int(random(256)), int(random(256)), int(random(256)));
  }
  
  public void handleStop() {
    _isGameOver = true;
  }

  public void receive(KeyMessage m) {
    int code = m.getKeyCode();
    if (m.isPressed()) {
      _isOn = (code == POCodes.Key.SPACE?false:true);

      switch (code) {
        case POCodes.Key.LEFT:
          _velocity.rotate(-HALF_PI);
          break;
        case POCodes.Key.RIGHT:
          _velocity.rotate(HALF_PI);
          break;
        default:
          // go ahead
          break;
      }
    }
  }
  
  public void receive(MouseMessage m) {
    if (m.getAction() == POCodes.Click.PRESSED) {
        _isOn = false;
    }
  }

  void perCChanged(PerCMessage handSensor) {
    _isOn = handSensor.isHandOpen();
  }

}

