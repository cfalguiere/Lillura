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
  // World construction
  //
    
  void createDeck() {      
      CardDeckCanvas cardDeck = new CardDeckCanvas(deckBoundingBox); 
      register(cardDeck);
      
      cards = new CardGroup(this, deckBoundingBox); 
      register(cards);
  }


  void perCChanged(PerCMessage handSensor) {
    // don't care
  }

  void actionSent(ActionMessage event) {
    if (event.action == ActionMessage.ACTION_COMPLETED) {
        cards.addCard();
    }
  }

}

