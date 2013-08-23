/**
 * Template World
 * You'll need to add stuff to setup().
 */
class LilluraWorld extends World  {
  
  Rectangle leftPanelBoundingBox;
  
  LilluraMessenger messenger = null;  
  
  //GameLevel _gameLevel;  
  
  LilluraWorld(int portIn, int portOut, Rectangle aBoundingBox, LilluraMessenger theMessenger) {
      super(portIn, portOut);
      leftPanelBoundingBox = aBoundingBox;
      messenger = theMessenger;
  }

  void setup() {
      //IMPORTANT: put all other setup hereterBeing(TemplateBeing);
      createMenu();
    
      createHand();
            
      println("Lillura world set up");
  }

  //
  // World construction
  //
    
  void createMenu() {      
      int w = (int)leftPanelBoundingBox.getWidth();
      int h = (int)leftPanelBoundingBox.getWidth()/4;
      PVector position = leftPanelBoundingBox.getAbsMin();
      position.add(new PVector(0,h));
      MenuCanvas menuCanvas = new MenuCanvas(position, w, h);
      register(menuCanvas);
      
      Rectangle boundingBox = new Rectangle(position, h, h);
      MenuButtonReset reset = new MenuButtonReset(boundingBox, this, messenger);
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

}

