/**
 * Template World
 * You'll need to add stuff to setup().
 */
class MessengerWorld extends World {
  
  LilluraMessenger messenger = null;  
  
  //GameLevel _gameLevel;  
  
  MessengerWorld(int portIn, int portOut) {
      super(portIn, portOut);
      messenger = new LilluraMessenger();
  }

  void setup() {
      //IMPORTANT: put all other setup hereterBeing(TemplateBeing);
      messenger.setup();
            
      println("Messenger world set up");
  }

  void preUpdate() {
      messenger.checkMessages();
  }
 
  LilluraMessenger getMessenger() {
    return messenger;
  } 
}
