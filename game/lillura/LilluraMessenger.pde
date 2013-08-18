/*
acquire data from the camera and dispatch to subscribers
*/
public class LilluraMessenger {
  
  // subscriber
  private final ArrayList<MessageSubscriber> messageSubscribers;
  // message queue
  private LinkedList<Message> messageQueue;

  LilluraMessenger() {
    messageSubscribers = new ArrayList<MessageSubscriber>();
    messageQueue = new LinkedList<Message>();
  }
  
  public void checkMessages() {
  } 
  
  void acquireEvents() { 
  } 
  
  //
  // Subscriber management
  //
  synchronized public void subscribe(MessageSubscriber subscriber) {
  }
 
  synchronized public void removeSubscriptions(MessageSubscriber subscriber) {
  }
  

}

public interface MessageSubscriber {
    void perCChanged(PerCMessage event);
}

public class MessageSubscriberAdapter {
    void perCChanged(PerCMessage event) {}
}

public class Message {
}

public class PerCMessage extends Message {
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


