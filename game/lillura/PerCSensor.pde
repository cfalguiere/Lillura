/*
This class responisbilities are to interface the camera, collect information and store the state of the interaction
*/

class PerCSensor {
  
  float[] mHandPos = new float[4];
  
  PXCUPipeline session;
  PXCMGesture.GeoNode hand = new PXCMGesture.GeoNode();

  LilluraMessenger messenger;
  
  boolean isActive = false;

  PerCSensor(LilluraMessenger theMessenger) {
      messenger = theMessenger;
      println("PerC session created");
  }
  
  void setup() {
    session = new PXCUPipeline(  Hermes.getPApplet());
    if(!session.Init(PXCUPipeline.GESTURE)) {
      println("could not initialize PerC");
    } else {
      isActive = true;
      println("PerC session set up");
    }
  }
  
  void acquireEvents() { //TODO buimd the status message
      if(session.AcquireFrame(false))
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
              event.gesture = gdata.label;  
          }
         
          if (event != null) {
            messenger.sendPerCMessage(event);
          }
         
          session.ReleaseFrame(); //must do tracking before frame is released
      }
  }
}


public class PerCMessage extends Message {
  public float x;
  public float y;
  public float depth;
  public float openness;
  public float opennessState;
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


