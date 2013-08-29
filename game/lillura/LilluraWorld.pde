/**
 * Template World
 * You'll need to add stuff to setup().
 */
class LilluraWorld extends World implements MessageSubscriber {
  
  HashMap<String, Rectangle>  boundingBoxes;
  Rectangle headerBoundingBox;
  Rectangle leftPanelBoundingBox;
  String message;
  
  LilluraMessenger messenger = null;  
  
  private PerceptualEventEmulatorController perceptualEmulator;
  
  LilluraWorld(int portIn, int portOut, HashMap<String, Rectangle> allBoundingBoxes,  LilluraMessenger theMessenger) {
      super(portIn, portOut);
      boundingBoxes = allBoundingBoxes;
      messenger = theMessenger;
      headerBoundingBox = allBoundingBoxes.get(HEADER_BBOX);
      leftPanelBoundingBox = allBoundingBoxes.get(LEFT_PANEL_BBOX);
  }

    void setup() {
        //IMPORTANT: put all other setup hereterBeing(TemplateBeing);
        messenger.subscribe(this);
  
        GeneralKeyController controller =  new GeneralKeyController(this, messenger);
        subscribe(controller, POCodes.Key.D);
        subscribe(controller, POCodes.Key.P);
  
        perceptualEmulator =  new PerceptualEventEmulatorController(this, messenger);
        subscribe(perceptualEmulator, POCodes.Button.RIGHT);
        subscribe(perceptualEmulator, POCodes.Key.C);
        subscribe(perceptualEmulator, POCodes.Key.O);
        subscribe(perceptualEmulator, POCodes.Key.T);
        subscribe(perceptualEmulator, POCodes.Key.V);
        subscribe(perceptualEmulator, POCodes.Key.W);
        subscribe(perceptualEmulator, POCodes.Key.F);
        subscribe(perceptualEmulator, POCodes.Key.E);
  
        ViewFocusPerceptualController viewFocusController =  new ViewFocusPerceptualController(3, this, messenger);
        viewFocusController.setActivePos(1);
        messenger.subscribe(viewFocusController);
        
        createHeader();
        
        createMenu();
      
        println("Lillura world set up");
    }

    void preUpdate() {
        perceptualEmulator.preUpdate();
    }


    //
    // behavior implementation 
    //
    void actionSent(ActionMessage message) {
        switch(message.eventType) {
            case PERCEPTUAL_AVAILABLE:
                createHand();
                break;
            default:
                 // ignore other events
          }
    }
    
    void perCChanged(PerCMessage event) {
      // don't care
    }

  //
  // World construction
  //
    
  void createHeader() {      
      HeaderCanvas headerCanvas = new HeaderCanvas(headerBoundingBox, boundingBoxes);
      register(headerCanvas);
      messenger.subscribe(headerCanvas);
  }
  

  void createMenu() {      
      int w = (int)leftPanelBoundingBox.getWidth();
      int h = (int)leftPanelBoundingBox.getWidth()/4;
      PVector position = leftPanelBoundingBox.getAbsMin();
      MenuCanvas menuCanvas = new MenuCanvas(position, w, h);
      register(menuCanvas);
      
      int pos = 0;
      
      MenuButtonNewGame newGame = new MenuButtonNewGame(getMenuButtonBoundingBox(pos++), this, messenger);
      register(newGame);
      
      MenuButtonRestart restart = new MenuButtonRestart(getMenuButtonBoundingBox(pos++), this, messenger);
      register(restart);

      MenuButtonPlay play = new MenuButtonPlay(getMenuButtonBoundingBox(pos++), this, messenger);
      register(play);

  }
  
  Rectangle getMenuButtonBoundingBox(int aPos) {
      int h = (int)leftPanelBoundingBox.getWidth()/4;
      PVector position = new PVector();
      position.set(leftPanelBoundingBox.getAbsMin());
      position.add(new PVector(h*aPos, 0)); // zero based
      Rectangle buttonBoundingBox = new Rectangle(position, h, h);
      return buttonBoundingBox;
  }
  
  
  void createHand() {
      int w = (int)leftPanelBoundingBox.getWidth();
      int h = (int)CAMERA_HEIGHT/3;
      int x = (int)leftPanelBoundingBox.getAbsMin().x;
      int y = (int)(WINDOW_HEIGHT - h) - VRT_SPACER;
      HandCanvas handCanvas = new HandCanvas(x, y, w, h);
      register(handCanvas);
      messenger.subscribe(handCanvas);
      
      Hand hand = new Hand(0, y, w, h);
      register(hand);
      messenger.subscribe(hand);
  }

}

