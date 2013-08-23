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
      println("firing messages");
      ActionMessage m = actionMessageQueue.poll();
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
  
  synchronized public void sendMessage(ActionMessage event) {
    actionMessageQueue.add(event);
  }
  
  synchronized public void sendActionMessage(int actionId) {
    actionMessageQueue.add(new ActionMessage(actionId));
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
  static final int ACTION_NONE = 0;
  static final int ACTION_CODE_NONE = 0;
  
  static final int ACTION_RESET = 11; //TODO new game / restart
  
  static final int NOTIFICATION_WIN = 21; 
  static final int NOTIFICATION_LOST = 22; 
  
  static final int ACTION_COMPLETED = 20;
  
  int action = ACTION_NONE;
  MovementType movementType;
  ActionMessage(int anAction)  {
    action = anAction;
  }
  ActionMessage(int anAction, MovementType aMovementType)  {
    action = anAction;
    movementType = aMovementType;
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


