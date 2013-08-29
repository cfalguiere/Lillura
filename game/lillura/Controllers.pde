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


