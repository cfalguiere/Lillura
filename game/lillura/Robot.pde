/**
 * Template being
 */
class Robot extends Being implements MessageSubscriber {
  static final int WIDTH = 30;
  static final int HEIGHT = 30;
  static final int SPEED = 1;
  static final int DEFAULT_COLOR = 127; 
  final PVector UP_VELOCITY  = PVector.fromAngle(-HALF_PI); // (0,-1)

  LilluraMessenger messenger;

  boolean isOn = false;
  boolean isGameOver = false;
  boolean isReset = false;
  color _c;
  PVector _velocity = UP_VELOCITY;
  PVector zero;
  
  Polygon triangle;

  Robot(PVector position, World w, LilluraMessenger theMessenger) {
        super(new Rectangle(position, WIDTH, HEIGHT));
        messenger = theMessenger;
        
        _c = color(DEFAULT_COLOR );
        zero = new PVector();
        zero.set(position);
        //Add your constructor info here
        println("creating robot");
        
        w.subscribe(this, POCodes.Key.UP);
        w.subscribe(this, POCodes.Key.LEFT);
        w.subscribe(this, POCodes.Key.RIGHT);
        w.subscribe(this, POCodes.Key.SPACE);
        //w.subscribe(this, POCodes.Button.LEFT, robot.getShape());
        w.subscribe(this, POCodes.Button.LEFT);
        
        initializeTriangle();
  }
  
  void initializeTriangle() {
        ArrayList<PVector> points = new ArrayList<PVector>();
        points.add(new PVector(0, HEIGHT)); // bottom  left
        points.add(new PVector(WIDTH, HEIGHT)); // bottom  right
        points.add(new PVector((int)WIDTH/2, 0)); // top
        triangle =  new Polygon(getCenter(), points);
  }

//fixme depends on actual direction
  void initializeTriangleRight() {
        ArrayList<PVector> points = new ArrayList<PVector>();
        points.add(new PVector(0, 0)); // top  left
        points.add(new PVector(WIDTH, (int)HEIGHT/2)); // top
        points.add(new PVector(0, HEIGHT)); // bottom  left
        triangle =  new Polygon(getCenter(), points);
  }

  void initializeTriangleLeft() {
        ArrayList<PVector> points = new ArrayList<PVector>();
        points.add(new PVector(WIDTH, 0)); // top  right
        points.add(new PVector(0, (int)HEIGHT/2)); // top
        points.add(new PVector(WIDTH, HEIGHT)); // bottom  right
        triangle =  new Polygon(getCenter(), points);
  }

  PVector getCenter() {
    return new Rectangle(_shape.getPosition(), WIDTH, HEIGHT).getCenter();
  }
  
  public void update() {
    if (isOn && !isGameOver) {
      _position.add(_velocity);
    }
    if (isReset) {
      _position.set(zero);
      isReset = false;
    }
  }

  public void draw() {
    if (isGameOver) {
        fill(color(256,0,0));
    } else {
        fill(_c);
    }
    noStroke();
    _shape.draw();
    //triangle.draw();
  }
  
    
  private color defaultColor() {
     return color(int(random(256)), int(random(256)), int(random(256)));
  }
  
  public void handlePause() {
     isOn = false;
     messenger.sendActionMessage(ActionMessage.ACTION_COMPLETED);
  }
  
  public void handleTurnRight() {
      isOn = true;
      _velocity.rotate(HALF_PI);
      initializeTriangleRight();
  }
  
  public void handleTurnLeft() {
      isOn = true;
      _velocity.rotate(-HALF_PI);
      initializeTriangleLeft();
  }
  
  public void handleGoOn() {
      isOn = true;
  }
  
  public void handleStop() {
    isGameOver = true;
  }
  
  public void handleReset() {
    println("resetting robot");
    initializeTriangle();
    isOn = false;
    isGameOver = false;
    isReset = true;
  }

  public void receive(KeyMessage m) {
    int code = m.getKeyCode();
    if (m.isPressed()) {
      switch (code) {
        case POCodes.Key.SPACE:
          handlePause();
          break;
        case POCodes.Key.LEFT:
          handleTurnLeft();
          break;
        case POCodes.Key.RIGHT:
          handleTurnRight();
          break;
        case POCodes.Key.UP:
          handleGoOn();
          break;
        default:
          // go ahead
          break;
      }
    }
  }
  
  public void receive(MouseMessage m) {
    if (m.getAction() == POCodes.Click.PRESSED) {
      handlePause();
    }
  }

  void perCChanged(PerCMessage handSensor) {
    isOn = handSensor.isHandOpen() && !handSensor.isTooFar();
  }

  void actionSent(ActionMessage event) {
    // don't care
  }

}

