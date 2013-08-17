/*
acquire data from the camera and dispatch to subscribers
*/
public class PerCMessenger extends LilluraMessenger {
  static final int PERC_MESSAGE_ANY = 0;
  
  //Maps that associate subscribers with messages they want to receive
  private final ArrayList<PerCSubscriber> _perCSubscribers;
  //Stores messages as they are received, which are then picked off by checkMail()
  private LinkedList<PerCMessage> _perCQueue;

  PXCUPipeline session;
  PXCMGesture.GeoNode hand = new PXCMGesture.GeoNode();
  boolean _isActive = false;

  PerCMessenger() {
    _perCSubscribers = new ArrayList<PerCSubscriber>();
    _perCQueue = new LinkedList<PerCMessage>();
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
      firePerCChanged(hand);
    }
  } 

  void acquireEvents() { 
    if(session.AcquireFrame(false))
    {
      if(session.QueryGeoNode(PXCMGesture.GeoNode.LABEL_BODY_HAND_PRIMARY|PXCMGesture.GeoNode.LABEL_OPENNESS_ANY, hand))
      {
        PerCMessage event = new PerCMessage();
        event.x = hand.positionImage.x;
        event.y = hand.positionImage.y;
        event.depth = hand.positionWorld.y;
        event.openness = hand.openness;
        synchronized(_perCQueue) {
          _perCQueue.add(event);
        }
      }
//      PXCMGesture.Gesture gdata=new PXCMGesture.Gesture();
//      if (pp.QueryGesture(PXCMGesture.GeoNode.LABEL_ANY,gdata)){
//          print("gesture "+gdata.label+"\n");
 //     }
       
       session.ReleaseFrame(); //must do tracking before frame is released
    }
  }
   
  protected void firePerCChanged(PXCMGesture.GeoNode hand) {
    while(!_perCQueue.isEmpty()) {
      PerCMessage m = _perCQueue.poll();
      for(PerCSubscriber subscriber : _perCSubscribers) {
        subscriber.perCChanged(m);
      }
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
  
  public boolean isHandOpen() {
    return openness > 50;
  }
  
  public boolean isTooFar() {
    return depth > 0.4;
  }
}


