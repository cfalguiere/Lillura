class MenuButtonReset extends Being {
  boolean isPressed = false;
  
  MenuButtonReset(PVector position, float radius, World world) {
        super(new Circle(position, radius));
        world.subscribe(this, POCodes.Button.LEFT, _shape);
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
      println("reset");
    }
    if (m.getAction() == POCodes.Click.RELEASED) {
        isPressed = false;
        println("release reset");
        //_gameLevel.resetLevel();  //TODO send message
    }
  }

}
