class PerceptualWorld extends World implements MessageSubscriber {
  
    LilluraMessenger messenger = null;  
    PerceptualSensor perceptualSensor;
    boolean isPerceptualAvailable = true;
    boolean isPerceptualActive = true;
  
  
    PerceptualWorld(int portIn, int portOut,  LilluraMessenger theMessenger) {
        super(portIn, portOut);
        messenger = theMessenger;
    }

    void setup() {
        //IMPORTANT: put all other setup hereterBeing(TemplateBeing);
        messenger.subscribe(this);
               
        try {
             perceptualSensor = new PerceptualSensor(messenger);
             perceptualSensor.setup();
             messenger.sendActionMessage(EventType.PERCEPTUAL_AVAILABLE);
       } catch (UnavailablePerceptualException upe) {
            isPerceptualAvailable = false;
        }
        println("Messenger is up");

  
        PerceptualEventEmulatorController perceptualEmulator =  new PerceptualEventEmulatorController(this, messenger); //FIXME insulate from general keys
        subscribe(perceptualEmulator, POCodes.Button.RIGHT);
        subscribe(perceptualEmulator, POCodes.Key.C);
        subscribe(perceptualEmulator, POCodes.Key.O);
        subscribe(perceptualEmulator, POCodes.Key.P);
  
        ViewFocusPerceptualController viewFocusController =  new ViewFocusPerceptualController(3, this, messenger);
        viewFocusController.setActivePos(1);
        messenger.subscribe(viewFocusController);
        
        println("Perceptual world is up");
    }
    
    void preUpdate() {
      if (isPerceptualAvailable) {
            perceptualSensor.acquireEvents();
      }
    }

    //
    // behavior implementation 
    //
    void actionSent(ActionMessage message) {
        switch(message.eventType) {
            case PERCEPTUAL_MODE_ON:
                isPerceptualActive = true;
                break;
            case PERCEPTUAL_MODE_OFF:
                isPerceptualActive = true;
                break;
            default:
                 // ignore other events
          }
    }
    
    void perCChanged(PerCMessage event) {
      // don't care
    }

}

/*
This class responisbilities are to interface the camera, collect information and store the state of the interaction
*/

class PerceptualSensor {
  
  float[] mHandPos = new float[4];
  
  PXCUPipeline session;
  PXCMGesture.GeoNode hand = new PXCMGesture.GeoNode();

  LilluraMessenger messenger;
  
  PerCMessage lastEvent;
  int memArea = -1;
  int lastArea = -1;
  
  boolean isActive = false;

    PerceptualSensor(LilluraMessenger theMessenger) {
        messenger = theMessenger;
        println("PerC session created");
    }
  
    void setup() throws UnavailablePerceptualException {
        try {
            session = new PXCUPipeline(  Hermes.getPApplet());
            if (session.Init(PXCUPipeline.GESTURE)) {
              isActive = true;
              println("PerC session set up");
            } 
        } catch (Throwable cause) {
           throw new UnavailablePerceptualException(cause);
        }
    }
  
  void acquireEvents() { //TODO build the status message
      if (session.AcquireFrame(false))
      {
          PerCMessage event = null;
          if(session.QueryGeoNode(PXCMGesture.GeoNode.LABEL_BODY_HAND_PRIMARY|PXCMGesture.GeoNode.LABEL_OPENNESS_ANY, hand))
          {
              event = new PerCMessage();
              event.x = hand.positionImage.x;
              event.y = hand.positionImage.y;
              event.depth = hand.positionWorld.y;
              event.openness = hand.openness;
              event.opennessState = hand.opennessState;
          }
        
          PXCMGesture.Gesture gdata = new PXCMGesture.Gesture();
          if (session.QueryGesture(PXCMGesture.GeoNode.LABEL_ANY,gdata)){
              if (event == null) event = new PerCMessage();
              event.gesture = gdata.label;  
          }
         
          if (event != null) {
            notifyEvent(event);
          }
         
          session.ReleaseFrame(); //must do tracking before frame is released
      }
  }
  
