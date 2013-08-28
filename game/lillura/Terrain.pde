class Terrain extends Being {
    static final int BORDER_HEIGHT = 16;
    final color BORDER_COLOR = color(232,232,216);
    
    ArrayList<PVector> cells;
    float cellWidth;
    float cellHeight;
    boolean  shouldShowGrid = false;
    
    Rectangle departure;
    Rectangle arrival;
      
    Terrain(int x, int y, int w, int h) {
          super(new Rectangle(x, y, w, h));
          println("creating terrain");
    }
    
    public void update() {
      //_stroke = false;
    }

    public void draw() {
        drawBackground();
        
        pushMatrix();
        fill(BORDER_COLOR);
        noStroke();
        drawDepartureBorder();
        drawArrivalBorder();
        popMatrix();
         
        if (shouldShowGrid) {
            drawGrid();
        }
    }
    
    protected void drawBackground() {
        fill(color(256,256,256));
        noStroke();
        _shape.draw();
    }
    
    protected void drawArrivalBorder() {
        drawBorder(arrival, 0);
    }

    protected void drawDepartureBorder() {
        float y = _shape.getBoundingBox().getHeight()-BORDER_HEIGHT;
        drawBorder(departure, y);
    }

    protected void drawBorder(Rectangle reservedRectangle, float y) {
        float w1 = reservedRectangle.getAbsMin().x - _shape.getBoundingBox().getAbsMin().x;
        float w2 = _shape.getBoundingBox().getWidth() - w1 - reservedRectangle.getWidth();
        rect(0, y, w1, BORDER_HEIGHT);
        rect(w1 + reservedRectangle.getWidth(), y, w2, BORDER_HEIGHT);
    }

    protected void drawGrid() {
        pushMatrix();
        translate(-_shape.getBoundingBox().getAbsMin().x, -_shape.getBoundingBox().getAbsMin().y);
        for (PVector cell : cells) {
          stroke(232);
          line(cell.x, cell.y, cell.x+cellWidth, cell.y );
          line(cell.x, cell.y, cell.x, cell.y+cellHeight );
        }
        popMatrix();
    }

    void showGrid(ArrayList<PVector> allCells, float aWidth, float aHeight) {
        cells = allCells;
        cellWidth = aWidth;
        cellHeight = aHeight;
        shouldShowGrid = true;
    }

    void setDeparture(PVector aPosition) {
        departure = new Rectangle(aPosition, Goal.WIDTH, BORDER_HEIGHT); 
    }

    void setArrival(PVector aPosition) {
        arrival = new Rectangle(aPosition, Goal.WIDTH, BORDER_HEIGHT); ;
    }
}


