// The TEDS spACE program
// Plot TEDS statistics on a map of the UK
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

// Use openGL to enable graphics cards
//import processing.opengl.*;
import java.awt.event.*;

// Set up global variables
PImage logoImage;
PImage tinyMap;
PImage[] spinner = new PImage[12];
int recordCount = 0;

// Diverging colour palette on a dark background; modify for different types of data
int[] colours = {#20D2FF,#23BCEE,#26A7DD,#2A92CC,#2D7DBB,#3168AA,#345399,
#383E88,#3B2977,#3F1466,#541561,#69165D,#7E1859,#941955,#A91A50,#BE1C4C,
#D41D48,#E91E44,#FF2040};
int[] colourIndex;
float imageWidth = 3500;
float imageHeight = 5500;
Integrator zoomFactor =  new Integrator(1.0);
float zoom = 1.0;
Integrator focusX = new Integrator();
Integrator focusY = new Integrator();
float focX;
float focY;
int pointX;
int pointY;
float easing = 0.05;
SmallMap small;
int lastTime = 0;
int rotation = 0;
boolean waitMode = true;
PFont plotFont;
int zoomTime = 0;
BarChart chart;
int currentColumn = 0;
FloatTable data;
int[] eastings;
int[] northings;
PFont mapFont = createFont("Junction 02", 16);
NameBar2 columns;
DataToggle toggle;
DescriptionBar description;
String[] descriptionArray;
int MAPWIDTH = 3500;
int MAPHEIGHT = 5500;
int readyCount;
int oldHeight;
int oldWidth;


// Array for holding map tiles
PImage[][] tiles = new PImage[7][11];

// Setup environment
void setup( ) {
  
// Modify for Web display
  size(955,700);
  
  background(20) ;
  
  logoImage = loadImage("sharpspACE.png");
  tinyMap = loadImage("tiny_map.jpg");
  
  // Load images for the 'waiting' spinner
  for(int i = 0; i < 12; i++){
    spinner[i] = loadImage("waiting"+nf(i,2)+".png");
  }

  // Modify to load new dataset; 'missing' is currently -9
  data = new FloatTable("year12phenotypes.csv");

  // Descriptions of the phenotypes
  descriptionArray = loadStrings("phenotypeDescriptions.txt");

  eastings = new int[data.getRowCount()];
  northings = new int[data.getRowCount()];
  eastings = data.getEastings();
  northings = data.getNorthings();
  
  focusX.set(0);
  focusY.set(0);
  
  // Load map tiles
  for(int i=0; i<7; i++){
    for(int j=0; j<11; j++){
      tiles[i][j]=requestImage("maptile"+nf(i,2)+nf(j,2)+".jpeg");
    }
  }
  
  // Set up the histogram for the bottom left
  chart = new BarChart(0, height-250, 250, 250, data, colours, currentColumn);
  
  // Make a font for the main text
  plotFont = createFont("Junction 02", 30);

  // Decide what colour to use for each value
  colourIndex = updateColourIndex(data,currentColumn);
  
  // Names of variables for lefthand bar
  columns = new NameBar2(0,100,250,height-370,data,currentColumn);
  
  // Button to toggle data for the bottom right
  toggle = new DataToggle(width-50,height-30,50,30);
  
  // Description bar for current dataset
  description = new DescriptionBar(250,height-30,width-300,30,currentColumn,descriptionArray);
  
  // Standardise framerate
  frameRate(20);
  
  oldHeight = height;
  oldWidth = width;
  
  // Set up for resizing the frame
  frame.setResizable(true);
          
  frame.addComponentListener(new ComponentAdapter() {
    public void componentResized(ComponentEvent e) {
      if(e.getSource()==frame) {
        if(frame.getHeight()<400) frame.setSize(frame.getWidth(),400);
        if(frame.getWidth()<500) frame.setSize(500,frame.getHeight());
        redraw();
      }
    }
  });
  
}

// Animation loop
void draw(){
  // If the data haven't loaded yet...
  if(waitMode){

    if(millis()-lastTime > 50){

      background(20) ;
      imageMode(CORNERS);
      image(logoImage, 20, 15);
      imageMode(CENTER);
      translate(width/2,height/2);
      image(spinner[rotation], 0, 0);
      lastTime=millis();
      if(rotation == 11){
        rotation = 0;
      }else{
        rotation++;
      }
      
      // Have we loaded all the tiles?
      readyCount = 0;
      for(int i=0; i<7; i++){
          for(int j=0; j<11; j++){
            if(tiles[i][j].width > 1) readyCount++;
          }
       }

       if (readyCount==77){
          waitMode = false;
          small = new SmallMap(width - 230, 20,210, 330, tinyMap, data, colours, currentColumn);
       }
    }
    
  }else{
    
    // Else, display the data screen
    
    if(oldWidth != width || oldHeight != height){
      columns.setDimY(height-350);
      toggle.setXY(width-50,height-30);
      description.setDimX(width-300);
      description.setXY(250,height-30);
      chart.setXY(0, height-250);
      small.setXY(width - 230, 20);
    }
    
    background(20);
    zoom = zoomFactor.get();
    focX = focusX.get();
    focY = focusY.get();

    imageMode(CENTER);
    
    // Set up drawing area, based on current position and zoom
    pushMatrix();
    translate(width/2,height/2);
    
    for(int i=0; i<7; i++){
      for(int j=0; j<11; j++){
        image(tiles[i][j],(((i-3)*500)+focX)*zoom,(((j-5)*500)+focY)*zoom,500*zoom,500*zoom);
      }
    }
    
    // If the data points are switched on, draw them
    if(toggle.getStatus()){
      drawDataPoints(zoom, focX, focY);
    }
    popMatrix();
    
    // Translucent side bar
    rectMode(CORNER);
    fill(20,200);
    noStroke();
    rect(0,0,250,height);
    
    // Translucent small map frame
    rect(width-250,0,250,370);
    
    // TEDS logo
    imageMode(CORNER);
    image(logoImage, 20, 15);
 
    pointX = mouseX;
    pointY = mouseY;
    
    // Small navigation map
    small.drawMap(focX,focY,zoom);
    
    // Data histogram
    chart.drawBarChart();
    
    // Draw the zoom in/out buttons (should make this a class, probably)
    fill(20);
    noStroke();
    rectMode(CORNER);
    rect(width-60, 20,40,80);
    textAlign(CENTER,CENTER);
   
    zoomFactor.update();
    focusX.update();
    focusY.update();
    
    textFont(plotFont);
   
    if(zoom<zoomFactor.get()){
      fill(255);
    }else{
      fill(150);
    }
    text("+",width-38,36);
    
    if(zoom>zoomFactor.get()){
      fill(255);
    }else{
      fill(150);
    }
    text("-",width-39,76);
    
    
    // Draw the variable selection bar
    columns.drawNameBar();
    
    // Draw the data toggle button
    toggle.drawDataToggle();
    
    // Draw the description bar
    description.drawDescriptionBar();


    // If there's no need to redraw, stop the animation loop to save CPU time
    if(mousePressed == false && zoom==zoomFactor.get() && focX==focusX.get() && focY==focusY.get()){
      noLoop();
    }
  }
  
}


// Draw the data as a series of points
void drawDataPoints(float zoom, float focX, float focY) {

  noStroke();
  rectMode(CENTER);
  
  float trMouseX = mouseX-(width/2);
  float trMouseY = mouseY-(height/2);
  float distMouse;
  
  // Array to work out the nearest data point to the cursor for pop-up info
  float[] minDist = new float[5];
  for(int i=0; i<minDist.length; i++){
    minDist[i]=Float.MAX_VALUE;
  }
  
  // Modify this to make the data points larger or smaller on the main map
  float rectSize = 12*zoom;
  
  // For each data point
  int recordCount = data.getRowCount();
  for (int row = 0; row < recordCount; row++) {

    float x = (map(eastings[row], 0, 700000, 0, imageWidth) - imageWidth/2 +focX)*zoom;
    float y = (map(northings[row], 0, 1100000, imageHeight, 0) - imageHeight/2 +focY)*zoom;
    
    // Skip points that fall outside the screen
    if(abs(x)>8+screenWidth/2 || abs(y)>8+screenHeight/2) continue;
    
    float value = data.getFloat(row,currentColumn);
    
    // Missing values are transparent
    if(value == -9){
       fill(#333333,0) ;
       rect(x, y,rectSize,rectSize) ;
    }else {
      // Use the colour index to determine the point colour
        fill(color(colours[colourIndex[row]])) ;
       rect(x, y,rectSize,rectSize) ;
       distMouse = dist(trMouseX,trMouseY,x,y);
       
       // If cursor is hovering over the main display, record closest point
       if(distMouse<minDist[2] && mouseX > 250){
         minDist[0] = x;
         minDist[1] = y;
         minDist[2] = distMouse;
         minDist[3] = value;
         minDist[4] = colourIndex[row];
       }
    }

  }
  
  // If the mouse is over the main display and touching a datapoint...
  if(minDist[2]<6 && mouseX > 250){
    
    // Draw a pop-up with the data value
        noFill();
        stroke(255);
        float x =minDist[0];
        float y = minDist[1];

      float value = minDist[3];
      String nm = nfp(value, value<10 ? 1:2, 2);
      fill(255);
      textAlign(LEFT,BASELINE);
      textFont(mapFont);
      noStroke();
      fill(20,150);
      rectMode(CORNER);
      rect(x+20,y-25,textWidth(nm)+2,18);
      fill(255);
      text(nm,x+20,y-11);
      stroke(255);
      strokeWeight(1);
      line(x+18,y-12,x+12,y-12);
      line(x+12,y-12,x,y);
      rectMode(CENTER);
      rect(x,y,5,5);

      noStroke();
        
      chart.markBar(int(minDist[4]));
  }
}

// Function to work out which colour each point should be
// Called when you change dataset
int[] updateColourIndex(FloatTable data, int currentColumn){
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

// What to do when keys are pressed or the mouse is used
void keyPressed() {
  if (key == CODED) {
    if (keyCode == UP) {
        loop();
        zoomFactor.target(constrain(zoomFactor.get()+0.1,0.1,1.0));
    } else if (keyCode == DOWN) {
        loop();
        zoomFactor.target(constrain(zoomFactor.get()-0.1,0.1,1.0));
    } else if (keyCode == LEFT ) {
        currentColumn--;
        if (currentColumn < 0) {
            currentColumn = data.getColumnCount() - 1;
        }
        small.changeColumn(currentColumn);
        chart.changeColumn(currentColumn);
        columns.changeColumn(currentColumn);
        description.changeColumn(currentColumn);
        colourIndex = updateColourIndex(data,currentColumn);
        redraw();
    } else if (keyCode == RIGHT ) {
        currentColumn++;
        if (currentColumn == data.getColumnCount()) {
            currentColumn = 0;
        }
        small.changeColumn(currentColumn);
        chart.changeColumn(currentColumn);
        columns.changeColumn(currentColumn);
        description.changeColumn(currentColumn);
        colourIndex = updateColourIndex(data,currentColumn);
        redraw();
    }

  }
}

void mousePressed(){
   loop();
   columns.switchPressed(true);
   pointX = mouseX;
   pointY = mouseY;
}

void mouseReleased(){
  columns.switchPressed(false);
}

void mouseMoved(){
  chart.unmarkBar();
  columns.noHover();
  columns.checkHover();
  redraw();
}

void mouseDragged(){
  loop();
  if(mouseX > 250 && (mouseX < width-250 || mouseY > 370)){
   focusX.target(focusX.get());
   focusY.target(focusY.get());

   focusX.set(constrain(focusX.get() + (mouseX - pointX)*(1/zoom),-MAPWIDTH/2,MAPWIDTH/2));
   focusY.set(constrain(focusY.get() + (mouseY - pointY)*(1/zoom),-MAPHEIGHT/2,MAPHEIGHT/2));
   
   columns.checkDrag();
  }else{
   columns.checkDrag();
  }
   
   pointX = mouseX;
   pointY = mouseY;
}

void mouseClicked(){
   loop();
   if(mouseX > width-60 && mouseX < width-20 && mouseY > 20 && mouseY < 60){
     zoomFactor.target(constrain(zoomFactor.get()+0.2,0.1,1.0));
   }else if(mouseX > width-60 && mouseX < width-20 && mouseY > 60 && mouseY < 100){
     zoomFactor.target(constrain(zoomFactor.get()-0.2,0.1,1.0));
   }else if(mouseX > small.posX && mouseX < small.posX+small.dimX && mouseY > small.posY && mouseY < small.posY+small.dimY){
    float shiftX = -1*map(mouseX-small.posX,0,small.dimX,-MAPWIDTH/2,MAPWIDTH/2);
    float shiftY = -1*map(mouseY-small.posY,0,small.dimY,-MAPHEIGHT/2,MAPHEIGHT/2);
    focusX.target(shiftX);
    focusY.target(shiftY);
  }
  int selectedColumn = columns.checkClick();
  if(selectedColumn != currentColumn){
    currentColumn = selectedColumn;
    small.changeColumn(currentColumn);
    chart.changeColumn(currentColumn);
    columns.changeColumn(currentColumn);
    description.changeColumn(currentColumn);
    colourIndex = updateColourIndex(data,currentColumn);
  }
  toggle.checkClick();
}


