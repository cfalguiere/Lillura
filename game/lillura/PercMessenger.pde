/*
acquire data from the camera and dispatch to subscribers
*/
public class PerCMessenger {
  static final int PERC_MESSAGE_ANY = 0;
  
  //Maps that associate subscribers with messages they want to receive
  private final ArrayList<PerCSubscriber> _perCSubscribers;
  //Stores messages as they are received, which are then picked off by checkMail()
  private ArrayList<PerCMessage> _perCQueue;

  PXCUPipeline session;
  PXCMGesture.GeoNode hand = new PXCMGesture.GeoNode();
  boolean _isActive = false;

  PerCMessenger() {
    _perCSubscribers = new ArrayList<PerCSubscriber>();
    _perCQueue = new ArrayList<PerCMessage>();
    initSensor();
  }
  
  void initSensor() {
    session = new PXCUPipeline(  Hermes.getPApplet());
    if(!session.Init(PXCUPipeline.GESTURE)) {
      println("could not initialize PerC");
    } else {
      _isActive = true;
      println("creating PerC session");
    }
  }

  // update the state of the camera user and collect events 
  public void checkMessages() {
    if (_isActive)  {
      acquireEvents();
    }
  } 

  void acquireEvents() { 
    if(session.AcquireFrame(false))
    {
      if(session.QueryGeoNode(PXCMGesture.GeoNode.LABEL_BODY_HAND_PRIMARY|PXCMGesture.GeoNode.LABEL_OPENNESS_ANY, hand))
      {
       firePerCChanged(hand);
      }
//      PXCMGesture.Gesture gdata=new PXCMGesture.Gesture();
//      if (pp.QueryGesture(PXCMGesture.GeoNode.LABEL_ANY,gdata)){
//          print("gesture "+gdata.label+"\n");
 //     }
       
       session.ReleaseFrame(); //must do tracking before frame is released
    }
  }
   
  protected void firePerCChanged(PXCMGesture.GeoNode hand) {
    //println("firing PerC change events to " + _perCSubscribers.size() + " subscribers");
    for(PerCSubscriber subscriber : _perCSubscribers) {
      PerCMessage event = new PerCMessage();
      event.x = hand.positionImage.x;
      event.y = hand.positionImage.y;
      event.depth = hand.positionWorld.y;
      event.openness = hand.openness;
      subscriber.perCChanged(event);
    }
  }

  //
  // Subscriber management
  //
  synchronized public void subscribe(PerCSubscriber subscriber) {
    _perCSubscribers.add(subscriber);
  }
 
  synchronized public void removeSubscriptions(PerCSubscriber subscriber) {
    _perCSubscribers.remove(subscriber);
  }
  

}

public interface PerCSubscriber {
    void perCChanged(PerCMessage event);
}

public class PerCMessage {
  public float x;
  public float y;
  public float depth;
  public float openness;
  public int gesture;
  public String toString() {
    return "x= " + x + " y=" + y + " depth=" + depth + " openness=" + openness;
  }
}


