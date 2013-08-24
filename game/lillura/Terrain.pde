class Terrain extends Being {
  
  ArrayList<PVector> cells;
  float cellWidth;
  float cellHeight;
  boolean  shouldShowGrid = false;

  
  Terrain(int x, int y, int w, int h) {
        super(new Rectangle(x, y, w, h));
        println("creating terrain");
  }
  
  public void update() {
    //_stroke = false;
  }

  public void draw() {
      fill(color(256,256,256));
      noStroke();
      _shape.draw();
/*
      strokeWeight(15);
      stroke(GREEN);
      float w =  _shape.getBoundingBox().getWidth();
      float h =  _shape.getBoundingBox().getHeight();
      line(0, 0, w, 0);
      line(0, 0, 0, h);
      line(w, 0, w, h);
      line(0, h, w, h);
 */       
      if (shouldShowGrid) {
        pushMatrix();
        translate(-_shape.getBoundingBox().getAbsMin().x, -_shape.getBoundingBox().getAbsMin().y);
        //println("showing grid");
        for (PVector cell : cells) {
          stroke(192);
          line(cell.x, cell.y, cell.x+cellWidth, cell.y );
          line(cell.x, cell.y, cell.x, cell.y+cellHeight );
        }
        popMatrix();
      }
  }

  void showGrid(ArrayList<PVector> allCells, float aWidth, float aHeight) {
    cells = allCells;
    cellWidth = aWidth;
    cellHeight = aHeight;
    shouldShowGrid = true;
  }

}

