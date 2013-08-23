/**
 * Template World
 * You'll need to add stuff to setup().
 */
class LilluraWorld extends World  {
  
  HashMap<String, Rectangle>  boundingBoxes;
  Rectangle headerBoundingBox;
  Rectangle leftPanelBoundingBox;
  
  LilluraMessenger messenger = null;  
  
  //GameLevel _gameLevel;  
  
  LilluraWorld(int portIn, int portOut, HashMap<String, Rectangle> allBoundingBoxes,  LilluraMessenger theMessenger) {
      super(portIn, portOut);
      boundingBoxes = allBoundingBoxes;
      messenger = theMessenger;
      headerBoundingBox = allBoundingBoxes.get(HEADER_BBOX);
      leftPanelBoundingBox = allBoundingBoxes.get(LEFT_PANEL_BBOX);
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
      HeaderCanvas headerCanvas = new HeaderCanvas(headerBoundingBox, boundingBoxes);
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

