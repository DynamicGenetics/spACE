## demo.R

## Demonstration of the OpenMx model described in:
## Davis OSP, Haworth CMA, Lewis CM, & Plomin R (submitted for publication)
## Visual analysis of geocoded twin data puts nature and nurture on the map

## Copyright Oliver Davis 2012
## Distributed under the terms of the GNU General Public License version 3

## Using the OpenMx package
## If you don't have it installed already, uncomment and run this line to install:
# source('http://openmx.psyc.virginia.edu/getOpenMx.R')
library(OpenMx)

## Read in the data
data<-read.csv("demo.csv")

## Plotting locations (in this case a uniform grid)
plocs<-cbind(rep(1:50,50),rep(1:50,each=50))

## Function to find Euclidean distances from plotting locations
plotDis<-function(plotPoints,locations){
	res<-matrix(NA,dim(locations)[1],dim(plotPoints)[1])
	pb<-txtProgressBar(style=3)
	for(i in 1:dim(plotPoints)[1]){
		x1<-plotPoints[i,1]
		y1<-plotPoints[i,2]
		x2s<-locations[,1]
		y2s<-locations[,2]
		res[,i]<-sqrt((abs(x2s-x1)^2)+(abs(y2s-y1)^2))
		setTxtProgressBar(pb,i/dim(plotPoints)[1])
	}
	return(res)
}

## Calculate distances of datapoints from plotting locations
distance<-plotDis(plocs,data[,1:2])

## The weight matrix is inverse distance^0.5
weightMatrix <- (distance^0.5)
weightMatrix[weightMatrix==0] <- 1
weightMatrix <- 1/weightMatrix

## Separate monozygotic and dizygotic twins
mzwt<-weightMatrix[data$zygosity==1,]
dzwt<-weightMatrix[data$zygosity==2,]

selVars<-c("twin1","twin2")
mzData<-as.matrix(subset(data, zygosity==1, c("twin1","twin2")))
dzData<-as.matrix(subset(data, zygosity==2, c("twin1","twin2")))

## Estimate of "effective" sample size
## But we're really interested in point estimates
effss<-function(x){
	return(sum(x)^2/sum(x^2))
}

## Ready-made results matrix
results<-matrix(nrow=dim(plocs)[1],ncol=4)

## Open a progress bar
pb<-txtProgressBar(style=3)

## Begin the model-fitting loop, iterating over plotting locations (will take a few minutes)
## There may be optimisation warnings, but they should be GREEN (== probably OK)
for(i in 1:dim(plocs)[1]){
	
	## Means vectors
	mzMeans<-c(weighted.mean(mzData[,1],mzwt[,i]),weighted.mean(mzData[,2],mzwt[,i]))
	names(mzMeans)<-selVars
	dzMeans<-c(weighted.mean(dzData[,1],dzwt[,i]),weighted.mean(dzData[,2],dzwt[,i]))
	names(dzMeans)<-selVars
	
	## Fit ACE Model with covariance matrix data and matrix-style specification
	twinACEModel <- mxModel("twinACE",
		## additive genetic path
		mxMatrix(
		    type="Full",
		    nrow=1,
		    ncol=1,
		    free=TRUE,
		    values=.6,
		    label="a",
		    name="X"
		),
		## shared environmental path
		mxMatrix(
		    type="Full",
		    nrow=1,
		    ncol=1,
		    free=TRUE,
		    values=.6,
		    label="c",
		    name="Y"
		),
		## specific environmental path
		mxMatrix(
		    type="Full",
		    nrow=1,
		    ncol=1,
		    free=TRUE,
		    values=.6,
		    label="e",
		    name="Z"
		),
		## additive genetic variance
		mxAlgebra(
		    expression=X * t(X),
		    name="A"
		),
		## shared environmental variance
		mxAlgebra(
		    expression=Y * t(Y),
		    name="C"
		),
		## specific environmental variance
		mxAlgebra(
		    expression=Z * t(Z),
		    name="E"
		),
		## means
		mxMatrix(
		    type="Full",
		    nrow=1,
		    ncol=2,
		    free=T,
		    values=20,
		    labels="mean",
		    name="expMean"
		),
		mxAlgebra(
		    expression=rbind (cbind(A+C+E, A+C),
		                      cbind(A+C  , A+C+E)),
		    name="expCovMZ"
		),
		mxAlgebra(
		    expression=rbind (cbind(A+C+E  , 0.5 %x% A+C),
		                      cbind(0.5 %x% A+C, A+C+E)),
		    name="expCovDZ"
		),
		mxModel("MZ",
		    mxData(
		        observed=cov.wt(mzData,mzwt[,i])[[1]],
		        type="cov",
				numObs=dim(mzData)[1],
				## numObs=effss(mzwt[,i]),
				means=mzMeans
		    ),
		    mxMLObjective(
		        covariance="twinACE.expCovMZ",
		        means="twinACE.expMean",
		        dimnames=selVars
		    )
		),
		mxModel("DZ",
		    mxData(
		        observed=cov.wt(dzData,dzwt[,i])[[1]],
		        type="cov",
				numObs=dim(dzData)[1],
				## numObs=effss(dzwt[,i]),
				means=dzMeans
		    ),
		    mxMLObjective(
		        covariance="twinACE.expCovDZ",
		        means="twinACE.expMean",
		        dimnames=selVars
		    )
		),
	    mxAlgebra(
	        expression=MZ.objective + DZ.objective,
	        name="twin"
	    ),
	    mxAlgebraObjective("twin")
	)
	
	## Run ACE model
	twinACEFit <- mxRun(twinACEModel,silent=TRUE)
	
	A <- mxEval(A, twinACEFit)
	C <- mxEval(C, twinACEFit)
	E <- mxEval(E, twinACEFit)
	V <- A + C + E
	
	results[i,]<-c(A,C,E,V)
	
	setTxtProgressBar(pb,i/dim(plocs)[1])
	
} ## End iteration loop

