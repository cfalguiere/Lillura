class MenuButtonReset extends Being {
  color _c;
  boolean _isPressed = false;
  World _world;
  GameLevel _gameLevel;
  
  MenuButtonReset(PVector position, float radius, World world, GameLevel gameLevel) {
        super(new Circle(position, radius));
        world.subscribe(this, POCodes.Button.LEFT, _shape);
        _world = world;
        _gameLevel = gameLevel;
  }
  
  public void draw() {
    fill(color(176,96,256));
    if (_isPressed) {
        noStroke();
    } else {
        strokeWeight(10);
        stroke(LIGHT_GREY);
    }
    _shape.draw();
  }
  
  public void receive(MouseMessage m) {
    if (m.getAction() == POCodes.Click.PRESSED) {
      _isPressed = true;
      println("reset");
    }
    if (m.getAction() == POCodes.Click.RELEASED) {
        _isPressed = false;
        println("release reset");
        _gameLevel.resetLevel();
    }
  }

}
