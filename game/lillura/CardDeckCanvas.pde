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
        
        int selectedCardIndex = cardGroup.getSelectedCardIndex(); //TODO refactoring - dedicated object
        if (selectedCardIndex >= 0) {
            stroke(GREEN);
            strokeWeight(2);
            float y = cardGroup.getCardOffset().y*selectedCardIndex;
            line(HRZ_SPACER, y+3, HRZ_SPACER, y+Card.HEIGHT-3);
            line(HRZ_SPACER+Card.WIDTH+4, y+3, HRZ_SPACER+Card.WIDTH+4, y+Card.HEIGHT-3);
        }

  }

}

//
//  CardDeckMouseMarker : displays the line marker
//

class CardDeckMouseMarker extends Being {
    CardGroup cardGroup;
    boolean isVisible = false;
    float currentY;

    CardDeckMouseMarker(Rectangle aBoundingBox, CardGroup theCardGroup) {
        super(aBoundingBox);
        cardGroup = theCardGroup;
        println("card deck mouse marker created");
    }

    public void update() {
        if (isVisible) {
            _position.set(new PVector(_shape.getBoundingBox().getAbsMin().x, currentY));
        }
    }
    
    void setY(float y) {
        currentY = y;
    }

    public void draw() {
        if (isVisible) {
          stroke(GREEN);
          strokeWeight(2);
          //line(1, y, _shape.getBoundingBox().getWidth() -5, y);
          _shape.draw();
        }
    }
}
