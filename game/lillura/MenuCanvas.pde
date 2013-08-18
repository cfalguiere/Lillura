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

