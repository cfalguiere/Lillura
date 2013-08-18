class MenuButtonReset extends Being {
  boolean isPressed = false;
  LilluraMessenger messenger;
  
  MenuButtonReset(PVector position, float radius, World theParentWorld, LilluraMessenger theMessenger) {
        super(new Circle(position, radius));
       theParentWorld.subscribe(this, POCodes.Button.LEFT, _shape);
        messenger = theMessenger;
  }
  
  public void draw() {
    fill(color(176,96,256));
    if (isPressed) {
        noStroke();
    } else {
        strokeWeight(10);
        stroke(MENU_BG);
    }
    _shape.draw();
  }
  
  public void receive(MouseMessage m) {
    if (m.getAction() == POCodes.Click.PRESSED) {
        isPressed = true;
    }
    if (m.getAction() == POCodes.Click.RELEASED) {
        isPressed = false;
        println("sending reset request");
        messenger.sendActionMessage(ActionMessage.ACTION_RESET);
    }
  }

}
