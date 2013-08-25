//
// Controller : support class for controllers
//

class Controller extends HObject implements MessageSubscriber {
    World parentWorld;
    LilluraMessenger messenger;
  
    Controller(World aParentWorld, LilluraMessenger theMessenger) {
         parentWorld = aParentWorld;
         messenger = theMessenger;
    }

    // world delegation
    
    void preUpdate() {
      // override in sub class
    }
    
    //
    // default implementation of message subscriber
    //
    void perCChanged(PerCMessage event) {
      // does nothing
    }
    
    void actionSent(ActionMessage message) {
      // does nothing
    }
 
}

//
// ReplayController : send commands to the robot so that it replays the game level
//

class ReplayController extends Controller {
    RobotProgram program;
  
    ReplayController(RobotProgram aProgram, World aParentWorld, LilluraMessenger theMessenger) {
        super(aParentWorld, theMessenger);
        program = aProgram;
    }

    void preUpdate() {
      
    }
}

//
// RobotMouseMovementController : listen to Mouse events and control the robot movement
//

class RobotMouseMovementController extends Controller {
    Robot robot;
    
    RobotMouseMovementController(Robot aRobot, World aParentWorld, LilluraMessenger theMessenger) {
        super(aParentWorld, theMessenger);
        robot = aRobot;
    }

    public void receive(MouseMessage m) {
      //if (isReplaying) return; //TODO handle replay
      
      if (m.getAction() == POCodes.Click.PRESSED) {
          if (robot.getBoundingBox().contains(mouseX, mouseY)) {
              //println("RobotMouseMovementController received MouseMessage Pause");
              robot.handlePause();
          } else {
              MovementType mt = convertToMovement();
              //println("RobotMouseMovementController received MouseMessage " + mt.name());
              switch (mt) {
                case LEFT:
                   robot.handleTurnLeft();
                   break;
                case RIGHT:
                  robot.handleTurnRight();
                  break;
                case FORWARD:
                  robot.handleGoOn();
                  break;
              }
          }
      }
    } 
  
    MovementType convertToMovement() {
      PVector robotPosition = robot.getPosition();
      float mouseAngle = normAngle(atan2(mouseY-robotPosition.y, mouseX-robotPosition.x));
      //println("mouseAngle " + mouseAngle);    
      float robotOrientation = robot.getOrientation();
      robotOrientation = normAngle(robotOrientation);
      //println("triangleOrientation " + triangleOrientation);    
      float delta = (robotOrientation - mouseAngle);
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

}

//
// RobotKeyMovementController : listen to Key events and control the robot movement
//

class RobotKeyMovementController extends Controller {
    Robot robot;
    
    RobotKeyMovementController(Robot aRobot, World aParentWorld, LilluraMessenger theMessenger) {
        super(aParentWorld, theMessenger);
        robot = aRobot;
    }
    
    public void receive(KeyMessage m) { //FIXME generates a command, and update do the switch
      //if (isReplaying) return; //TODO replay
      
      RobotAction currentAction = robot.getCurrentAction();
      
      int code = m.getKeyCode();
      if (m.isPressed()) {
        switch (code) {
          case POCodes.Key.SPACE:
            robot.handlePause();
            break;
          case POCodes.Key.LEFT:
            if (currentAction==null || robot.getCurrentAction().isDistinct(MovementType.LEFT, millis())) {
                robot.handleTurnLeft();
            }
            break;
          case POCodes.Key.RIGHT:
            if (currentAction==null || robot.getCurrentAction().isDistinct(MovementType.RIGHT, millis())) {
              robot.handleTurnRight();
            }
            break;
          case POCodes.Key.UP:
            robot.handleGoOn();
            break;
          default:
            // go ahead
            break;
        }
      }
    }

}


//
// RobotPerceptualMovementController : listen to perceptual events and control the robot movement
//

class RobotPerceptualMovementController extends Controller {
    Robot robot;
    
    RobotPerceptualMovementController(Robot aRobot, World aParentWorld, LilluraMessenger theMessenger) {
        super(aParentWorld, theMessenger);
        robot = aRobot;
    }
  
    void perCChanged(PerCMessage handSensor) {
      //if (isReplaying) return;
  
      if (handSensor.isHandOpen() && !handSensor.isTooFar()) {
          robot.handleGoOn();
      }
    }
   
}
