#CREATE BAITING GRIDS AROUND AREA-OF-INTEREST for IBM
# Bronwyn Hradsky 2017

rm(list=ls())

library(rgdal)
library(raster)
library(rgeos)
library(dismo)

setwd("C:/Users/hradskyb/Dropbox/FIPTH/Predator_IBM/GIS_layers/Glenelg/MtClay")

mtclay <- readOGR(getwd(), "MtClay_union_60mtol_dissolve_WGS84")
land <- readOGR(getwd(), "MtClay_40km_landonly")
plot(land)
plot(mtclay, add = TRUE)
projection(mtclay)

# FOR BAITS AT DIFFERENT DENSITIES

#set number of baits per km2

baits.km2 <- c(0.2, 0.5, 1, 2, 4, 6, 8, 10)

for (b in baits.km2)
{
  #calculate distance between baits in m
  distancebetweenbaits.m <- ( 1 / sqrt(b)) * 1000
  
  #generate grid points
  mtclay.gridpts <- spsample(mtclay, type = "regular", cellsize = distancebetweenbaits.m, offset =c(0.5,0.5), nsig = 2, pretty = TRUE)
  #head(coordinates(mtclay.gridpts))
  #projection(mtclay.gridpts)
  
  #convert into spatial points data frame
  mtclay.gridpts.spdf <- SpatialPointsDataFrame(mtclay.gridpts, data.frame(ptno = seq(1,length(mtclay.gridpts), 1))  )
  

  
  #export as shapefile
  writeOGR(mtclay.gridpts.spdf , dsn=getwd(), layer=paste0("baiting_scenarios/mtclay_", b, "bait_km"), driver="ESRI Shapefile", overwrite_layer=T)
}

# FOR BAITS AT DIFFERENT BUFFER DISTANCES

#make biggest layer
biggestbuffer <- 10000

mtclay.buffer <-gBuffer(mtclay, width = biggestbuffer, byid = F)
mtclay.bufferpts <- spsample(mtclay.buffer, type = "regular", cellsize = 1000, offset =c(0.5,0.5), nsig = 2, pretty = TRUE)
 
# clip to exclude ocean
mtclay.bufferpts.clip <- gIntersection(mtclay.bufferpts, land, byid = TRUE, drop_lower_td = TRUE)
#plot(mtclay.bufferpts.clip, add = TRUE, col = "red")

# make polygons for smaller layers and clip out points
bufferwidth <- c(500, 1000, 2000, 4000, 6000, 8000, 10000)

for (w in bufferwidth)
{
  mtclay.buffer <-gBuffer(mtclay, width = w, byid = F)
  buffered.points <- gIntersection(mtclay.bufferpts.clip, mtclay.buffer, byid = TRUE, drop_lower_td = TRUE)
  mtclay.bufferpts.clip.spdf <- SpatialPointsDataFrame(buffered.points, data.frame(ptno = seq(1,length(buffered.points), 1))  )
  writeOGR(mtclay.bufferpts.clip.spdf, dsn=getwd(), layer=paste0("baiting_scenarios/mtclay_buffer_", w), driver="ESRI Shapefile", overwrite_layer=T)
}

