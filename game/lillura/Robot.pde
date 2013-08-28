/**
 * Template being
 */
class Robot extends Being  {
    static final int WIDTH = 30;
    static final int HEIGHT = 30;
  
    PVector zero;
    
    RobotState robotState;
    RobotDirection robotDirection;
    RobotShape robotShape;
  
    RobotAction currentAction;
    RobotAction previousAction;
    RobotTracker robotTracker;
    int nbSteps;

    Robot(PVector position, World w, RobotTracker aRobotTracker) {  
        super(new Rectangle(position, WIDTH, HEIGHT));
        robotTracker = aRobotTracker;
  
        //Add your constructor info here
        println("creating robot");
        
        zero = new PVector();
        zero.set(position);
  
        robotState = new RobotState();
        robotDirection = new RobotDirection();
        robotShape = new RobotShape(new Rectangle(position, WIDTH, HEIGHT), robotDirection, robotState);
        
        previousAction = new RobotAction(MovementType.NONE, millis(), position);
        
        nbSteps = 0;
    }
  
  public void update() {
    if (robotState.canMove()) {
        //println("robot before update " + this);
        _velocity.set(robotDirection.velocity);
        _position.add(_velocity);
        //println("robot after update " + this);
        nbSteps = (nbSteps + 1) % 10;
        if (nbSteps == 0) robotTracker.trackPath(_position);
    } else {
        _velocity.set(new PVector(0,0));
    }
    
    robotShape.update();

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
      robotState.state = RobotState.WAITING;
      notifyActionCompleted();
      currentAction = new RobotAction(MovementType.NONE, millis(), _position);
  }
  
  public void handleTurnRight() {
      notifyActionCompleted();
      currentAction = new RobotAction(MovementType.TURN_RIGHT, millis(), _position);
      robotState.state = RobotState.STEERABLE;
      robotDirection.turnRight();
  }
  
  public void handleTurnLeft() {
      notifyActionCompleted();
      currentAction = new RobotAction(MovementType.TURN_LEFT, millis(), _position);
      robotState.state = RobotState.STEERABLE;
      robotDirection.turnLeft();
  }
  
  public void handleGoOn() {
      if (currentAction == null || currentAction.movementType == MovementType.NONE) {
        currentAction = new RobotAction(MovementType.FORWARD, millis(), _position);
        //println("CREATE currentAction " + currentAction.movementType.name() + " "+ currentAction.startPosition);
      }
      robotState.state = RobotState.STEERABLE;
  }
  
  public void handleStop() {
      robotState.state = RobotState.CRASHED;
  }
  
  public void handleCompleted() {
      if (robotState.state != RobotState.PARKED) {
         notifyActionCompleted();
         robotState.state = RobotState.PARKED;
      }
  }
  
    public void handleReset() {
        currentAction = new RobotAction(MovementType.NONE, millis(), _position);
        previousAction = currentAction;
        _position.set(zero);
        robotTracker.reset();
        nbSteps = 0;
        robotState.reset();
        robotDirection.reset();
        robotShape.reset();
    }

  
    public void handleReplay() {
       handleReset();
       robotState.state = RobotState.REPLAYING;
    }
   
    public void handleStopReplay() {
       robotState.state = RobotState.WAITING;
    }
   
   
    public float  getOrientation() {
      return robotDirection.orientation;
    }

    private void notifyActionCompleted() {
      if (currentAction != null) currentAction.endPosition =  _position;
      if (currentAction != null && currentAction.movementType != MovementType.NONE) {
           robotTracker.completedAction(currentAction);
           previousAction = currentAction;
      }
    }

    
    public RobotAction  getCurrentAction() {
      return currentAction;
    }
    
    public void replay(MovementType mvt) {
      switch (mvt) {
       case FORWARD:
          break;
        case TURN_LEFT:
          println("in replay before turn left " + robotDirection);
          robotDirection.turnLeft();
          println("in replay after turn left  " + robotDirection);
          break;
        case TURN_RIGHT:
          println("in replay before turn right  " + robotDirection);
          robotDirection.turnRight();
          println("in replay after turn right " + robotDirection);
          break;
        default:
          //ignore
      }
    }
    
    String toString() {
        return "Robot:[ " + robotState + " " + robotDirection + " position:" + _position + " ]";
    }

}

//
// RobotState
//

public class  RobotState {
    static final int WAITING = 0;
    static final int STEERABLE = 1;
    static final int REPLAYING = 2;
    static final int CRASHED = 3;
    static final int PARKED = 4;
    final String[] labels = {"WAITING", "STEERABLE", "REPLAYING", "CRASHED", "PARKED"};
    int state;
    
    RobotState() {
        reset();
    }
    
    void reset() {
        state = WAITING;
    }
    
    boolean canMove() {
        return state == STEERABLE || state == REPLAYING;
    }
    
    String toString() {
      return labels[state];
    }
}

//
// RobotDirection
//

class RobotDirection {
    static final int SPEED = 1;
    static final float DEFAULT_ORIENTATION = -HALF_PI; 
    final PVector UP_VELOCITY  = PVector.fromAngle(DEFAULT_ORIENTATION); // (0,-1)

    float orientation;
    PVector velocity;
    
    RobotDirection() {
        reset();
    }
    
    void reset() {
        forward();   
    }
    
    void forward() {
        orientation = DEFAULT_ORIENTATION;
        velocity = UP_VELOCITY;     
    }
    
    void turnLeft() {
        orientation -= HALF_PI;
        velocity.rotate(-HALF_PI);
    }
    
    void turnRight() {
        orientation += HALF_PI;
        velocity.rotate(HALF_PI);
    }
    
