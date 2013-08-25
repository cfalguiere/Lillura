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
       
        initializeTriangleUp();
        previousAction = new RobotAction(MovementType.NONE, millis(), position);
  }
  
  void initializeTriangleUp() {
    triangleOrientation = -HALF_PI + TWO_PI;
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
    if (isOn) {
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
     isOn = false;
     println("PAUSE");
     sendActionCompleted();
     currentAction = new RobotAction(MovementType.NONE, millis(), _position);
  }
  
  public void handleTurnRight() {
      sendActionCompleted();
      currentAction = new RobotAction(MovementType.RIGHT, millis(), _position);
      isOn = true;
      _velocity.rotate(HALF_PI);
      triangleOrientation = (triangleOrientation + HALF_PI) % TWO_PI;
      createTriangle(triangleOrientation); 
  }
  
  public void handleTurnLeft() {
      sendActionCompleted();
      currentAction = new RobotAction(MovementType.LEFT, millis(), _position);
      isOn = true;
      _velocity.rotate(-HALF_PI);
      triangleOrientation = (triangleOrientation - HALF_PI) % TWO_PI;
      createTriangle(triangleOrientation); 
  }
  
  public void handleGoOn() {
      if (currentAction == null || currentAction.movementType == MovementType.NONE) {
        currentAction = new RobotAction(MovementType.FORWARD, millis(), _position);
        //println("CREATE currentAction " + currentAction.movementType.name() + " "+ currentAction.startPosition);
      }
      isOn = true;
  }
  
  public void handleStop() {
      //if (!isGameOver) 
      // sendActionCompleted();
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
    if (currentAction != null) currentAction.endPosition = _position;
    if (currentAction != null && currentAction.movementType != MovementType.NONE) {
         //println("SEND " + currentAction.movementType.name() + " " + currentAction.startPosition + " -> " +  currentAction.endPosition  + " distance " + currentAction.distance());
         messenger.sendMessage(new ActionMessage(EventType.ROBOT_ACTION_COMPLETED, currentAction));
         previousAction = currentAction;
    }
  }

  public void receive(KeyMessage m) { //FIXME generates a command, and update do the switch
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
      if (_shape.getBoundingBox().contains(mouseX, mouseY)) {
        handlePause();
      } else {
        MovementType mt = convertToMovement();
        switch (mt) {
          case LEFT:
             handleTurnLeft();
             break;
          case RIGHT:
            handleTurnRight();
            break;
          case FORWARD:
            handleGoOn();
            break;
        }
      }
    }
  }
  
  MovementType convertToMovement() {
    float mouseAngle = normAngle(atan2(mouseY-_position.y, mouseX-_position.x));
    //println("mouseAngle " + mouseAngle);    
    triangleOrientation = normAngle(triangleOrientation);
    //println("triangleOrientation " + triangleOrientation);    
    float delta = (triangleOrientation - mouseAngle);
    //println("delta " + delta + " Q "  + HALF_PI  + "  " + PI + " "  + 3*PI/2);    
    MovementType mt = MovementType.NONE;
    if (abs(delta) < HALF_PI/2) {
      // going up 3PI/2 click ahead 3PI/2 delta 0
      mt = MovementType.FORWARD;
    } else {
      if (delta<0) delta+=TWO_PI;
      // going up 3PI/2 click back PI/2 delta  PI
      if (abs(delta-3*PI/2) < HALF_PI) {
        // going up 3PI/2 click right 0 delta 3PI/2 == -PI/2
        // going right 0 click right PI/2 delta  -PI/2 
        // going left PI click right 3PI/2 delta -PI/2
        mt = MovementType.RIGHT;
      } else if (abs(delta-HALF_PI) < HALF_PI) {
        // going up 3PI/2 click left PI delta  PI/2
        // going right 0 click left 3PI/2  delta -3PI/2 = PI/2
        // going left PI click left PI/2  delta PI/2
        mt = MovementType.LEFT;
      } 
    }  
    return mt;
  }
  
  float normAngle(float aRad) {
    float rad =  aRad;
    if (rad < 0) rad += TWO_PI;
    rad %= TWO_PI;
    return rad;
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
  PVector endPosition;
  
  RobotAction(MovementType aMovementType, long theTimeStarted, PVector theStartPosition) {
    movementType = aMovementType;
    timeStarted = theTimeStarted;
    startPosition = new PVector();
    startPosition.set(theStartPosition);
  }
  
  public boolean isDistinct(MovementType aMovementType, long aTime) {
    return movementType != aMovementType || timeStarted+STABILIZER <  aTime;
  }
  
  int distance() {
    return int(abs(startPosition.x -  endPosition.x + startPosition.y -  endPosition.y));
  }
}

