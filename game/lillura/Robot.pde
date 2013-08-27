/**
 * Template being
 */
class Robot extends Being  {
  static final int WIDTH = 30;
  static final int HEIGHT = 30;
  static final int SPEED = 1;
  final PVector UP_VELOCITY  = PVector.fromAngle(-HALF_PI); // (0,-1)

  LilluraMessenger messenger;

  boolean isOn = false;
  boolean isGameOver = false;
  boolean hasCompleted = false;
  boolean isReset = false;
  boolean isReplaying = false; //TODO state machine
  PVector _velocity = UP_VELOCITY;
  PVector zero;
  
  RobotShape robotShape;

  RobotPath path;

  RobotAction currentAction;
  RobotAction previousAction;

  Robot(PVector position, World w, LilluraMessenger theMessenger, RobotPath aPath) {  //FIxME decouping of robotpath
      super(new Rectangle(position, WIDTH, HEIGHT));
      messenger = theMessenger;
      path = aPath;
      
      zero = new PVector();
      zero.set(position);
      //Add your constructor info here
      println("creating robot");

      robotShape = new RobotShape(new Rectangle(position, WIDTH, HEIGHT));
      
      previousAction = new RobotAction(MovementType.NONE, millis(), position);
  }
  
  public void update() {
    if (isOn || isReplaying) {
        //println("robot before update " + this);
        _position.add(_velocity);
        //path.addPoint(_position);
        //println("robot after update " + this);
    }
    
    if (isReset) {
      _position.set(zero);
      isReset = false;
    }
    
    if (isGameOver) {
        robotShape.setColorToBroken();
    } else  if (hasCompleted) {
        robotShape.setColorToCompleted();
    } else {
        robotShape.setColorToDefault();
    }

  }

  public void draw() {
    //drawBoxForDebug();
    robotShape.draw();
  }
  
  private void drawBoxForDebug() {
      stroke(color(256,0,0));
      noFill();
      _shape.draw();
  }
  
  public void handlePause() {
      isOn = false;
      sendActionCompleted();
      currentAction = new RobotAction(MovementType.NONE, millis(), _position);
  }
  
  public void handleTurnRight() {
      sendActionCompleted();
      currentAction = new RobotAction(MovementType.TURN_RIGHT, millis(), _position);
      isOn = true;
      _velocity.rotate(HALF_PI);
      robotShape.rotateRight();
  }
  
  public void handleTurnLeft() {
      sendActionCompleted();
      currentAction = new RobotAction(MovementType.TURN_LEFT, millis(), _position);
      isOn = true;
      _velocity.rotate(-HALF_PI);
      robotShape.rotateLeft();
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
    _velocity = UP_VELOCITY;
    robotShape.reset();
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
   
    public void handleStopReplay() {
       isReplaying = false;
    }
   
   
    private void sendActionCompleted() {
      if (currentAction != null) currentAction.endPosition = _position;
      if (currentAction != null && currentAction.movementType != MovementType.NONE) {
           //println("SEND " + currentAction.movementType.name() + " " + currentAction.startPosition + " -> " +  currentAction.endPosition  + " distance " + currentAction.distance());
           messenger.sendMessage(new ActionMessage(EventType.ROBOT_ACTION_COMPLETED, currentAction));
           previousAction = currentAction;
      }
    }

    public float  getOrientation() {
      return robotShape.getOrientation();
    }
    
    public RobotAction  getCurrentAction() {
      return currentAction;
    }
    
    public void replay(MovementType mvt) {
      switch (mvt) {
       case FORWARD:
          _velocity = UP_VELOCITY;
          break;
        case TURN_LEFT:
          _velocity.rotate(-HALF_PI);
          break;
        case TURN_RIGHT:
          _velocity.rotate(HALF_PI);
          break;
        default:
          //ignore
      }
    }
    
    String toString() {
        return "[Robot " + (isOn?"ON":"OFF") + " position " + _position + " ]";
    }

}

//
// RobotShape : draw the robot
//

class RobotShape {
    static final float INITIAL_ORIENTATION = -HALF_PI;
    static final int DEFAULT_COLOR = 127; 

