/*
acquire data from the camera and dispatch to subscribers
*/
public class LilluraMessenger implements MessageSubscriber {
  
  private final ConcurrentLinkedQueue<MessageSubscriber> messageSubscribers;
  private LinkedList<ActionMessage> actionMessageQueue;
  private LinkedList<PerCMessage> perCMessageQueue;
  
  boolean useDebugMode = false;
  
  LilluraMessenger() {
    messageSubscribers = new ConcurrentLinkedQueue<MessageSubscriber>();
    actionMessageQueue = new LinkedList<ActionMessage>();
    perCMessageQueue = new LinkedList<PerCMessage>();

    println("Messenger created");
  }
  
  void setup() {
      subscribe(this);
  }
  
  public void checkMessages() {
    fireMessages();
    firePerCChanged();
  } 

  protected void fireMessages() {
      while(!actionMessageQueue.isEmpty()) {
          ActionMessage m = null;
          synchronized(actionMessageQueue) {
              m = actionMessageQueue.poll();
          }
          
          if (useDebugMode) println("firing message " + m);
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
    //println("received capture");
    perCMessageQueue.add(event);
  }
  
  
    //
    // behavior implementation 
    //
    void actionSent(ActionMessage message) {
        switch(message.eventType) {
            case DEBUG_MODE:
                useDebugMode = ! useDebugMode;
                break;
            default:
                 // ignore other events
          }
    }
    
    void perCChanged(PerCMessage event) {
      // don't care
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
  RobotProgram program;
  
  ActionMessage(EventType anEventType)  {
    eventType = anEventType;
  }
  
  ActionMessage(EventType anEventType, RobotAction aRobotAction)  {
    eventType = anEventType;
    robotAction = aRobotAction;
  }
  
  ActionMessage(EventType anEventType, RobotProgram aProgram)  {
    eventType = anEventType;
    program = aProgram;
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


