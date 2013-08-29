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
      
      if (m.getButton() != POCodes.Button.LEFT) {
          return;
      }
      
      if (m.getAction() == POCodes.Click.PRESSED) {
          if (robot.getBoundingBox().contains(mouseX, mouseY)) {
              //println("RobotMouseMovementController received MouseMessage Pause");
              robot.handlePause();
          } else {
              MovementType mt = convertToMovement();
              //println("RobotMouseMovementController received MouseMessage " + mt.name());
              switch (mt) {
                case TURN_LEFT:
                   robot.handleTurnLeft();
                   break;
                case TURN_RIGHT:
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
          mt = MovementType.TURN_RIGHT;
        } else if (abs(delta-HALF_PI) < HALF_PI) {
          // going up 3PI/2 click left PI delta  PI/2
          // going right 0 click left 3PI/2  delta -3PI/2 = PI/2
          // going left PI click left PI/2  delta PI/2
          mt = MovementType.TURN_LEFT;
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
      if (! isActive) return;

      //if (isReplaying) return; //TODO replay
      
      RobotAction currentAction = robot.getCurrentAction();
      
      int code = m.getKeyCode();
      if (m.isPressed()) {
          switch (code) {
              case POCodes.Key.SPACE:
                  robot.handlePause();
                  break;
              case POCodes.Key.LEFT:
                  if (currentAction==null || robot.getCurrentAction().isDistinct(MovementType.TURN_LEFT, millis())) {
                      robot.handleTurnLeft();
                  }
                  break;
              case POCodes.Key.RIGHT:
                  if (currentAction==null || robot.getCurrentAction().isDistinct(MovementType.TURN_RIGHT, millis())) {
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
    float lastMouseX;
    EventType handOpennessStatus;
    
    RobotPerceptualMovementController(Robot aRobot, World aParentWorld, LilluraMessenger theMessenger) {
        super(aParentWorld, theMessenger);
        robot = aRobot;
    }
  
    void perCChanged(PerCMessage handSensor) {
      if (! isActive) return;
      
      if (! robot.robotState.isSteerable()) return;
  
      if (handSensor.isHandOpen() && !handSensor.isTooFar()) {
          robot.handleGoOn();
      } else {
          robot.handlePause();
      }
    }

    void actionSent(ActionMessage message) {
        if (! isActive) return;

        switch(message.eventType) {
            case PERCEPTUAL_THUMB_UP:
                if (robot.robotState.isOff()) {
                    robot.handleGoOn();
                    robot.handlePause();
                } else {
                  robot.handlePause();
                  robot.robotState.state = RobotState.OFF;
                }
                break;
            case PERCEPTUAL_HAND_MOVED_CLOSER:
                if (handOpennessStatus == EventType.PERCEPTUAL_HAND_OPEN) {
                    if (robot.robotState.isOff()) {
                        robot.handleGoOn();
                        robot.handlePause();
                    } else {
                        robot.handleGoOn();
                    }
                }
                break;
            default:
              // ignore other events
        }
        
        if (robot.robotState.isSteerable()) {
            handleRoboMovementEvents(message);
        }

    }
    
    private void handleRoboMovementEvents(ActionMessage message) {
        switch(message.eventType) {
            case PERCEPTUAL_HAND_OPEN:
                robot.handleGoOn();
                handOpennessStatus = message.eventType;
                break;
            case PERCEPTUAL_HAND_CLOSE:
                robot.handlePause();
                handOpennessStatus = message.eventType;
                break;
            case PERCEPTUAL_PEACE:
                robot.robotState.state = RobotState.OFF;
                break;
            case PERCEPTUAL_HAND_MOVED_CENTER:
                robot.handleGoOn();
                break;
            case PERCEPTUAL_HAND_MOVED_RIGHT:
                robot.handleTurnRight();
                break;
            case PERCEPTUAL_HAND_MOVED_LEFT:
                robot.handleTurnLeft();
                break;
            case PERCEPTUAL_HAND_MOVED_BOTTOM_LEFT:
                robot.handleReset();
                break;
            default:
                // ignore other events
        }
    }
}



