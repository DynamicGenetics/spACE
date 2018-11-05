// Class to draw a histogram of the data values in the colours of the data points
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

class BarChart {
  
  int posX;
  int posY;
  int dimX;
  int dimY;
  FloatTable data;
  int[] colours;
  float[] bins = new float[19];
  int[] counts = new int[19];
  float barwidth;
  PFont graphFont;
  int currentColumn;
  int markedBar;
  
  // Constructor
  public BarChart(int posX, int posY, int dimX, int dimY, FloatTable data, int[] colours, int currentColumn){
    this.posX = posX;
    this.posY = posY;
    this.dimX = dimX;
    this.dimY = dimY;
    this.data =data;
    this.colours = colours;

    this.counts = updateCounts(data,currentColumn);

    this.barwidth = (dimX - 40)/19;
    this.graphFont = createFont("Junction 02", 10);
    this.currentColumn = currentColumn;
    this.markedBar = -9;
    
  }
  
  // Called each time through the animation loop
  public void drawBarChart(){
    pushMatrix();
    translate(posX,posY);
    
    for(int bar = 0; bar < counts.length; bar++){
      float x = map(bar+1,1,19,40,dimX-20);
      float y = map(counts[bar],0,max(counts),dimY-30,30);
      rectMode(CORNERS);
      noStroke();
      fill(color(colours[bar]));
      rect(x-barwidth/2,y,x+barwidth/2,dimY-30);
      if(bar == markedBar){
        fill(255);
        triangle(x,y-barwidth/2,x-barwidth/4,y-barwidth,x+barwidth/4,y-barwidth);
      }
    }
    stroke(255);
    line(40-barwidth/2,dimY-30,40-barwidth/2,30);
    
    fill(255);
    textFont(graphFont);
    
    int freqInterval = 250;
    textAlign(RIGHT,BOTTOM);
    for(int fi = 0; fi < max(counts); fi += freqInterval){
      float labPos = map(fi, 0, max(counts), dimY-30,30);
      text(fi,30-barwidth/2,labPos);
      line(35-barwidth/2,labPos,40-barwidth/2,labPos);
    }
    
    textAlign(CENTER,TOP);
    float dmin = data.getColumnMin(currentColumn);
    float dmax = data.getColumnMax(currentColumn);
    
    // Hack to work out reasonably sensible places to put the ticks
    float range = dmax-dmin;
    float mod;
    int leftNum = 1;
    int rightNum;
    if(range < 0.1){
      mod = 0.01;
      rightNum = 2;
    }else if(range < 0.5){
      mod = 0.05;
      rightNum = 2;
    } else if(range < 1.0){
      mod = 0.1;
      rightNum = 1;
    } else if(range < 5.0){
      mod = 0.5;
      rightNum = 1;
    } else if(range < 10.0){
      mod = 1.0;
      rightNum = 0;
    } else if(range < 50.0){
      mod = 5.0;
      rightNum = 0;
    } else {
      mod = 10.0;
      rightNum = 0;
    }
    
    float start = dmin - (dmin % mod) + mod;
      
    for(float vi = start; vi <= dmax; vi += mod){
      float labPos = map(vi, dmin, dmax, 40,dimX-20);
      if(vi >= 10) leftNum = 2;
      text(nf(vi,leftNum,rightNum),labPos,dimY-20);
      line(labPos,dimY-30,labPos,dimY-25);
    }
    
    
    popMatrix();
  }
  
  // Called to change to another variable from the dataset
  public void changeColumn(int newColumn){
    this.currentColumn = newColumn;
    counts = updateCounts(data,currentColumn);
    markedBar = -9;
  }
  
  // Updates the frequency displayed in each bar of the histogram
  private int[] updateCounts(FloatTable data, int currentColumn){
    int[] counts = new int[19];
    for(int i = 0; i < counts.length; i++){
      counts[i] = 0;
    }
    float[] bins = new float[19];
    float dmin = data.getColumnMin(currentColumn);
    float dmax = data.getColumnMax(currentColumn);
    float ivl = (dmax-dmin)/19;
    float lower = dmin-1;

    for(int i = 0; i < bins.length; i++){
      bins[i] = dmin+(ivl*(i+1));
    }

    for(int i = 0; i < counts.length; i++){
      for(int row = 0; row < data.getRowCount(); row++){
        float x = data.getFloat(row,currentColumn);
        if((x > lower) && (x <= bins[i])) counts[i]++;
      }
    lower = bins[i];
    }
    return(counts);
  }
  
  // Called to mark a histogram bar with a tiny triangle
  public void markBar(int value){
    this.markedBar = value;
  }
  
  public void unmarkBar(){
    this.markedBar = -9;
  }
  
  public void setXY(int x, int y){
    this.posX = x;
    this.posY = y;
  }
}