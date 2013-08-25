class HeaderCanvas extends Being implements MessageSubscriber  {
  
  static final int MARKER_HEIGHT = 3;

  HashMap<String, Rectangle>  boundingBoxes;
  HeaderMarker marker;
  
  String gameMessage;
  PVector messagePosition;

  HeaderCanvas(Rectangle boundingBox, HashMap<String, Rectangle>  allBoundingBoxes) {
        super(boundingBox);
        boundingBoxes = allBoundingBoxes;
        println("header canvas created");
        
        Rectangle glArea = boundingBoxes.get(GAME_LEVEL_BBOX);
        gameMessage = "Hello";
        messagePosition = new PVector( glArea.getAbsMin().x +  glArea.getWidth()/2 - _shape.getBoundingBox().getAbsMin().x, 40);
        //messagePosition = new PVector( _shape.getBoundingBox().getAbsMin().x + _shape.getBoundingBox().getWidth()/2, 40);
  }
  
  public void update() {
    Rectangle selectedArea = getSelectedArea();
    
    float x = selectedArea.getAbsMin().x - _shape.getBoundingBox().getAbsMin().x;
    float y = _shape.getBoundingBox().getHeight();
    marker = new HeaderMarker(x, y, selectedArea.getWidth(), MARKER_HEIGHT, GOLD_75);
  }
  
  private Rectangle getSelectedArea() {
    PVector mouseVector = new PVector(mouseX, mouseY);
    Rectangle selectedArea = boundingBoxes.get(GAME_LEVEL_BBOX);
    for(Rectangle  area : boundingBoxes.values()) {
      if (area.contains(mouseX, mouseY)) {
        selectedArea = area;
      }
    }
    return selectedArea;
  }

  public void draw() {
    fill(FRAME_BG);
    noStroke();
    _shape.draw();
    
    fill(GOLD);
    textAlign(LEFT);
    textSize(48);
    text("Lillura", 5, 40); 
    if (marker != null) {
      marker.draw();
    }
      
    fill(64, 208, 224, 256);
    //fill(GREEN);
    textSize(32);
    textAlign(CENTER);
    text(gameMessage, messagePosition.x, messagePosition.y); 
  }
  
  //
  // behavior implementation 
  //
    void actionSent(ActionMessage aMessage) {
      switch (aMessage.eventType) {
         case NOTIFICATION_PLAYER_WON :
           gameMessage = "You Win !";
           break;
         case NOTIFICATION_PLAYER_LOST :
           gameMessage = "Game Over !";
           break;
         case COMMAND_RESET :
           gameMessage = "New Game";
           break;
         default :
           gameMessage = "";
           break;
      }
    }
    
    void perCChanged(PerCMessage event) {
      // don't care
    }

}

class HeaderMarker  {
  float x;
  float y;
  float w;
  float h;
  color c;
  
  HeaderMarker(float aX, float aY, float aWidth, float aHeight, color aColor) {
    x = aX;
    y = aY;
    w = aWidth;
    h = aHeight;
    c = aColor;
  }
  
  public void draw() {
    stroke(c);
    strokeWeight(h);
    line(x, y, x+w, y);
  }

}

