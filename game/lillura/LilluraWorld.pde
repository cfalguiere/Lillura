/**
 * Template World
 * You'll need to add stuff to setup().
 */
class LilluraWorld extends World {
  
  PerCWorld _perCWorld;
  LilluraMessenger _perCMessenger = null;
  
  Terrain _terrain;  
  GameLevel _gameLevel;  
  
  LilluraWorld(int portIn, int portOut, PerCWorld pcw) {
    super(portIn, portOut);
    _perCWorld = pcw;
  }

  void setup() {
    //IMPORTANT: put all other setup hereterBeing(TemplateBeing);
    _terrain = createTerrain();
    _gameLevel = new GameLevel(this, _terrain, _perCMessenger);
  
    createMenu(_terrain, _gameLevel);
  
    // wait until messenger is created
    while (_perCMessenger == null) {
      _perCMessenger = _perCWorld.getPerCMessenger();
    }
    Hand hand = createHand(_terrain);
    _perCMessenger.subscribe(hand);

  }

  void preUpdate() {
    _perCMessenger.checkMessages();
  }
  
  //
  // World construction
  //
  Terrain createTerrain() {
        int x = CAMERA_WIDTH/3 + HRZ_SPACER*2;
        int y = WINDOW_HEIGHT - CAMERA_HEIGHT -  + VRT_SPACER;
        Terrain terrain = new Terrain(x, y, CAMERA_WIDTH, CAMERA_HEIGHT);
        register(terrain);
        return terrain;
  }
  
  
  
  public Terrain getTerrain() {
    return _terrain;
  }  

  
  Hand createHand(Terrain terrain) {
      int w = (int)CAMERA_WIDTH/3;
      int h = (int)CAMERA_HEIGHT/3;
      int y = (int)(WINDOW_HEIGHT - h) - VRT_SPACER;
      HandCanvas handCanvas = new HandCanvas(HRZ_SPACER, y, w, h);
      register(handCanvas);
      Hand hand = new Hand(0, y, w, h);
      register(hand);
      return hand;
  }

  MenuCanvas createMenuLeft() {
        int x = HRZ_SPACER;
        int y = VRT_SPACER;
        int w =  (int)CAMERA_WIDTH/3;
        int h = WINDOW_HEIGHT - VRT_SPACER*2;
        MenuCanvas menuCanvas = new MenuCanvas(x, y, w, h);
        register(menuCanvas);
        return menuCanvas;
  }
  

  MenuCanvas createMenu(Terrain terrain, GameLevel gameLevel) {
        int x = (int)terrain.getBoundingBox().getAbsMin().x;
        int y = VRT_HEADER + VRT_SPACER;
        int w = (int)terrain.getBoundingBox().getWidth();
        int h = (int)(WINDOW_HEIGHT - VRT_SPACER*3 - terrain.getBoundingBox().getHeight() - VRT_HEADER);
        MenuCanvas menuCanvas = new MenuCanvas(x, y, w, h);
        register(menuCanvas);
        
        float radius = h/2 * 0.8;
        float center = h/2;
        PVector position = new PVector(x + center, y + center);
        MenuButtonReset reset = new MenuButtonReset(position, radius, this, _gameLevel);
        register(reset);
        
        return menuCanvas;
  }
  
}

