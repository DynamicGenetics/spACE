// Class to display the variables available in the dataset, allows them to be selected
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

class NameBar2{
  
  int posX;
  int posY;
  int dimX;
  int dimY;
  FloatTable data;
  PFont nameFont;
  int currentColumn;
  String[] slots;
  int spacing;
  int hoverColumn;
  int scrollY;
  int overhang;

  int offset;
  boolean pressed;
  
  // Constructor
  public NameBar2(int posX, int posY, int dimX, int dimY, FloatTable data, int currentColumn){
    this.posX = posX;
    this.posY = posY;
    this.dimX = dimX;
    this.dimY = dimY;
    this.data = data;
    this.currentColumn = currentColumn;
    this.nameFont = createFont("Junction 02", 16);
    this.slots = new String[data.getColumnCount()];
    slots = data.getColumnNames();
    this.spacing = 20;
    this.hoverColumn = -9;
    this.scrollY = 0;
    this.overhang = dimY-(slots.length*spacing);
    this.offset = 0;
  }
  
  // Called in the animation loop
  public void drawNameBar(){
    pushMatrix();
    translate(posX,posY);
    
    this.offset = round(map(scrollY,0,dimY,0,overhang));
    
    int firstTrait = 0;
    int lastTrait = slots.length-1;
    
    for(int i=0; i < slots.length; i++){
      if((spacing*i)+offset < 0){
        fill(0,0);
        firstTrait = i+1;
      }else if((spacing*(i+1))+offset > dimY){  
        fill(0,0);
        if(lastTrait == slots.length-1) lastTrait = i-1;
      }else if(i == currentColumn){
        fill(255);
      }else if(i == hoverColumn){
        fill(180);
      }else{
        fill(100);
      }
      textAlign(LEFT,TOP);
      textFont(nameFont);
      text(slots[i],20,(i*spacing)+offset);
    }
    if(slots.length*spacing > dimY){
      drawScrollBar();
    }
    fill(180);
    text((firstTrait+1)+"-"+(lastTrait+1)+" of "+slots.length,20,dimY);
    popMatrix();
  }
  
  // Called when a different variable is requested (using keys, rather than clicking)
  public void changeColumn(int newColumn){
    this.currentColumn = newColumn;
  }
  
  // Has a variable been selected?
  public int checkClick(){
    if(mouseX > posX && mouseX < posX+dimX-30 && mouseY > posY && mouseY < posY+dimY){
      for(int i=0; i< slots.length; i++){
        if(mouseY >= posY+(i*spacing)+offset && mouseY < posY+((i+1)*spacing)+offset){
          return(i);
        }
      }
    }
    return(currentColumn);
  }
  
  // Is the mouse hovering over one of the variable names?
  public void checkHover(){
    if(mouseX > posX && mouseX < posX+dimX-30 && mouseY > posY && mouseY < posY+dimY){
      for(int i=0; i< slots.length; i++){
        if(mouseY >= posY+(i*spacing)+offset && mouseY < posY+((i+1)*spacing)+offset){
          hoverColumn = i;
        }
      }
    }
  }
  
  public void noHover(){
    hoverColumn = -9;
  }
  
  // Called internally to draw a scroll bar for datasets with lots of variables
  // that don't fit on the screen
  private void drawScrollBar(){
    stroke(0);
    rectMode(CORNERS);
    noStroke();
    fill(0);
    rect(dimX-21,0,dimX-19,dimY);
    noStroke();
    fill(80);
    rectMode(CENTER);
    rect(dimX-20,scrollY,20,20);
    if(mouseX > posX+dimX-30 && mouseX < posX+dimX-10 && abs(mouseY-posY-scrollY) < 10){
      fill(255);
    }else if(this.pressed){
      fill(255);
    }else{
      fill(0);
    }
   
    triangle(dimX-20,scrollY-8,dimX-23,scrollY-2,dimX-17,scrollY-2);
    triangle(dimX-20,scrollY+8,dimX-23,scrollY+2,dimX-17,scrollY+2);
  }
  
  // Has the mouse dragged the scroll bar?
  public void checkDrag(){
    if(mouseX < posX+dimX && this.pressed == true){
      this.scrollY=constrain(mouseY-posY,0,dimY);
    }else {
      this.pressed = false;
    }
  }
  
  // Used to toggle dragging on and off
  // This allows the mouse to wander from the scroll bar while dragging,
  // so long as the button remains pressed. Makes moving the scroll bar
  // less of a dexterity test, so you can concentrate on the variable names.
  public void switchPressed(boolean prssd){
    if(mouseX > posX+dimX-30 && mouseX < posX+dimX-10 && abs(mouseY-posY-scrollY) < 10 && this.pressed == false && prssd == true){
      this.pressed = true;
    }else if(prssd == false){
      this.pressed = false;
    }
  }
  
  public void setDimY(int y){
    int oldY = dimY;
    this.dimY = y;
    this.overhang = dimY-(slots.length*spacing);
    scrollY = round(map(scrollY,0,oldY,0,dimY));
    this.offset = round(map(scrollY,0,dimY,0,overhang));
  }
}
