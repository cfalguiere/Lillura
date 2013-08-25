/**
 * Template being
 */
class Robot extends Being  {
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
  boolean isReplaying = false; //TODO state machine
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
    isReplaying = false;
  }

  
  public void handleReplay(RobotProgram program) {
     handleReset();
     isReplaying = true;
  }
   
  private void sendActionCompleted() {
    if (currentAction != null) currentAction.endPosition = _position;
    if (currentAction != null && currentAction.movementType != MovementType.NONE) {
         //println("SEND " + currentAction.movementType.name() + " " + currentAction.startPosition + " -> " +  currentAction.endPosition  + " distance " + currentAction.distance());
         messenger.sendMessage(new ActionMessage(EventType.ROBOT_ACTION_COMPLETED, currentAction));
         previousAction = currentAction;
    }
  }

    PVector getCenter() {
      return new Rectangle(_shape.getPosition(), WIDTH, HEIGHT).getCenter();
    }
  
    public float  getOrientation() {
      return triangleOrientation;
    }
    
    public RobotAction  getCurrentAction() {
      return currentAction;
    }
    

}

//
// RobotAction : keep track of the current movement of the robot in order to create a card
// 

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

//
// RobotOperation : an action to be done by the robot
// 

class RobotOperation {
  
  MovementType movementType;
  int distance;
  
  RobotOperation(MovementType aMovementType, int aDistance) {
    movementType = aMovementType;
    distance = aDistance;
  }
}

//
// RobotProgram : a list of RobotOperation with operation index
// 

class RobotProgram {
  ArrayList<RobotOperation> program;
  int currentLine = 0;
  
  RobotProgram() {
    program = new ArrayList<RobotOperation>();
  }
  
  void addOperation(RobotOperation anOperation) {
    program.add(anOperation);
  }  
  
  void run() {
    currentLine = 0;
  }
  
  
  boolean hasMoreOperation() {
    return currentLine < program.size();
  }
  
  RobotOperation readOperation() {
    return program.get(currentLine++);
  }
  
}


