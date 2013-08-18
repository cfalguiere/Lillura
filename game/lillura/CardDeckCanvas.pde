class CardDeckCanvas extends Being {
  
  CardDeckCanvas(Rectangle boundingBox) {
        super(boundingBox);
        println("card deck canvas created");
  }
  
  public void update() {
    //_stroke = false;
  }

  public void draw() {
        fill(DECK_BG);
        noStroke();
        _shape.draw();
  }
}

