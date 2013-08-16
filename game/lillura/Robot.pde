/**
 * Template being
 */
class Robot extends Being {
  static final int WIDTH = 30;
  static final int HEIGHT = 30;
  static final int SPEED = 1;
  static final int DEFAULT_COLOR = 127; 
  color _c;
  boolean _isOn = false;
  Direction _direction = Direction.UP;

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
    if (! _isOn) return;
    
    // TODO move vector 
    
    if (_direction == Direction.UP) {
        _position.y -= SPEED;    
    }
    
    if (_direction == Direction.LEFT) {
          _position.x -= SPEED;    
    }

    if (_direction == Direction.RIGHT) {
          _position.x += SPEED;    //TODO PVector
    }
  }

  public void draw() {
        fill(_c);
        noStroke();
        _shape.draw();
  }
  
    
  private color defaultColor() {
     return color(int(random(256)), int(random(256)), int(random(256)));
  }
  
  public void handleStop() {
    _isOn = false;
  }

  public void receive(KeyMessage m) {
    int code = m.getKeyCode();
    if (m.isPressed()) {
      if (code == POCodes.Key.UP) {
        _isOn = true;
      } 
      if (code == POCodes.Key.LEFT) {
        _isOn = true;
        _direction = Direction.LEFT;  
      } 
      if (code == POCodes.Key.RIGHT) {
        _isOn = true;
        _direction = Direction.RIGHT;  
      } 
      if (code == POCodes.Key.SPACE) {
        _isOn = false;
      } 
    }
  }
  
  public void receive(MouseMessage m) {
    if (m.getAction() == POCodes.Click.PRESSED) {
        _isOn = false;
    }
  }

}

