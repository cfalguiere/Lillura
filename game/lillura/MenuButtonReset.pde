class MenuButtonReset extends Being {
  boolean isPressed = false;
  LilluraMessenger messenger;
  float diameter;
  float hText = 6.0;
  PVector imageCenter;
  float hImage;
  PFont font;
  
  MenuButtonReset(Rectangle aBoundingBox, World theParentWorld, LilluraMessenger theMessenger) {
    super(aBoundingBox);
    theParentWorld.subscribe(this, POCodes.Button.LEFT, _shape);
    messenger = theMessenger;
    imageCenter = aBoundingBox.getCenter();
    imageCenter.sub(aBoundingBox.getAbsMin());
    imageCenter.add(new PVector(0,hText));
    hImage = aBoundingBox.getHeight() - hText;
    
    font = createFont("Verdana", 12);
    //font = loadFont("Verdana-Bold.vlw");
    //String[] fontList = PFont.list();
    //println(fontList);
  }
  
  public void update() {
    float coef = (isPressed ? 0.8 : 0.6);
    diameter = hImage * coef;
  }
  
  public void draw() {
    
    if (_shape.getBoundingBox().contains(mouseX, mouseY)) {
        noStroke();
        fill(color(104,104,104));
        _shape.draw();
    }

    fill(color(176,96,256));
    noStroke();
    ellipseMode(CENTER); 
    ellipse(imageCenter.x, imageCenter.y, diameter, diameter);

    fill(color(192,128,256));
    textSize(12);
    textAlign(CENTER);
    textFont(font);
    text("Reset", imageCenter.x, 13); 
  
  }
  
  public void receive(MouseMessage m) {
    if (m.getAction() == POCodes.Click.PRESSED) {
        isPressed = true;
    }
    if (m.getAction() == POCodes.Click.RELEASED) {
        isPressed = false;
        println("sending reset request");
        messenger.sendActionMessage(ActionMessage.EVENT_COMMAND_RESET);
    }
  }

}
