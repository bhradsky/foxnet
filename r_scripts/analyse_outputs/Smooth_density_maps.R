# TO READ IN FOX DENSITY MAPS, AVERAGE ACROSS ITERATIONS AND SMOOTH

library(raster)

setwd("C:/Users/hradskyb/FoxControlPatrol/Dropbox/personal/bron/ibm/foxnet_github")

# set your projection
my.projection <- "+proj=utm +zone=54 +south +ellps=GRS80 +units=m +no_defs"

# get names of map files

map.files <- list.files(path = paste0(getwd(), "/outputs/test"), pattern="fox_density_custom_") # set path and pattern as appropriate

map.files.path <- paste0(getwd(), "/outputs/test/", map.files)

# read them in and create a raster stack

s <- raster::stack()
for (i in 1:length(map.files.path))
{
  r <- raster(map.files.path[i], crs = my.projection)
  NAvalue(r) <- 999
  s <- stack(s, r)
}

# plot the last raster just to check

par(mfrow = c(1, 1)) 
plot(r)

# average across values for each cell
averaged <- mean(s)
plot(averaged)

# smooth across a moving window of 5 x 5 cells


smoothed.map <- focal(averaged, w=matrix(1,nrow=5,ncol=5), mean, na.rm=FALSE, pad=FALSE, padValue=NA, NAonly=FALSE) 
# You may need na.rm = TRUE or na.rm = FALSE

plot(smoothed.map)

writeRaster(smoothed.map, "outputs/test/smoothed_map.asc", overwrite = TRUE)
