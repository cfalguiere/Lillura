//
// MenuCanvas : menu background
// 
class MenuCanvas extends Being {
  
  MenuCanvas(PVector position, int w, int h) {
        super(new Rectangle(position, w, h));
        println("creating menu canvas");
  }
  
  public void update() {
    //_stroke = false;
  }

  public void draw() {
      fill(MENU_BG);
      noStroke();
      _shape.draw();
  }
}

//
// MenuButton : common look & feel and behavior of buttons
// 
class MenuButton extends Being {
  
  String buttonLabel;
  
  boolean isPressed = false;
  LilluraMessenger messenger;
  float diameter;
  float hText = 6.0;
  PVector imageCenter;
  float hImage;
  PFont font;
  
  MenuButton(String aLabel, Rectangle aBoundingBox, World theParentWorld, LilluraMessenger theMessenger) {
    super(aBoundingBox);
    buttonLabel = aLabel;
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
    text(buttonLabel, imageCenter.x, 13); 
  
  }
  
  public void receive(MouseMessage m) {
    if (m.getAction() == POCodes.Click.PRESSED) {
        isPressed = true;
    }
    if (m.getAction() == POCodes.Click.RELEASED) {
        isPressed = false;
        execute();
    }
  }
  
  void execute() {
    // does nothing
    // allow to instantiate a button to protoype the GUI wihout creating all the subclasses
  }

}

//
// MenuButtonReset : reset button
// 

class MenuButtonReset extends  MenuButton {
  MenuButtonReset(Rectangle aBoundingBox, World theParentWorld, LilluraMessenger theMessenger) {
    super("Reset", aBoundingBox, theParentWorld, theMessenger);
  }
  
  void execute() {
        println("sending reset request");
        messenger.sendActionMessage(EventType.COMMAND_RESET);
  }
}

//
// MenuButtonRestart : restart button
// 

class MenuButtonRestart extends  MenuButton {
  MenuButtonRestart(Rectangle aBoundingBox, World theParentWorld, LilluraMessenger theMessenger) {
    super("Restart", aBoundingBox, theParentWorld, theMessenger);
  }
  
  void execute() {
        println("sending reset request");
        messenger.sendActionMessage(EventType.COMMAND_RESTART);
  }
}

