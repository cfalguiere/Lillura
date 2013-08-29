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
        println("Controller " + getClass().getName() + " is enabled");
    }
 
    void disable() {
        isActive = false;
        println("Controller " + getClass().getName() + " is disabled");
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

    PerceptualEventEmulatorController(World aParentWorld, LilluraMessenger theMessenger) {
        super(aParentWorld, theMessenger);
        println("Perceptual event emulator is ON");
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
          
          float distance = currentMousePosition.dist(lastMousePosition);
          //println("distance " + distance);
          if ( distance > width*0.1) {
              et = (lastMousePosition.x > currentMousePosition.x) ? EventType.PERCEPTUAL_SWIPE_LEFT : EventType.PERCEPTUAL_SWIPE_RIGHT;
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
                    messenger.sendMessage(new ActionMessage(EventType.PERCEPTUAL_HAND_AWAY));
                    break;
                case POCodes.Key.H:
                    emulateHand();
                    break;
              default:
                  // ignore other events
            }
        }
    }   
  
    void emulateHand() {
        messenger.sendMessage(new ActionMessage(EventType.PERCEPTUAL_AVAILABLE));
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
// CardDeckController : base class for all CardDeck controller. is responsibie for executing the cardDeck actions 
//TODO select and unselect are CardDeck operations
//TODO move some card deck operations to gui List classes  
//

class CardDeckController extends Controller {
    CardGroup cards;
    CardDeckCanvas cardDeckCanvas;

    float hoverPosition = -1;
    int actionCardIndex = -1;
    
    CardDeckController(CardDeckCanvas aCardDeckCanvas, CardGroup aCardGroup, World aParentWorld, LilluraMessenger theMessenger) {
        super(aParentWorld, theMessenger);
        cards = aCardGroup;
        cardDeckCanvas = aCardDeckCanvas;
    }
    
    void reset() {
        actionCardIndex = -1;
    }
    
    void selectCurrentCard() {
        if (hoverPosition >= 0) {
            //println("hover position " + hoverPosition);
            actionCardIndex = int(hoverPosition);
            //println("selected card at " + actionCardIndex);
            Card card = cards.getCard(actionCardIndex);
            //println("selected card is "  + card);
            card.select();
        }
    }
    
    void deselectCurrentCard() {
        if (actionCardIndex >= 0) {
            Card card = cards.getCard(actionCardIndex);
            float index = cards.getCardIndexForMouse(mouseY);
            //println("releasing card at index " + index);
            int newPos = (index == int(index)) ? floor(index) : ceil(index);
            //println("releasing card at pos " + newPos);
            cards.moveCardTo(card, newPos);
            card.deselect();
            actionCardIndex = -1;
        }
    }
    
    void removeCurrentCard() {
        cards.removeSelectedCard();
        actionCardIndex = -1;
    }
}

class CardDeckKeyController extends CardDeckController {
  
    CardDeckKeyController(CardDeckCanvas aCardDeckCanvas, CardGroup aCardGroup, World aParentWorld, LilluraMessenger theMessenger) {
        super(aCardDeckCanvas, aCardGroup, aParentWorld, theMessenger);
    }
    
    public void receive(KeyMessage m) { //FIXME generates a command, and update do the switch
      if (! isActive) return;

      int code = m.getKeyCode();
      if (m.isPressed()) {
          switch (code) {
              case POCodes.Key.S:
                   removeCurrentCard();
                  break;
              default:
                  // go ahead
                  break;
        }
      }
    }

}

//
// CardDeckMouseController : cardDeck controller with mouse
//

class CardDeckMouseController extends CardDeckController {
    
    CardDeckMouseController(CardDeckCanvas aCardDeckCanvas, CardGroup aCardGroup, World aParentWorld, LilluraMessenger theMessenger) {
        super(aCardDeckCanvas, aCardGroup, aParentWorld, theMessenger);
    }

    public void preUpdate() {
        if (! isActive) return;

        if (cardDeckCanvas.getBoundingBox().contains(mouseX, mouseY)) {
            hoverPosition = cards.getCardIndexForMouse(mouseY);
        } else {
            hoverPosition = -1;
        }   
        if (hoverPosition == int(hoverPosition)) cards.setSelectedCardIndex(floor(hoverPosition));
    }
    
    public void receive(MouseMessage m) {
         if (! isActive) return;
  
        if (hoverPosition < 0) return;
        
        if (m.getAction() == POCodes.Click.PRESSED) {
            selectCurrentCard();
        }  
        if (m.getAction() == POCodes.Click.RELEASED) {
            deselectCurrentCard();
        }  
    }

}

//
// CardDeckPerceptualController : cardDeck controller with peceptual camera
//

class CardDeckPerceptualController extends CardDeckController {
    CardDeckPerceptualController(CardDeckCanvas aCardDeckCanvas, CardGroup aCardGroup, World aParentWorld, LilluraMessenger theMessenger) {
        super(aCardDeckCanvas, aCardGroup, aParentWorld, theMessenger);
    }

    public void preUpdate() {
        if (! isActive) {
           hoverPosition = -1;
          return;
        }

        hoverPosition = cards.getCardIndexForMouse(mouseY);
    }

    void perCChanged(PerCMessage handSensor) {
        if (! isActive) return;
        
            println(" card deck sensor " );
        if (handSensor.isHandOpen() && !handSensor.isTooFar()) {
            println(" card deck y " + handSensor.y);
            hoverPosition = -1;
        } else {
            hoverPosition = -1;    
        }
    }

    void actionSent(ActionMessage message) {
        if (! isActive) return;

        try {
             switch(message.eventType) {
                case PERCEPTUAL_HAND_OPEN:
                    deselectCurrentCard();
                    break;
                case PERCEPTUAL_HAND_CLOSE:
                    selectCurrentCard();
                    break;
                case PERCEPTUAL_HAND_AWAY:
                println("hand away");
                    removeCurrentCard();
                    break;
                default:
                    // ignore other events
            }
        } catch (Exception e) {
            e.printStackTrace();
            println("controller " + this);
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


