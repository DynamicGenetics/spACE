// Class for a simple button to toggle the datapoints on and off
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

class DataToggle{
  
  int posX;
  int posY;
  int dimX;
  int dimY;
  boolean dataOn;
  PFont toggleFont;
  
  // Constructor
  public DataToggle(int posX, int posY, int dimX, int dimY){
    this.posX = posX;
    this.posY = posY;
    this.dimX = dimX;
    this.dimY = dimY;
    this.dataOn = true;
    this.toggleFont = createFont("Junction 02", 16);
  }
  
  // Called in the animation loop
  public void drawDataToggle(){
    pushMatrix();
    translate(posX,posY);
    
    rectMode(CORNERS);
    fill(20,200);
    noStroke();
    rect(0,0,dimX,dimY);
    textAlign(LEFT,TOP);
    textFont(toggleFont);
    if(dataOn){
      fill(255);
    }else{
      fill(100);
    }
    text("Data",8,6);
    
    popMatrix();
  }
 
  // Are the data on or off?
  public boolean getStatus(){
    return(dataOn);
  }
  
  // Has the button been clicked?
  public int checkClick(){
    if(mouseX > posX && mouseX < posX+dimX && mouseY > posY && mouseY < posY+dimY){
      if(dataOn){
        dataOn = false;
      }else{
        dataOn = true;
      }
    }
    return(currentColumn);
  }
  
  public void setXY(int x, int y){
    this.posX = x;
    this.posY = y;
  }
  
}