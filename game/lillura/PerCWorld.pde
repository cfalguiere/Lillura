class PerCWorld extends World {
  LilluraMessenger _perCMessenger;

  PerCWorld(int portIn, int portOut) {
    super(portIn, portOut);
  }
  
  void setup() {
    if (USE_PCC) {
      //_perCMessenger = new PerCMessenger();
    } else {
      _perCMessenger = new LilluraMessenger();
    }
  }
  
  public LilluraMessenger getPerCMessenger() {
    return _perCMessenger;
  }
  
  void preUpdate() {
    _perCMessenger.acquireEvents();
  }
  
}

