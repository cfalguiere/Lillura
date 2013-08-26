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
        println("Controller " + getName() + " is enabled");
    }
 
    void disable() {
        isActive = false;
        println("Controller " + getName() + " is disabled");
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
    float lastMouseX;
    
    RobotPerceptualMovementController(Robot aRobot, World aParentWorld, LilluraMessenger theMessenger) {
        super(aParentWorld, theMessenger);
        robot = aRobot;
    }
  
    void perCChanged(PerCMessage handSensor) {
      if (! isActive) return;
      
      //if (isReplaying) return;
  
      if (handSensor.isHandOpen() && !handSensor.isTooFar()) {
          robot.handleGoOn();
      } else {
          robot.handlePause();
      }
    }

    void actionSent(ActionMessage message) {
        if (! isActive) return;

        switch(message.eventType) {
            case PERCEPTUAL_HAND_OPEN:
                robot.handleGoOn();
                break;
            case PERCEPTUAL_HAND_CLOSE:
                robot.handlePause();
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
 
    // emulation of position with right button
    public void receive(MouseMessage m) {
       if (! isActive) return;

        //if (isReplaying) return; //TODO handle replay
        
        if (m.getAction() == POCodes.Click.PRESSED) {
            boolean top = (mouseY<height*0.2);
            boolean bottom = (mouseY>height*0.8);
            boolean left = (mouseX<width*0.33);
            boolean right = (mouseX>width*0.66);
        
            EventType et = EventType.PERCEPTUAL_HAND_MOVED_CENTER;
            
            if (top) {
                 if (left) {
                    et = EventType.PERCEPTUAL_HAND_MOVED_TOP_LEFT;
                 } else if (right) {
                    et = EventType.PERCEPTUAL_HAND_MOVED_TOP_RIGHT;
                 } else {
                    et = EventType.PERCEPTUAL_HAND_MOVED_TOP_CENTER;
                 }
            } else if (bottom) { 
                 if (left) {
                    et = EventType.PERCEPTUAL_HAND_MOVED_BOTTOM_LEFT;
                 } 
            } else {
                if (left) {
                    et = EventType.PERCEPTUAL_HAND_MOVED_LEFT;
                } else if (right) {
                    et = EventType.PERCEPTUAL_HAND_MOVED_CENTER;
                } else {
                    et = EventType.PERCEPTUAL_HAND_MOVED_RIGHT;
                }
            }
            
            messenger.sendMessage(new ActionMessage(et));
        }
    }

    // emulation of close / open with keyboard C and O
    public void receive(KeyMessage m) { //FIXME generates a command, and update do the switch
       if (! isActive) return;
       
       println("here");

        //if (isReplaying) return; //TODO replay
        
        int code = m.getKeyCode();
        if (m.isPressed()) {
            switch (code) {
                case POCodes.Key.C:
                    messenger.sendMessage(new ActionMessage(EventType.PERCEPTUAL_HAND_CLOSE));
                    break;
                case POCodes.Key.O:
                    messenger.sendMessage(new ActionMessage(EventType.PERCEPTUAL_HAND_OPEN));
                    break;
              default:
                  // ignore other events
            }
        }
    }   
}

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
    
    void selectCurrentCard() {
        if (hoverPosition >= 0) {
            println("hover position " + hoverPosition);
            actionCardIndex = int(hoverPosition);
            println("selected card at " + actionCardIndex);
            Card card = cards.getCard(actionCardIndex);
            println("selected card is "  + card);
            card.select();
        }
    }
    
    void deselectCurrentCard() {
        if (actionCardIndex >= 0) {
            Card card = cards.getCard(actionCardIndex);
            float index = cards.getCardIndexForMouse(mouseY);
            println("releasing card at index " + index);
            int newPos = (index == int(index)) ? floor(index) : ceil(index);
            println("releasing card at pos " + newPos);
            cards.moveCardTo(card, newPos);
            card.deselect();
            actionCardIndex = -1;
        }
    }
}

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

    void actionSent(ActionMessage message) {
        if (! isActive) return;

        switch(message.eventType) {
            case PERCEPTUAL_HAND_OPEN:
                deselectCurrentCard();
                break;
            case PERCEPTUAL_HAND_CLOSE:
                selectCurrentCard();
                break;
            default:
                // ignore other events
        }
    }
    
    // emulation of close / open with keyboard C and O
    public void receive(KeyMessage m) { //FIXME generates a command, and update do the switch
      //if (isReplaying) return; //TODO replay
      
      int code = m.getKeyCode();
      if (m.isPressed()) {
          switch (code) {
              case POCodes.Key.C:
                  messenger.sendMessage(new ActionMessage(EventType.PERCEPTUAL_HAND_CLOSE));
                  break;
              case POCodes.Key.O:
                  messenger.sendMessage(new ActionMessage(EventType.PERCEPTUAL_HAND_OPEN));
                  break;
            default:
                // ignore other events
          }
      }
    }   

}
