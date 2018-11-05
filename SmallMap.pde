// Class describing the small, clickable overview map
// Copyright Oliver Davis 2011

// This file is part of spACE.

// spACE is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.

// spACE is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
  
// You should have received a copy of the GNU General Public License
// along with spACE. If not, see <http://www.gnu.org/licenses/>.

class SmallMap {
  
  int posX;
  int posY;
  int dimX;
  int dimY;
  PImage mapImage;
  FloatTable data;
  int[] colours;
  PGraphics currentMap;
  PGraphics nextMap;
  int currentColumn;
  int[] colourIndex;
  
  // Constructor
  public SmallMap(int posX, int posY, int dimX, int dimY, PImage mapImage, FloatTable data, int[] colours, int currentColumn){
    this.posX = posX;
    this.posY = posY;
    this.dimX = dimX;
    this.dimY = dimY;
    this.mapImage = mapImage;
    this.data = data;
    this.colours = colours;
    this.currentColumn = currentColumn;
    this.colourIndex = updateColourIndex(data,currentColumn);
    this.currentMap = createMapImage();
  }
  
  // Overloaded and called below
  public void drawMap(){
    imageMode(CORNER);
    image(mapImage, posX, posY,dimX,dimY);
    image(currentMap, posX, posY);
    rectMode(CORNER);
    noFill();
    stroke(20);
    rect(posX, posY, dimX, dimY);
    noStroke();
  }
  
  // Called in the animation loop
  public void drawMap(float focusX, float focusY, float zoom){
    this.drawMap();
    float smallFocusX = map(focusX*-1, 0, 3500, 0,dimX);
    float smallFocusY = map(focusY*-1, 0, 5500, 0,dimY);
    float windowWidth = map(width*(1/zoom), 0, 3500, 0, dimX);
    float windowHeight = map(height*(1/zoom), 0, 5500, 0, dimY);
    noFill();
    stroke(255);
    strokeWeight(1);
    rectMode(CENTER);
    pushMatrix();
    translate(posX+dimX/2,posY+dimY/2);
    rect(smallFocusX, smallFocusY, windowWidth, windowHeight);
    popMatrix();
  }
  
  // Make a new image of the overview map with the data, so
  // we don't need to draw all the data points twice in the animation loop,
  // just display this ready made map
  private PGraphics createMapImage(){
    // Draw offscreen
    PGraphics pg = createGraphics(dimX,dimY,JAVA2D);
    pg.beginDraw();
    pg.smooth();
    pg.noStroke();
    pg.imageMode(CORNER);
    int[] eastings;
    int[] northings;
    eastings = new int[data.getRowCount()];
    northings = new int[data.getRowCount()];
    eastings = data.getEastings();
    northings = data.getNorthings();
    int recordCount = data.getRowCount();
    for (int row = 0; row < recordCount; row++) {
      float x = map(eastings[row], 0, 700000, 0, dimX);
      float y = map(northings[row], 0, 1100000, dimY, 0);
      float value = data.getFloat(row,currentColumn);
      
      if(value == -9){
         pg.fill(#333333,0) ;
         pg.rect(x, y,3,3) ;
      }else{
        pg.fill(color(colours[colourIndex[row]])) ;
        pg.rect(x, y,3,3) ;
      }
    }
    pg.endDraw();
    return(pg);
  }
  
  // Called when a new variable is requested from the dataset
  public void changeColumn(int newColumn){
    this.currentColumn = newColumn;
    colourIndex = updateColourIndex(data,currentColumn);
    this.currentMap = createMapImage();
  }
  
  // Called internally to update the mapping of colours to values
  private int[] updateColourIndex(FloatTable data, int currentColumn){
    int[] colours = new int[data.getRowCount()];
    float[] bins = new float[19];
    float dmin = data.getColumnMin(currentColumn);
    float dmax = data.getColumnMax(currentColumn);
    float ivl = (dmax-dmin)/19;
    float lower = dmin-1;
    for(int i = 0; i < bins.length; i++){
      bins[i] = dmin+(ivl*(i+1));
    }
    for(int i = 0; i < bins.length; i++){
      for(int row = 0; row < colours.length; row++){
        float x = data.getFloat(row,currentColumn);
        if((x > lower) && (x <= bins[i])) colours[row] = i;
      }
      lower = bins[i];
    }
    return(colours);
  }
  
  public void setXY(int x, int y){
    this.posX = x;
    this.posY = y;
  }
  
}