/**
 * Template World
 * You'll need to add stuff to setup().
 */
class LilluraWorld extends World {
  
  Rectangle leftPanelBoundingBox;
  
  LilluraMessenger messenger = null;  
  
  //GameLevel _gameLevel;  
  
  LilluraWorld(int portIn, int portOut, Rectangle aBoundingBox) {
      super(portIn, portOut);
      leftPanelBoundingBox = aBoundingBox;
  }

  void setup() {
      //IMPORTANT: put all other setup hereterBeing(TemplateBeing);
      messenger = new LilluraMessenger();
    
      createMenu();
    
      createHand();
  }

  void preUpdate() {
      messenger.checkMessages();
  }
  
  //
  // World construction
  //
    
  void createMenu() { 
      PVector position = leftPanelBoundingBox.getAbsMin();
      int w = (int)leftPanelBoundingBox.getWidth();
      int h = (int)leftPanelBoundingBox.getWidth()/3;
      MenuCanvas menuCanvas = new MenuCanvas(position, w, h);
      register(menuCanvas);
      
      float radius = h/2 * 0.8;
      float center = h/2;
      PVector positionCenter = new PVector(position.x + center, position.y + center);
      MenuButtonReset reset = new MenuButtonReset(positionCenter, radius, this, messenger);
      register(reset);
  }
  
  void createHand() {
      int w = (int)leftPanelBoundingBox.getWidth();
      int h = (int)CAMERA_HEIGHT/3;
      int x = (int)leftPanelBoundingBox.getAbsMin().x;
      int y = (int)(WINDOW_HEIGHT - h) - VRT_SPACER;
      HandCanvas handCanvas = new HandCanvas(x, y, w, h);
      register(handCanvas);
      
      Hand hand = new Hand(0, y, w, h);
      register(hand);
      messenger.subscribe(hand);
  }

  
  LilluraMessenger getMessenger() {
    return messenger;
  }
}