  private void notifyEvent(PerCMessage event) {
      
      boolean foundGesture = false;
      if (event.gesture == PXCMGesture.Gesture.LABEL_POSE_THUMB_UP) {
          if (lastEvent == null || lastEvent.gesture != event.gesture) {
             messenger.sendActionMessage(EventType.PERCEPTUAL_THUMB_UP);
          }
          foundGesture = true;
      }

      if (event.gesture == PXCMGesture.Gesture.LABEL_POSE_PEACE) {
          if (lastEvent == null || lastEvent.gesture != event.gesture) {
             messenger.sendActionMessage(EventType.PERCEPTUAL_PEACE);
          }
          foundGesture = true;
      }

      if (event.gesture == PXCMGesture.Gesture.LABEL_HAND_WAVE) {
          if (lastEvent == null || lastEvent.gesture != event.gesture) {
             messenger.sendActionMessage(EventType.PERCEPTUAL_WAVE);
          }
          foundGesture = true;
      }

      if (event.gesture == PXCMGesture.Gesture.LABEL_HAND_CIRCLE) {
          if (lastEvent == null || lastEvent.gesture != event.gesture) {
             messenger.sendActionMessage(EventType.PERCEPTUAL_CIRCLE);
          }
          foundGesture = true;
      }



      if (event.gesture == PXCMGesture.Gesture.LABEL_NAV_SWIPE_UP) {
          if (lastEvent == null || lastEvent.gesture != event.gesture) {
             messenger.sendActionMessage(EventType.PERCEPTUAL_SWIPE_UP);
          }
          foundGesture = true;
      }

      if (event.gesture == PXCMGesture.Gesture.LABEL_NAV_SWIPE_DOWN) {
          if (lastEvent == null || lastEvent.gesture != event.gesture) {
             messenger.sendActionMessage(EventType.PERCEPTUAL_SWIPE_DOWN);
          }
          foundGesture = true;
      }

      if (event.gesture == PXCMGesture.Gesture.LABEL_NAV_SWIPE_LEFT) {
          if (lastEvent == null || lastEvent.gesture != event.gesture) {
             messenger.sendActionMessage(EventType.PERCEPTUAL_SWIPE_LEFT);
          }
          foundGesture = true;
      }

      if (event.gesture == PXCMGesture.Gesture.LABEL_NAV_SWIPE_RIGHT) {
          if (lastEvent == null || lastEvent.gesture != event.gesture) {
             messenger.sendActionMessage(EventType.PERCEPTUAL_SWIPE_RIGHT);
          }
          foundGesture = true;
      }

        
      if (! foundGesture && lastEvent!=null) { 
          //println("depth change " + lastEvent.depth + " -> " +  event.depth);
          float avgDepth = (lastEvent.depth / event.depth) / 2;
          if (lastEvent.depth > 0.15 && avgDepth < 0.15) {
              messenger.sendActionMessage(EventType.PERCEPTUAL_HAND_MOVED_CLOSER);
              foundGesture = true;
          } else  if (avgDepth > 0.6) {
              messenger.sendActionMessage(EventType.PERCEPTUAL_HAND_MOVED_AWAY);
              foundGesture = true;
          }
          
          //println("x change " + lastEvent.x + " -> " +  event.x);
          float avgX = (lastEvent.x + event.x) /2;
          //int area = int(event.x / (CAMERA_WIDTH/8) );
          int area = int(avgX / (CAMERA_WIDTH/6) );
          //println( "area  " + area);
          if (! event.isTooFar()) { //(memArea >= 0 && memArea == area) {
              if (area == 0 && lastArea !=0) { // view is mirrored, lower x is on the left from the camera perspective
                  messenger.sendActionMessage(EventType.PERCEPTUAL_HAND_MOVED_RIGHT);
                  foundGesture = true;
                  lastArea = 0;
              } else if (area == 2 && lastArea !=2) { // view is mirrored, lower x is on the left from the camera perspective
                  messenger.sendActionMessage(EventType.PERCEPTUAL_HAND_MOVED_LEFT);
                  foundGesture = true;
                  lastArea = 2;
              } else if (area == 1 && lastArea !=1){ // view is mirrored, lower x is on the left from the camera perspective
                  messenger.sendActionMessage(EventType.PERCEPTUAL_HAND_MOVED_CENTER);
                  foundGesture = true;
                  lastArea = 1;
              }
          }
          memArea = area;
      }
    
      if (! foundGesture ) { 
          
          if (event.opennessState == PXCMGesture.GeoNode.LABEL_OPEN) {
              if (lastEvent == null || lastEvent.opennessState != event.opennessState) {
                  messenger.sendActionMessage(EventType.PERCEPTUAL_HAND_OPEN);
              }
          }
          
          if (event.opennessState == PXCMGesture.GeoNode.LABEL_CLOSE) { 
              if (lastEvent == null || lastEvent.opennessState != event.opennessState) {
                  messenger.sendActionMessage(EventType.PERCEPTUAL_HAND_CLOSE);
              }
          }
      }

      if (lastEvent != null) {
          event.depth = (event.depth + lastEvent.depth) / 2;
          event.x = (event.x + lastEvent.x) / 2;
          event.y = (event.y + lastEvent.y) / 2;
      }
      
      messenger.sendPerCMessage(event);
    
      lastEvent = event;
   }
      
  
}


public class PerCMessage extends Message {
  public float x;
  public float y;
  public float depth;
  public float openness;
  public int opennessState;
  public int gesture;
  public String toString() {
    return "x= " + x + " y=" + y + " depth=" + depth + " openness=" + openness;
  }
  
  public boolean isHandOpen() {
    //return openness >= 50;
    return opennessState == PXCMGesture.GeoNode.LABEL_OPEN;
  }
  
  public boolean isHandClose() {
    //return openness < 50;
    return opennessState == PXCMGesture.GeoNode.LABEL_CLOSE;
  }
  
  public boolean isTooFar() {
    return depth > 0.4;
  }
}

//Mock
/*
public class PerCMessage extends Message {
  public float x;
  public float y;
  public float depth;
  public float openness;
  public float opennessState;
  public int gesture;
  
  public boolean isHandOpen() {
    return true;
  }
  
  public boolean isHandClose() {
    return false;
  }
  
  public boolean isTooFar() {
    return false;
  }
}*/

class UnavailablePerceptualException extends Exception {
    static final private String label = "unable to setup camera";
    public UnavailablePerceptualException() {
         super(label);
    }
    public UnavailablePerceptualException(Throwable cause) {
         super(label, cause);
    }
}
