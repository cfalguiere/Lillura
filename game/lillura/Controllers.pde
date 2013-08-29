//
// Controller : support class for controllers
//

class Controller extends HObject implements MessageSubscriber {
    World parentWorld;
    LilluraMessenger messenger;
    boolean isActive = true;
  
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
 
    void enable() {
        isActive = true;
        //println("Controller " + getClass().getName() + " is enabled");
    }
 
    void disable() {
        isActive = false;
        //println("Controller " + getClass().getName() + " is disabled");
    }
    
    String toString() {
        return getClass().getName() + ":[ " + (isActive?"ACTIVE":"INACTIVE") + " ]";
    }
}

//
//
//

class GeneralKeyController extends Controller { 
    boolean isDebugModeOn = false;
    boolean isPerceptualModeOn = true;

    GeneralKeyController(World aParentWorld, LilluraMessenger theMessenger) {
        super(aParentWorld, theMessenger);
    }
  
    public void receive(KeyMessage m) { //FIXME generates a command, and update do the switch
        int code = m.getKeyCode();
        if (m.isPressed()) {
            switch (code) {
                case POCodes.Key.D:
                    switchDebugMode();
                    break;
                case POCodes.Key.P:
                    switchPerceptualMode();
                    break;
              default:
                  // ignore other events
            }
        }
    }   
    
