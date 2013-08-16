/**
 * Template being
 */
class LilluraBeing extends Being {
  static final int WIDTH = 50;
  static final int HEIGHT = 50;
  final color RED = color(256,0,0);
  color _c;
  boolean _stroke = false;

  LilluraBeing(int x, int y, color pc) {
        super(new Rectangle(x, y, WIDTH, HEIGHT));
        _c = pc;
        //Add your constructor info here
        println("creating bloc at " + x + " " + y);
  }

  public void update() {
    //_stroke = false;
  }

  public void draw() {
        fill(_c);
        if(_stroke) {
            strokeWeight(5);
            stroke(RED);
        } else {
            noStroke();
        }       
        _shape.draw();
  }
  
  public void handleProtect() {
    _stroke = true;
  }
 
}

