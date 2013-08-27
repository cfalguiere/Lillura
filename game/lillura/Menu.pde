//
// MenuCanvas : menu background
// 
class MenuCanvas extends Being {
  
  MenuCanvas(PVector position, int w, int h) {
        super(new Rectangle(position, w, h));
        println("creating menu canvas");
  }
  
  public void update() {
    //_stroke = false;
  }

  public void draw() {
      fill(MENU_BG);
      noStroke();
      _shape.draw();
  }
}

//
// MenuButton : common look & feel and behavior of buttons
// 
class MenuButton extends Being {
  
    String buttonLabel;
    
    boolean isPressed = false;
    LilluraMessenger messenger;
    float diameter;
    float hText = 6.0;
    PVector iconCenter;
    float iconHeight;
    color iconColor;
    PFont font;
  
    MenuButton(String aLabel, Rectangle aBoundingBox, World theParentWorld, LilluraMessenger theMessenger) {
        super(aBoundingBox);
        buttonLabel = aLabel;
        theParentWorld.subscribe(this, POCodes.Button.LEFT, _shape);
        messenger = theMessenger;
        
        iconCenter = aBoundingBox.getCenter();
        iconCenter.sub(aBoundingBox.getAbsMin());
        iconCenter.add(new PVector(0,hText));
        iconHeight = aBoundingBox.getHeight() - hText;
        iconColor = color(176,96,256);
        
        font = createFont("Verdana", 12); //FIXME creates a font per button
    }
  
    public void update() {
        float coef = (isPressed ? 0.7 : 0.6);
        diameter = iconHeight * coef;
    }
  
    public void draw() {
        if (_shape.getBoundingBox().contains(mouseX, mouseY)) {
            drawBackground();
        }   
        drawIcon();
        drawText();
    }
  
    protected void drawBackground() {
        noStroke();
        fill(color(104,104,104));
        _shape.draw();
    }
  
    protected void drawIcon() {
        fill(iconColor);
        noStroke();
        ellipseMode(CENTER); 
        ellipse(iconCenter.x, iconCenter.y, diameter, diameter);
    }
  
    protected void drawText() {
        fill(color(192,128,256));
        textSize(12);
        textAlign(CENTER);
        textFont(font);
        text(buttonLabel, iconCenter.x, 13); 
    }
  
    public void receive(MouseMessage m) {
        if (m.getAction() == POCodes.Click.PRESSED) {
            isPressed = true;
        }
        if (m.getAction() == POCodes.Click.RELEASED) {
            isPressed = false;
            execute();
        }
    }
    
    void execute() {
        // does nothing
        // allow to instantiate a button to protoype the GUI wihout creating all the subclasses
    }

}

//
// MenuButtonNewGame : reset button
// 

class MenuButtonNewGame extends  MenuButton {
  MenuButtonNewGame(Rectangle aBoundingBox, World theParentWorld, LilluraMessenger theMessenger) {
    super("New", aBoundingBox, theParentWorld, theMessenger);
  }
  
  void execute() {
        println("sending NewGame request");
        messenger.sendActionMessage(EventType.COMMAND_NEWGAME);
  }
}

//
// MenuButtonRestart : restart button
// 

class MenuButtonRestart extends  MenuButton {
    Polygon triangle;
    Polygon triangleDefault;
    Polygon trianglePressed;
    
    MenuButtonRestart(Rectangle aBoundingBox, World theParentWorld, LilluraMessenger theMessenger) {
      super("Restart", aBoundingBox, theParentWorld, theMessenger);
      triangleDefault = createPolygon(0.7);
      trianglePressed = createPolygon(0.85); 
    }
  
    protected Polygon createPolygon(float coef) {
        ArrayList<PVector> points = new ArrayList<PVector>();
        float angle = 0;
        for (int i=0; i<3; i++, angle+=TWO_PI/3) {
          PVector vertex = PVector.fromAngle(angle);
          vertex.mult(coef*iconHeight/2);
          vertex.add(iconCenter);
          points.add(vertex);
        } 
        return new Polygon(iconCenter, points);
    }

    protected void drawIcon() {
      pushMatrix();
      fill(iconColor);
      noStroke();
      triangle.draw();
      popMatrix();
    }

    public void update() {
        triangle = (isPressed ? trianglePressed : triangleDefault);
    }
    
    void execute() {
          println("sending restart request");
          messenger.sendActionMessage(EventType.COMMAND_RESTART);
    }
}

//
// MenuButtonReplay : replay button
// 

class MenuButtonPlay extends  MenuButton {
    MenuButtonPlay(Rectangle aBoundingBox, World theParentWorld, LilluraMessenger theMessenger) {
        super("Play", aBoundingBox, theParentWorld, theMessenger);
    }
    
    protected void drawIcon() {
        fill(iconColor);
        noStroke();
        rectMode(CENTER); 
        rect(iconCenter.x, iconCenter.y+1, diameter, diameter*.8);
    }

    void execute() {
          println("sending play request");
          messenger.sendActionMessage(EventType.COMMAND_PLAY);
    }
    
}


