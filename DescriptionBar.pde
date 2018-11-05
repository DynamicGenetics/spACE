// Class for a description bar to display a description of the current data
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

class DescriptionBar{
  
  int posX;
  int posY;
  int dimX;
  int dimY;
  int currentColumn;
  PFont descriptionFont;
  String[] descriptionArray;
  String visibleTxt;
  
  // Constructor
  public DescriptionBar(int posX, int posY, int dimX, int dimY, int currentColumn, String[] descriptionArray){
    this.posX = posX;
    this.posY = posY;
    this.dimY = dimY;
    this.currentColumn = currentColumn;
    this.descriptionArray = descriptionArray;
    this.descriptionFont = createFont("Junction 02", 16);
    setDimX(dimX);
  }
  
  // Called in the animation loop
  public void drawDescriptionBar(){
    pushMatrix();
    translate(posX,posY);
    
    rectMode(CORNERS);
    fill(20,200);
    noStroke();
    rect(0,0,dimX,dimY);
    textAlign(LEFT,TOP);
    textFont(descriptionFont);
    fill(255);
    text(visibleTxt,8,6);
    
    popMatrix();
  }
 
  public void setXY(int x, int y){
    this.posX = x;
    this.posY = y;
  }
  
  public void setDimX(int x){
    this.dimX = x;
    this.visibleTxt = calcTxt();
  }
  
  public void changeColumn(int currentColumn){
    this.currentColumn = currentColumn;
    visibleTxt = calcTxt();
  }
  
  private String calcTxt(){
    String txt = this.descriptionArray[currentColumn];
    float txtWdth = txt.length();
    int prntDesc = 0;
    for(int i = 0; i < txtWdth; i++){
      if(textWidth(txt.substring(0,i)) >= dimX-40) break;
      prntDesc++;
    }
    String res = txt.substring(0,prntDesc);
    
    if(res.length() < txtWdth){
      res = res + " ...";
    }
    
    return(res);
  }
  
}