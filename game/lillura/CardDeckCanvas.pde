class CardDeckCanvas extends Being {
 
  Rectangle boundingBox;
  CardGroup cardGroup;
  int selectedCardIndex;
  
 
  CardDeckCanvas(Rectangle aBoundingBox, CardGroup theCardGroup) {
        super(aBoundingBox);
        boundingBox = aBoundingBox;
        cardGroup = theCardGroup;
        println("card deck canvas created");
  }
  
  public void update() {
  }

  public void draw() {
        fill(DECK_BG);
        noStroke();
        _shape.draw();
        
        int selectedCardIndex = cardGroup.getSelectedCardIndex();
        if (selectedCardIndex >= 0) {
          stroke(GREEN);
          strokeWeight(2);
          float y = cardGroup.getCardOffset().y*selectedCardIndex;
          line(HRZ_SPACER, y+3, HRZ_SPACER, y+Card.HEIGHT-3);
          line(HRZ_SPACER+Card.WIDTH+4, y+3, HRZ_SPACER+Card.WIDTH+4, y+Card.HEIGHT-3);
        }
  }

}

