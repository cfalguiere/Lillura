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
    
    boolean isPerceptualMode = false;

    CardDeckMouseMarker(Rectangle aBoundingBox, CardGroup theCardGroup) {
        super(aBoundingBox);
        cardGroup = theCardGroup;
        println("card deck mouse marker created");
    }

    public void update() {
        if (cardGroup.getUsedBoundingBox().contains(mouseX, mouseY)) {
            float y = 0;
            /*if (isPerceptualMode) {
                y = ( mouseY * _shape.getBoundingBox().getHeight()) / height;
            } else {*/
                y = mouseY - _shape.getBoundingBox().getAbsMin().y;
            //}
            _position.set(new PVector(_shape.getBoundingBox().getAbsMin().x, mouseY));
            isVisible = true;
        } else {
            isVisible = false;
        }
    }
    
    void setPerceptualMode(boolean b) {
      isPerceptualMode = b;
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