    String toString() {
      return "RobotDirection:[ " + orientation + " velocity:" + velocity + " ]"; 
    }
}

//
// RobotShape : draw the robot
//

class RobotShape {
    static final int DEFAULT_COLOR = 127; 

    Rectangle boundingBox;
    RobotDirection robotDirection;
    RobotState robotState;
    float currentDirection;
    Polygon triangle;
    color c;
    
    RobotShape(Rectangle aBoundingBox, RobotDirection aRobotDirection, RobotState aRobotState) {
        boundingBox = aBoundingBox;
        robotDirection = aRobotDirection;
        robotState = aRobotState;
        reset();
    }

    void reset() {
        initialize();
        setColorToDefault();
    }
    
    void initialize() {
        currentDirection = robotDirection.orientation;
        ArrayList<PVector> points = new ArrayList<PVector>();
        float angle = currentDirection;
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

    public void setColorToBroken() {
      c = color(256,0,0);
    }
    
    public void setColorToReplaying() {
      c = color(92,128,256);
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
    
    public void update() {
      if (currentDirection != robotDirection.orientation) initialize();
      
      switch (robotState.state) {
          case RobotState.CRASHED:
              setColorToBroken();
              break;
          case RobotState.PARKED:
              setColorToCompleted();
              break;
          case RobotState.REPLAYING:
              setColorToReplaying();
              break;
          default:
              setColorToDefault();
      } 

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
  PVector startCoordinates;
  PVector endCoordinates;
  
  RobotAction(MovementType aMovementType, long theTimeStarted, PVector theStartPosition) {
    movementType = aMovementType;
    timeStarted = theTimeStarted;
    startPosition = new PVector();
    startPosition.set(theStartPosition);
  }
  
  public boolean isDistinct(MovementType aMovementType, long aTime) {
    return movementType != aMovementType || timeStarted+STABILIZER <  aTime;
  }
  
  int actualDistance() {
    return int(abs(startPosition.x -  endPosition.x + startPosition.y -  endPosition.y));
  }
  
  int distance() {
    return int(abs(startCoordinates.x -  endCoordinates.x + startCoordinates.y -  endCoordinates.y));
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
    return "RobotOperation:[ " + movementType.name() + " " + distance + " ]";
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
    return "RobotProgram:[ " + program.size() + " operations ]";
  }
}

//
// RobotProgramPlayer : play the robot program
// 

class RobotProgramPlayer {
    LilluraMessenger messenger;
    RobotProgram program;
    PVector cellSize;
    Robot robot;
    
    int currentLine = 0;
    RobotOperation currentOperation;
    int remainingDistance;
    boolean isCompleted;
    
    RobotProgramPlayer(Robot aRobot, RobotProgram aProgram, PVector aCellSize, LilluraMessenger theMessenger) {
        program = aProgram;
        robot = aRobot;
        cellSize = aCellSize;
        messenger = theMessenger;
        
        currentLine = 0;
        isCompleted = false;
    }
  
    boolean preUpdate() {
        if (remainingDistance == 0) {
            pickNextOperation();
        } else if (!isCompleted) {
            runNextStep();
        }
        
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
            try {
                currentOperation = program.getOperation(currentLine);
                println("starting " + currentOperation);
                remainingDistance = int(currentOperation.distance * cellSize.x); //FIXME won't work if cell is not square
                runFirstStep();
                println(this);
            } catch (IndexOutOfBoundsException e) {
                whenProgramCompleted(); //FIXME can't figure out why
            }
        }
        currentLine++;
     }
    
    void runFirstStep() {
        robot.replay(currentOperation.movementType);
        remainingDistance--;
    }
    
    void runNextStep() {
        robot.replay(MovementType.FORWARD);
        remainingDistance--;
    }
    
    String toString() {
        return "RobotProgramPlayer:[ " + currentLine + " of " + program + " " +  (isCompleted?"DONE":"RUNNING") +" ]";
    }
  
}



class RobotTracker extends Being {
    LilluraMessenger messenger;

    ConcurrentLinkedQueue<PVector> path;
    PVector translation;
    GridLayoutManager grid;
    
    RobotTracker(Rectangle aBoundingBox, LilluraMessenger theMessenger, GridLayoutManager aGrid) {
        super(aBoundingBox);
        grid = aGrid;
        messenger = theMessenger;
        path = new ConcurrentLinkedQueue<PVector>();
        translation = new PVector(- _shape.getBoundingBox().getAbsMin().x + Robot.WIDTH/2, - _shape.getBoundingBox().getAbsMin().y + Robot.HEIGHT/2);
    }

    private void completedAction(RobotAction currentAction) {
        PVector startCoordinates = grid.getCoordinates(currentAction.startPosition);
        currentAction.startCoordinates = startCoordinates;
        println("startCoordinates " + startCoordinates);
        PVector endCoordinates = grid.getCoordinates(currentAction.endPosition);
        currentAction.endCoordinates = endCoordinates;
        println("endCoordinates " + endCoordinates);
        
        messenger.sendMessage(new ActionMessage(EventType.ROBOT_ACTION_COMPLETED, currentAction));
    }

    public void draw() {
        stroke(color(256,0,0));
        strokeWeight(3);
        
        pushMatrix();
        translate(translation.x, translation.y);
        PVector v = null;
        Iterator<PVector> it = path.iterator();
        while (it.hasNext()) {
            v = it.next();
            point(v.x, v.y);
        }
        popMatrix();
    }
    
    void reset() {
        path = new ConcurrentLinkedQueue<PVector>();
    }
    
    void trackPath(PVector aPosition) {
        PVector vertex = new PVector();
        vertex.set(aPosition);
        path.add(vertex);
    }

}

