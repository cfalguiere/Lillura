/**
 * Template World
 * You'll need to add stuff to setup().
 */
class LilluraWorld extends World  {
  
  Rectangle leftPanelBoundingBox;
  Rectangle headerBoundingBox;
  
  LilluraMessenger messenger = null;  
  
  //GameLevel _gameLevel;  
  
  LilluraWorld(int portIn, int portOut, Rectangle aLPBoundingBox,  Rectangle aHeaderBoundingBox, LilluraMessenger theMessenger) {
      super(portIn, portOut);
      leftPanelBoundingBox = aLPBoundingBox;
      headerBoundingBox = aHeaderBoundingBox;
      messenger = theMessenger;
  }

  void setup() {
      //IMPORTANT: put all other setup hereterBeing(TemplateBeing);
      
      createHeader();
      
      createMenu();
    
      createHand();
            
      println("Lillura world set up");
  }

  //
  // World construction
  //
    
  void createHeader() {      
      HeaderCanvas headerCanvas = new HeaderCanvas(headerBoundingBox);
      register(headerCanvas);
  }
  

  void createMenu() {      
      int w = (int)leftPanelBoundingBox.getWidth();
      int h = (int)leftPanelBoundingBox.getWidth()/4;
      PVector position = leftPanelBoundingBox.getAbsMin();
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