    Rectangle boundingBox;
    float orientation;
    Polygon triangle;
    color c;
    
    RobotShape(Rectangle aBoundingBox) {
        boundingBox = aBoundingBox;
        orientation = INITIAL_ORIENTATION;
        initialize();
        setColorToDefault();
    }
    
    void initialize() {
        ArrayList<PVector> points = new ArrayList<PVector>();
        float angle = orientation;
        float w = boundingBox.getWidth();
        float h = boundingBox.getHeight();
        for (int i=0; i<3; i++, angle+=TWO_PI/3) {
          PVector vertex1 = PVector.fromAngle(angle);
          vertex1.mult(w/2);
          vertex1.add(new PVector(w/2, h/2));
          points.add(vertex1);
        } 
        triangle =  new Polygon(getCenter(), points);
    }

    public void rotateRight() {
        orientation = (orientation + HALF_PI) % TWO_PI;
        initialize();
    }
    
    public void rotateLeft() {
        orientation = (orientation - HALF_PI) % TWO_PI;
        initialize();
    }

    public void reset() {
        orientation = INITIAL_ORIENTATION;
        initialize();
    }

    public void setColorToBroken() {
      c = color(256,0,0);
    }
    
    public void setColorToCompleted() {
      c = color(GREEN);
    }
    
    public void setColorToDefault() {
        c = color(DEFAULT_COLOR);
    }

    PVector getCenter() {
      return boundingBox.getCenter();
    }
    
    public float getOrientation() {
        return orientation;
    }
    
    public void draw() {
      pushMatrix();
      fill(c);
      noStroke();
      triangle.draw();
      popMatrix();
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
  
  String toString() {
    return "[ RobotAction " + movementType.name() + " " + startPosition + " -> " + endPosition  + " ]";
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
  
  String toString() {
    return "[ RobotOperation " + movementType.name() + " " + distance + " ]";
  }
}

//
// RobotProgram : a list of RobotOperation with operation index
// 

class RobotProgram {
  ArrayList<RobotOperation> program;
  
  RobotProgram() {
    program = new ArrayList<RobotOperation>();
  }
  
  void addOperation(RobotOperation anOperation) {
    program.add(anOperation);
  }  
  
  int getNbLines() {
    return program.size();
  }
  
  RobotOperation getOperation(int line) {
    return program.get(line);
  }  
  
  String toString() {
    return "[ RobotProgram " + program.size() + " operations ]";
  }
}

//
// RobotProgramPlayer : play the robot program
// 

class RobotProgramPlayer {
    LilluraMessenger messenger;
    RobotProgram program;
    Robot robot;
    int currentLine = 0;
    RobotOperation currentOperation;
    int remainingDistance;
    boolean isCompleted;
    
    RobotProgramPlayer(Robot aRobot, RobotProgram aProgram, LilluraMessenger theMessenger) {
        program = aProgram;
        robot = aRobot;
        messenger = theMessenger;
        
        currentLine = 0;
        isCompleted = false;
    }
  
    boolean preUpdate() {
        if (remainingDistance == 0) pickNextOperation();
        if (!isCompleted) runStep();
        return !isCompleted;
    }
    
    void whenProgramCompleted() {
          isCompleted = true;
          messenger.sendMessage(new ActionMessage(EventType.ROBOT_PROGRAM_COMPLETED));
    }
    
    void pickNextOperation() {
       if (currentLine == program.getNbLines()) {
            whenProgramCompleted();
        } else {
            currentOperation = program.getOperation(currentLine);
            remainingDistance = currentOperation.distance;
            println(this);
        }
        currentLine++;
     }
    
    void runStep() {
        robot.replay(currentOperation.movementType);
        remainingDistance--;
    }
    
    String toString() {
        return "[ RobotProgramPlayer " + currentLine + " of " + program + " " +  (isCompleted?"DONE":"RUNNING") +" ]";
    }
  
}