mapMatrix<-cbind(plocs, results)
colnames(mapMatrix)<-c("east","north","A","C","E","V")

## The colour scale from the map
mapColours<-c("#20D2FF","#23BCEE","#26A7DD","#2A92CC","#2D7DBB","#3168AA","#345399",
"#383E88","#3B2977","#3F1466","#541561","#69165D","#7E1859","#941955","#A91A50","#BE1C4C",
"#D41D48","#E91E44","#FF2040")

## Function to work out which colour each point should be
calcColourIndex<-function(data,bins=numeric(19)){
  kolours <- numeric(length(data))
  bins <- bins
  dmin <- min(data)
  dmax <- max(data)
  ivl <- (dmax-dmin)/19
  louuer <- dmin-1
  if(bins[19]==0){
  	for(i in 1:length(bins)){
      bins[i] <- dmin+(ivl*(i))
    }
  }
  for(i in 1:length(bins)){
    for(row in 1:length(kolours)){
      x = data[row];
      if((x > louuer) && (x <= bins[i])){
      	kolours[row] <- i
      }
    }
    louuer <- bins[i]
  }
  return(list(min=dmin,max=dmax,interval=ivl,bin=bins,index=kolours,data=data))
}

## Function to scale one gradient to another
rescale<-function(from,to){
	fromRange<-from$max-from$min
	toRange<-to$max-to$min
	if(fromRange>toRange) warning("the range you're converting to is narrower than the original. Returning original range.")
	fromMid<-((from$max-from$min)/2)+from$min
	toMid<-((to$max-to$min)/2)+to$min
	toDiff<-fromMid-toMid
	kolours <- numeric(length(from$data))
	bins<-to$bin+toDiff
	ivl<-to$interval
	dmin<-to$min+toDiff
	dmax<-to$max+toDiff
	louuer <- dmin-1
    for(i in 1:length(bins)){
      for(row in 1:length(kolours)){
        x = from$data[row];
        if((x > louuer) && (x <= bins[i])){
        	kolours[row] <- i
        }
      }
    louuer <- bins[i]
    }
    if(fromRange>toRange) {
    	return(from)
    }else{
	    return(list(min=dmin,max=dmax,interval=ivl,bin=bins,index=kolours,data=from$data))
	}
}

## Plot the A, C and E maps side by side
x11(width=13.5,height=4.5)

old<-par(bg="#272727",col.axis="white",col.lab="white",col="white",mfrow=c(1,3))

## A
plot(plocs,col= mapColours[calcColourIndex(results[,1])$index],las=1,pch=19,bty="l",xaxt="n",yaxt="n",xlab="east",ylab="north")
axis(1,col="white",col.ticks="white",las=1)
axis(2,col="white",col.ticks="white",las=1)
text(25,25,"A",cex=1.5)

## C
plot(plocs,col= mapColours[rescale(calcColourIndex(results[,2]),calcColourIndex(results[,1]))$index],las=1,pch=19,bty="l",xaxt="n",yaxt="n",xlab="east",ylab="north")
axis(1,col="white",col.ticks="white",las=1)
axis(2,col="white",col.ticks="white",las=1)
text(25,25,"C",cex=1.5)

## E
plot(plocs,col= mapColours[rescale(calcColourIndex(results[,3]),calcColourIndex(results[,1]))$index],las=1,pch=19,bty="l",xaxt="n",yaxt="n",xlab="east",ylab="north")
axis(1,col="white",col.ticks="white",las=1,main="E")
axis(2,col="white",col.ticks="white",las=1)
text(25,25,"E",cex=1.5)

par(old)



