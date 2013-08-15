/**
 * Template being
 */
class Robot extends Being {
  static final int WIDTH = 30;
  static final int HEIGHT = 30;
  static final int STEP = 5;
  static final int DEFAULT_COLOR = 127; 
  color _c;
  boolean _isOn = true;

  Robot(int x, int y) {
        super(new Rectangle(x, y, WIDTH, HEIGHT));
        _c = color(DEFAULT_COLOR );
        //Add your constructor info here
        println("creating robot at " + x + " " + y);
  }

  public void update() {
    if (! _isOn) return;
    
    if (_position.y > 50) {
      _position.y += -STEP;    
    }
  }

  public void draw() {
        fill(_c);
        noStroke();
        _shape.draw();
  }
  
    
  private color defaultColor() {
     return color(int(random(256)), int(random(256)), int(random(256)));
  }
  
  public void actionStop() {
    _isOn = false;
  }

}

