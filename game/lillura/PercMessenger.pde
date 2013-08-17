public class PerCMessenger {
  static final int PERC_MESSAGE_ANY = 0;
  
  //Maps that associate subscribers with messages they want to receive
  private final HashMultimap<Integer, PerCSubscriber> _perCSubscribers;
  //Stores messages as they are received, which are then picked off by checkMail()
  private LinkedList<PerCMessage> _perCQueue;

  PerCMessenger() {
    _perCSubs = HashMultimap.create();
    _perCQueue = new LinkedList<PerCMessage>();
  }

  // update the state of the camera user and collect events 
  public void checkMessages() {
    // acquire events
    println("acquire events");
    firePerCChanged(1,2);
    /*
      //Send all the messages in each queue to the corresponding subscribers
      synchronized(_keyQueue) {
        _pressedKeys.clear();
        while(!_keyQueue.isEmpty()) {
          KeyMessage m = _keyQueue.poll();
          int key = m.getKeyCode();
          if(m.isPressed()) { //Add to the pressed key array if pressed
            _pressedKeys.add(key);
          }
          Set<KeySubscriber> subs = _keySubs.get(key);
          for(KeySubscriber sub : subs) {
            sub.receive(m);
          }
        }
      }*/
  } 
  
    protected void firePerCChanged(double oldValue, double c) {
      println("firing PerC change events");
      /*
            for(PerCListener listener : getPerCListeners()) {
                listener.perCChanged(oldValue, oldValue);
            }*/
    }

  //
  // Subscriber management
  //
  public void addPerCListener(PerCListener listener) {
      listeners.add(PercHandListener.class, listener);
  }
 
  public void removePerCListener(PerCListener listener) {
      listeners.remove(PerCListener.class, listener);
  }
  
  public PerCListener[] getPerCListeners() {
        return listeners.getListeners(PerCListener.class);
  }
 

}

public interface PerCListener extends EventListener {
    void perCChanged(double oldValue, double newValue);
}
