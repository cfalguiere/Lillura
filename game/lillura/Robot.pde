/**
 * Template being
 */
class Robot extends Being implements MessageSubscriber {
  static final int COMMAND_PAUSE = 0;
  static final int COMMAND_UP = 1;
  static final int COMMAND_LEFT = 2;
  static final int COMMAND_RIGHT = 3;
  
  static final int WIDTH = 30;
  static final int HEIGHT = 30;
  static final int SPEED = 1;
  static final int DEFAULT_COLOR = 127; 
  final PVector UP_VELOCITY  = PVector.fromAngle(-HALF_PI); // (0,-1)

  LilluraMessenger messenger;

  boolean isOn = false;
  boolean isGameOver = false;
  boolean hasCompleted = false;
  boolean isReset = false;
  color _c;
  PVector _velocity = UP_VELOCITY;
  PVector zero;
  float triangleOrientation;
  
  Polygon triangle;
  RobotPath path;

  RobotAction currentAction;
  RobotAction previousAction;

  Robot(PVector position, World w, LilluraMessenger theMessenger, RobotPath aPath) {  //FIxME decouping of robotpath
        super(new Rectangle(position, WIDTH, HEIGHT));
        messenger = theMessenger;
        path = aPath;
        
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
        
        initializeTriangleUp();
        currentAction = new RobotAction(MovementType.NONE, millis(), _position);
        previousAction = currentAction;
  }
  
  void initializeTriangleUp() {
    triangleOrientation = -HALF_PI;
    createTriangle(triangleOrientation); 
  }
  
  void createTriangle(float angle) {
        ArrayList<PVector> points = new ArrayList<PVector>();
        for (int i=0; i<3; i++, angle+=TWO_PI/3) {
          PVector vertex1 = PVector.fromAngle(angle);
          vertex1.mult(WIDTH/2);
          vertex1.add(new PVector(WIDTH/2, HEIGHT/2));
          points.add(vertex1);
        } 
        triangle =  new Polygon(getCenter(), points);
  }




  PVector getCenter() {
    return new Rectangle(_shape.getPosition(), WIDTH, HEIGHT).getCenter();
  }
  
  public void update() {
    if (isOn && !isGameOver) {
      _position.add(_velocity);
      //path.addPoint(_position);
    }
    if (isReset) {
      _position.set(zero);
      isReset = false;
    }
  }

  public void draw() {
    //drawBoxForDebug();
    
    if (isGameOver) {
        fill(color(256,0,0));
    } else  if (hasCompleted) {
        fill(GREEN);
    } else {
        fill(_c);
    }
    noStroke();
    triangle.draw();
  }
  
  private void drawBoxForDebug() {
     stroke(color(256,0,0));
    noFill();
    _shape.draw();
  }
    
  private color defaultColor() {
     return color(int(random(256)), int(random(256)), int(random(256)));
  }
  
  public void handlePause() {
     currentAction = new RobotAction(MovementType.NONE, millis(), _position);

     isOn = false;
     sendActionCompleted();
  }
  
  public void handleTurnRight() {
      currentAction = new RobotAction(MovementType.RIGHT, millis(), _position);
      isOn = true;
      _velocity.rotate(HALF_PI);
      triangleOrientation += HALF_PI;
      createTriangle(triangleOrientation); 
      sendActionCompleted();
  }
  
  public void handleTurnLeft() {
      currentAction = new RobotAction(MovementType.LEFT, millis(), _position);
      isOn = true;
      _velocity.rotate(-HALF_PI);
      triangleOrientation += -HALF_PI;
      createTriangle(triangleOrientation); 
      sendActionCompleted();
  }
  
  public void handleGoOn() {
      currentAction = new RobotAction(MovementType.FORWARD, millis(), _position);
      isOn = true;
  }
  
  public void handleStop() {
      if (!isGameOver) 
       sendActionCompleted();
      isGameOver = true;
      isOn = false;
  }
  
  public void handleCompleted() {
      if (!hasCompleted) 
       sendActionCompleted();
      hasCompleted = true;
      isOn = false;
  }
  
  public void handleReset() {
    currentAction = new RobotAction(MovementType.NONE, millis(), _position);
    previousAction = currentAction;
    println("resetting robot");
    initializeTriangleUp();
    isOn = false;
    isGameOver = false;
    hasCompleted = false;
    isReset = true;
  }

  
  private void sendActionCompleted() {
    if (previousAction.movementType != MovementType.NONE) 
     messenger.sendMessage(new ActionMessage(ActionMessage.ACTION_COMPLETED, previousAction.movementType));
  }

  public void receive(KeyMessage m) { //FIXME generates a command, and update do the switch
    previousAction = currentAction;
    int code = m.getKeyCode();
    if (m.isPressed()) {
      switch (code) {
        case POCodes.Key.SPACE:
          handlePause();
          break;
        case POCodes.Key.LEFT:
          if (currentAction.isDistinct(MovementType.LEFT, millis())) {
              handleTurnLeft();
          }
          break;
        case POCodes.Key.RIGHT:
          if (currentAction.isDistinct(MovementType.RIGHT, millis())) {
            handleTurnRight();
          }
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

class RobotAction {
  static final int STABILIZER = 100; // in ms
  
  MovementType movementType;
  long timeStarted;
  PVector startPosition;
  
  RobotAction(MovementType aMovementType, long theTimeStarted, PVector theStartPosition) {
    movementType = aMovementType;
    timeStarted = theTimeStarted;
    startPosition = new PVector();
    startPosition.set(theStartPosition);
  }
  
  public boolean isDistinct(MovementType aMovementType, long aTime) {
    return movementType != aMovementType || timeStarted+STABILIZER <  aTime;
  }
  
  
}

