# TO READ IN FOX DENSITY MAPS, AVERAGE ACROSS ITERATIONS AND SMOOTH

library(raster)

setwd("C:/Users/hradskyb/Dropbox/personal/bron/ibm/foxnet_github")

# set your projection
my.projection <- "+proj=utm +zone=54 +south +ellps=GRS80 +units=m +no_defs"

# get names of map files

map.files <- list.files(path = paste0(getwd(), "/outputs/nedscrn/"), pattern="fox_density_custom_Y22_W1") # set path and pattern as appropriate

map.files.path <- paste0(getwd(), "/outputs/nedscrn/", map.files)

# read them in using a loop and create a raster stack

s <- raster::stack()

for (i in 1:length(map.files.path))
{
  r <- raster(map.files.path[i], crs = my.projection)
  NAvalue(r) <- 999
  s <- stack(s, r)
}

# plot the last raster see what it looks like

par(mfrow = c(1, 1)) 
plot(r)

# average across values for each cell
averaged <- mean(s)
plot(averaged)

writeRaster(averaged, "outputs/nedscrn/neds_y22_monthlybait_av_ns.asc", overwrite = TRUE)

# smooth across a moving window, of whatever size you feel is appropriate 
smoothed.map <- focal(averaged, w=matrix(1,nrow=29,ncol=29), mean, na.rm=TRUE, pad=FALSE, padValue=NA, NAonly=FALSE) 
# You may need na.rm = TRUE or na.rm = FALSE

plot(smoothed.map)

writeRaster(smoothed.map, "outputs/nedscrn/neds_y22_monthlybait_av_smoothed.asc", overwrite = TRUE)
