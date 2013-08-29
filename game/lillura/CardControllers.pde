//
// CardDeckController : base class for all CardDeck controller. is responsibie for executing the cardDeck actions 
//TODO select and unselect are CardDeck operations
//TODO move some card deck operations to gui List classes  
//

class CardDeckController extends Controller { //FIXME synchronizaton of controllers
    CardGroup cards;
    CardDeckCanvas cardDeckCanvas;

    float hoverPosition = -1;
    int actionCardIndex = -1;
    
    CardDeckController(CardDeckCanvas aCardDeckCanvas, CardGroup aCardGroup, World aParentWorld, LilluraMessenger theMessenger) {
        super(aParentWorld, theMessenger);
        cards = aCardGroup;
        cardDeckCanvas = aCardDeckCanvas;
    }
    
    void reset() {
        actionCardIndex = -1;
    }
    
    void selectCurrentCard() {
        if (hoverPosition >= 0) {
            selectCard(int(hoverPosition));
        }
    }
    
    void selectCard(int pos) {
        actionCardIndex = pos;
        cards.setSelectedCardIndex(actionCardIndex);
        Card card = cards.getCard(actionCardIndex);
        card.select();
    }

    void hoverPreviousCard() {
        if (hoverPosition >= 1) {
             hoverPosition--;
             cards.setSelectedCardIndex(floor(hoverPosition));
        }
    }

    void hoverNextCard() { 
       if (hoverPosition < cards.getNumberOfCards() -1 ) {
             hoverPosition++;
             cards.setSelectedCardIndex(floor(hoverPosition));
        }
    }
    
    void moveAndDeselectCurrentCard(float y) {
        if (actionCardIndex >= 0) {
            Card card = cards.getCard(actionCardIndex);
            float index = cards.getCardIndexForMouse(y);
            //println("releasing card at index " + index);
            int newPos = (index == int(index)) ? floor(index) : ceil(index);
            //println("releasing card at pos " + newPos);
            cards.moveCardTo(card, newPos);
            card.deselect();
            actionCardIndex = -1;
        }
    }
    
    void deselectCurrentCard() {
        if (actionCardIndex >= 0) {
            Card card = cards.getCard(actionCardIndex);
            card.deselect();
            actionCardIndex = -1;
        }
    }
    
    void removeCurrentCard() {
        cards.removeSelectedCard();
        actionCardIndex = -1;
    }
}

class CardDeckKeyController extends CardDeckController {
  
    CardDeckKeyController(CardDeckCanvas aCardDeckCanvas, CardGroup aCardGroup, World aParentWorld, LilluraMessenger theMessenger) {
        super(aCardDeckCanvas, aCardGroup, aParentWorld, theMessenger);
    }
    
    public void receive(KeyMessage m) { //FIXME generates a command, and update do the switch
      if (! isActive) return;

      int code = m.getKeyCode();
      if (m.isPressed()) {
          switch (code) {
              case POCodes.Key.UP:
                  hoverPreviousCard(); 
                  break;
              case POCodes.Key.DOWN:
                  hoverNextCard();
                  break;
              case POCodes.Key.S:
                   removeCurrentCard();
                  break;
              case POCodes.Key.SPACE:
                  if (actionCardIndex>=0) {
                      deselectCurrentCard();
                  } else {
                      selectCurrentCard();
                  }
                  break;
              default:
                  // go ahead
                  break;
        }
      }
    }
    

}

//
// CardDeckMouseController : cardDeck controller with mouse
//

class CardDeckMouseController extends CardDeckController {
    private CardDeckMouseMarker cardDeckMouseMarker;
    
    CardDeckMouseController(CardDeckCanvas aCardDeckCanvas, CardGroup aCardGroup, CardDeckMouseMarker aCardDeckMouseMarker, World aParentWorld, LilluraMessenger theMessenger) {
        super(aCardDeckCanvas, aCardGroup, aParentWorld, theMessenger);
        cardDeckMouseMarker = aCardDeckMouseMarker;
    }

    public void preUpdate() {
        if (! isActive) return;

        Rectangle cardsBoundingBox = cards.getUsedBoundingBox();
        if (cardsBoundingBox.contains(mouseX, mouseY)) {
            float relativeY = mouseY - cardDeckCanvas.getBoundingBox().getAbsMin().y;
            hoverPosition = cards.getCardIndexForMouse(relativeY);
            cardDeckMouseMarker.setY(relativeY + cardDeckCanvas.getBoundingBox().getAbsMin().y);
            cardDeckMouseMarker.isVisible = true;
        } else {
            hoverPosition = -1;
            cardDeckMouseMarker.isVisible = false;
        }   
        
        if (hoverPosition == int(hoverPosition)) cards.setSelectedCardIndex(floor(hoverPosition));
    }
    
    public void receive(MouseMessage m) {
         if (! isActive) return;
  
        if (hoverPosition < 0) return;
        
        if (m.getAction() == POCodes.Click.PRESSED) {
            selectCurrentCard();
        }  
        if (m.getAction() == POCodes.Click.RELEASED) {
            float relativeY = mouseY - cardDeckCanvas.getBoundingBox().getAbsMin().y;
            moveAndDeselectCurrentCard(relativeY);
        }  
    }

}

//
// CardDeckPerceptualController : cardDeck controller with peceptual camera
//

class CardDeckPerceptualController extends CardDeckController {
    private CardDeckMouseMarker cardDeckMouseMarker;
    private float relativeY;
  
    CardDeckPerceptualController(CardDeckCanvas aCardDeckCanvas, CardGroup aCardGroup, CardDeckMouseMarker aCardDeckMouseMarker, World aParentWorld, LilluraMessenger theMessenger) {
        super(aCardDeckCanvas, aCardGroup, aParentWorld, theMessenger);
        cardDeckMouseMarker = aCardDeckMouseMarker;
    }

    void perCChanged(PerCMessage handSensor) {
        if (! isActive) return;
        
        Rectangle cardsBoundingBox = cards.getUsedBoundingBox();
        if (true) { 
            relativeY = (handSensor.y - cardDeckCanvas.getBoundingBox().getAbsMin().y) * 2;
            hoverPosition = cards.getCardIndexForMouse(relativeY);
            cardDeckMouseMarker.setY(relativeY + cardDeckCanvas.getBoundingBox().getAbsMin().y);
            cardDeckMouseMarker.isVisible = true;
        } else {
            hoverPosition = -1;
            cardDeckMouseMarker.isVisible = false;
        }   
        
        //println("changed hoverPosition to " + hoverPosition);
        if (hoverPosition == int(hoverPosition)) cards.setSelectedCardIndex(floor(hoverPosition));
     }

    void actionSent(ActionMessage message) {
        if (! isActive) return;

        try {
             switch(message.eventType) {
                case PERCEPTUAL_HAND_OPEN:
                    moveAndDeselectCurrentCard(relativeY);
                    break;
                case PERCEPTUAL_HAND_CLOSE:
                    selectCurrentCard();
                    break;
                case PERCEPTUAL_SWIPE_UP:
                    hoverPreviousCard();
                    break;
                case PERCEPTUAL_SWIPE_DOWN:
                    hoverNextCard();
                  break;
                //case PERCEPTUAL_HAND_MOVED_AWAY:
                //    removeCurrentCard();
                //    break;
                default:
                    // ignore other events
            }
        } catch (Exception e) {
            e.printStackTrace();
            println("controller " + this);
        }  
    }

}

