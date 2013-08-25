class CardDeckWorld extends World implements MessageSubscriber  {
  
  Rectangle deckBoundingBox;
  
  LilluraMessenger messenger = null;  
  CardGroup cards;
  
  //GameLevel _gameLevel;  
  
  CardDeckWorld(int portIn, int portOut, Rectangle aBoundingBox, LilluraMessenger theMessenger) {
      super(portIn, portOut);
      deckBoundingBox = aBoundingBox;
      messenger = theMessenger;
  }

  void setup() {
      //IMPORTANT: put all other setup hereterBeing(TemplateBeing);
      createDeck();

      messenger.subscribe(this);
    
      println("CardDeck world set up");
  }

  //
  // behavior implementation 
  //
    void actionSent(ActionMessage message) {
      switch (message.eventType) {
         case ROBOT_ACTION_COMPLETED :
            cards.addCard(message.robotAction.movementType, message.robotAction.distance());
            break;
         case COMMAND_RESET :
         case COMMAND_RESTART :
            resetDeck();
            break;
         default :
             break;
      }
    }
    
    void perCChanged(PerCMessage event) {
      // don't care
    }
  //
  // World construction
  //
    
  void createDeck() {      
      cards = new CardGroup(this, deckBoundingBox); 
      register(cards);
      subscribe(cards, POCodes.Button.LEFT, deckBoundingBox);
      
      CardDeckCanvas cardDeck = new CardDeckCanvas(deckBoundingBox, cards); 
      register(cardDeck);
      
      PVector position3D = new PVector(deckBoundingBox.getPosition().x, deckBoundingBox.getPosition().y, -1);
      Rectangle mouseMarker = new Rectangle(position3D, deckBoundingBox.getWidth() -12, 1);
      CardDeckMouseMarker cardMouseMarker = new CardDeckMouseMarker(mouseMarker, cards);
      register(cardMouseMarker);
  }

  void resetDeck() {
       cards.destroy();
       createDeck();
  }


}

