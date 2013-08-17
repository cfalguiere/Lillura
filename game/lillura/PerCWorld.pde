class PerCWorld extends World {
  PerCMessenger _perCMessenger;

  PerCWorld(int portIn, int portOut) {
    super(portIn, portOut);
  }
  
  void setup() {
    _perCMessenger = new PerCMessenger();
  }
  
  public PerCMessenger getPerCMessenger() {
    return _perCMessenger;
  }
  
  void preUpdate() {
    _perCMessenger.acquireEvents();
  }
  
}

