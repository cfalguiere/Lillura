/*
acquire data from the camera and dispatch to subscribers
*/
public class LilluraMessenger {
  LilluraMessenger() {
  }
  
  public void checkMessages() {
  } 
  
  void acquireEvents() { 
  } 
  
  //
  // Subscriber management
  //
  synchronized public void subscribe(PerCSubscriber subscriber) {
  }
 
  synchronized public void removeSubscriptions(PerCSubscriber subscriber) {
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