    void switchDebugMode() {
        isDebugModeOn = ! isDebugModeOn;
        String label = (isDebugModeOn?"ON":"OFF");
        EventType et = EventType.valueOf("DEBUG_MODE_" + label);
        messenger.sendMessage(new ActionMessage(et));
        println("debug mode is now " + label);
    }
  
    
    void switchPerceptualMode() {
        isPerceptualModeOn = ! isPerceptualModeOn;
        String pLabel = (isPerceptualModeOn?"ON":"OFF");
        EventType et = EventType.valueOf("PERCEPTUAL_MODE_" + pLabel);
        messenger.sendMessage(new ActionMessage(et));
        println("perceptual mode is now " + pLabel);
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
// PerceptualEventEmulatorController : emulate perceptual event with mouse and keyboard - ofr test purpose
//

class PerceptualEventEmulatorController extends Controller { 

    PVector lastMousePosition;
    boolean isActive = false;

    PerceptualEventEmulatorController(World aParentWorld, LilluraMessenger theMessenger) {
        super(aParentWorld, theMessenger);
        println("Perceptual event emulator is ON");
    }
 
     void preUpdate() {
       if (isActive) {
            PerCMessage event = new PerCMessage();
            event.x = mouseX;
            event.y = mouseY;
            event.depth = 0.2;
            event.openness = 100;
            event.opennessState = 1; //TODO check
            messenger.sendPerCMessage(event);
       }
    }
 
    /**
     * emulates the perceptual hand movement with keyboard
     */    
    public void receive(MouseMessage m) {
        if (m.getButton() != POCodes.Button.RIGHT) {
            return;
        }
      
        switch (m.getAction()) {
            case PRESSED:
                lastMousePosition = m.getPosition();
                break;
            case RELEASED:
                whenRightButtonReleased(m);
                break;
            default:
               // ignore others  
        }
    }
    
    void whenRightButtonReleased(MouseMessage m) {
          PVector currentMousePosition = m.getPosition();
          EventType et = null;
          
          if ( abs(lastMousePosition.x - currentMousePosition.x) > width*0.1) {
              et = (lastMousePosition.x > currentMousePosition.x) ? EventType.PERCEPTUAL_SWIPE_LEFT : EventType.PERCEPTUAL_SWIPE_RIGHT;
          } else if ( abs(lastMousePosition.y - currentMousePosition.y) > height*0.05) {
              et = (lastMousePosition.y > currentMousePosition.y) ? EventType.PERCEPTUAL_SWIPE_UP : EventType.PERCEPTUAL_SWIPE_DOWN;
          } else {
              et = getScreenArea();
          }
          messenger.sendMessage(new ActionMessage(et));
     }
    
    EventType getScreenArea() {
          StringBuilder eventTypeName = new StringBuilder("PERCEPTUAL_HAND_MOVED_");
          if (mouseY<height*0.2) {
              eventTypeName.append("TOP_");
          } else if (mouseY>height*0.8) { 
              eventTypeName.append("BOTTOM_");
          } 
          
          if (mouseX<width*0.33) {
              eventTypeName.append("LEFT");
          } else if (mouseX>width*0.66) {
              eventTypeName.append("RIGHT");
          } else {
              eventTypeName.append("CENTER");
          }
           
          return EventType.valueOf(eventTypeName.toString()); 
     } 

    /**
     * emulates the perceptual hand movement with keyboard
     */    
    public void receive(KeyMessage m) { //FIXME generates a command, and update do the switch
        int code = m.getKeyCode();
        if (m.isPressed()) {
            switch (code) {
                case POCodes.Key.C:
                    messenger.sendMessage(new ActionMessage(EventType.PERCEPTUAL_HAND_CLOSE));
                    break;
                case POCodes.Key.O:
                    messenger.sendMessage(new ActionMessage(EventType.PERCEPTUAL_HAND_OPEN));
                    break;
                case POCodes.Key.W:
                    messenger.sendMessage(new ActionMessage(EventType.PERCEPTUAL_WAVE));
                    break;
                case POCodes.Key.V:
                    messenger.sendMessage(new ActionMessage(EventType.PERCEPTUAL_PEACE));
                    break;
                case POCodes.Key.T:
                    messenger.sendMessage(new ActionMessage(EventType.PERCEPTUAL_THUMB_UP));
                    break;
                case POCodes.Key.F:
                    messenger.sendMessage(new ActionMessage(EventType.PERCEPTUAL_HAND_MOVED_AWAY));
                    break;
                case POCodes.Key.E:
                     messenger.sendMessage(new ActionMessage(EventType.PERCEPTUAL_AVAILABLE));
                     isActive = true;
                     emulateHand();
                    break;
              default:
                  // ignore other events
            }
        }
    }   
  
    void emulateHand() {
        PerCMessage event = new PerCMessage();
        event.x = mouseX;
        event.y = mouseY;
        event.depth = 0.2;
        event.openness = 1;
        event.opennessState = 1;
        messenger.sendPerCMessage(event);
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


//
// ViewFocusPerceptualController : manage which view has the focus
//

class ViewFocusPerceptualController extends Controller {
    
    int activePos;
    int nbPos;
    final ArrayList<ActionMessage> notificationMessages;
    boolean isTrackingOn = false;
    
    ViewFocusPerceptualController(int aNbPos, World aParentWorld, LilluraMessenger theMessenger) {
        super(aParentWorld, theMessenger);
        nbPos = aNbPos;
        
        notificationMessages = new ArrayList<ActionMessage> ();
        notificationMessages.add(new ActionMessage(EventType.SWITCH_TO_MENU));
        notificationMessages.add(new ActionMessage(EventType.SWITCH_TO_GAME_BOARD));
        notificationMessages.add(new ActionMessage(EventType.SWITCH_TO_CARD_DECK));
    }

    /**
    * pos is zero based
    */
    void setActivePos(int aPos) {
        activePos = aPos;
    }
    
    void actionSent(ActionMessage message) {
        if (! isActive) return;

        switch(message.eventType) {
            case PERCEPTUAL_PEACE:
                isTrackingOn  = true;
                break;
            case PERCEPTUAL_HAND_MOVED_TOP_LEFT:
                 setActivePos(1);
                 messenger.sendMessage(new ActionMessage(EventType.SWITCH_TO_MENU));
                 break;
            case PERCEPTUAL_HAND_MOVED_TOP_CENTER:
                 setActivePos(2);
                 messenger.sendMessage(new ActionMessage(EventType.SWITCH_TO_GAME_BOARD));
                 break;
            case PERCEPTUAL_HAND_MOVED_TOP_RIGHT:
                 setActivePos(3);
                 messenger.sendMessage(new ActionMessage(EventType.SWITCH_TO_CARD_DECK));
                 break;
            case PERCEPTUAL_SWIPE_LEFT:
                incrementActivePos();
                break;
            case PERCEPTUAL_SWIPE_RIGHT:
                decrementActivePos();
                break;
            default:
                // ignore other events
        }
        
        if (isTrackingOn) {
            switch(message.eventType) {
                case PERCEPTUAL_HAND_MOVED_LEFT:
                     setActivePos(1);
                     messenger.sendMessage(new ActionMessage(EventType.SWITCH_TO_MENU));
                     isTrackingOn = false;
                     break;
                case PERCEPTUAL_HAND_MOVED_CENTER:
                     setActivePos(2);
                     messenger.sendMessage(new ActionMessage(EventType.SWITCH_TO_GAME_BOARD));
                     isTrackingOn = false;
                     break;
                case PERCEPTUAL_HAND_MOVED_RIGHT:
                     setActivePos(3);
                     messenger.sendMessage(new ActionMessage(EventType.SWITCH_TO_CARD_DECK));
                     isTrackingOn = false;
                     break;
            }
        }
    }
    
    void incrementActivePos() {
        int newPos = (activePos + 1) % nbPos;
        //println("inc activePos " + activePos + " newPos " + newPos);
        activePos = newPos;
        messenger.sendMessage(notificationMessages.get(activePos));
    }

    
    void decrementActivePos() {
        int newPos = (activePos - 1 + nbPos) % nbPos;
        //println("dec activePos " + activePos + " newPos " + newPos);
        activePos = newPos;
        messenger.sendMessage(notificationMessages.get(activePos));
    }


}


