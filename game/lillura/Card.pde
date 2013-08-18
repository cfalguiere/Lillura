/**
 * Card on the CardDeck
 */
class Card extends Being {
  static final int WIDTH = 80;
  static final int HEIGHT = 60;

  Card(PVector position) {
        super(new Rectangle(position, WIDTH, HEIGHT));
        //Add your constructor info here
        println("creating card at " + position);
  }

  public void update() {
    //_stroke = false;
  }

  public void draw() {
        fill(color(256,256,256));
        strokeWeight(1);
        stroke(0);
        _shape.draw();
  }
   
}

