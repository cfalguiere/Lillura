/*
acquire data from the camera and dispatch to subscribers
*/
public class LilluraMessenger {
  /*
  PerCSensor perCSensor;
  */
  // subscriber
  private final ArrayList<MessageSubscriber> messageSubscribers;
  // message queue
  private LinkedList<ActionMessage> actionMessageQueue;
  private LinkedList<PerCMessage> perCMessageQueue;

  LilluraMessenger() {
    messageSubscribers = new ArrayList<MessageSubscriber>();
    actionMessageQueue = new LinkedList<ActionMessage>();
    perCMessageQueue = new LinkedList<PerCMessage>();
    /*
    perCSensor = new PerCSensor(this);
    */
    println("Messenger created");
  }
  
  void setup() {
    /*
    perCSensor.setup();
    */
    println("Messenger set up");
  }
  
  public void checkMessages() {
    /*
    perCSensor.acquireEvents();
    */
    fireMessages();
    firePerCChanged();
  } 

  protected void fireMessages() {
    while(!actionMessageQueue.isEmpty()) {
      ActionMessage m = actionMessageQueue.poll();
      println("firing message " + m);
      for(MessageSubscriber subscriber : messageSubscribers) {
        subscriber.actionSent(m);
      }
    }
  }

  protected void firePerCChanged() {
    while(!perCMessageQueue.isEmpty()) {
      PerCMessage m = perCMessageQueue.poll();
      for(MessageSubscriber subscriber : messageSubscribers) {
        subscriber.perCChanged(m);
      }
    }
  }
  
  
  //
  // Subscriber management
  //
  synchronized public void subscribe(MessageSubscriber subscriber) {
     messageSubscribers.add(subscriber);
  }
 
  synchronized public void removeSubscriptions(MessageSubscriber subscriber) {
    messageSubscribers.remove(subscriber);
  }
  
  synchronized public void sendMessage(ActionMessage message) {
    actionMessageQueue.add(message);
  }
  
  synchronized public void sendActionMessage(EventType eventType) {
    actionMessageQueue.add(new ActionMessage(eventType));
  }

  synchronized public void sendPerCMessage(PerCMessage event) {
    println("received capture");
    perCMessageQueue.add(event);
  }
  
  

}

//
// subscriber interfaces
//

public interface MessageSubscriber {
    void actionSent(ActionMessage event);
    void perCChanged(PerCMessage event);
}

//
// messages
//

public class Message {
}

public class ActionMessage extends Message {

  EventType eventType = EventType.NONE;
  RobotAction robotAction;
  
  ActionMessage(EventType anEventType)  {
    eventType = anEventType;
  }
  
  ActionMessage(EventType anEventType, RobotAction aRobotAction)  {
    eventType = anEventType;
    robotAction = aRobotAction;
  }
  
  public String toString() {
    String message;
    if (eventType == EventType.ROBOT_ACTION_COMPLETED) {
        message = "[ " + eventType.name()  + " " + robotAction.movementType.name() + " " + robotAction.distance() + " ]"; 
    } else {
        message = "[ " + eventType.name()  + " ]"; 
    }
    return message; 
  }
}

//Mock
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
}


