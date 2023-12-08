# CREATE AN ASCII INPUT FOR FOXNET FROM A SHAPEFILE
# Bronwyn Hradsky, University of Melbourne

library(dplyr)
library(stars)
library(terra)
library(sf)

# set your details here
input.shapefile.path <- "dudley_peninsula/cleaned/dudley_outline.shp"
resolution <- 100
output.asc.path <- "dudley_peninsula/cleaned/dudley_100.asc"

# then just run the rest of the code

# read in the shapefile
landscape <- st_read(input.shapefile.path)

#plot(st_geometry(landscape))

# make a rectangular polygon with the same extent as the shapefile
box <- st_as_sf(st_as_sfc(st_bbox(landscape)))
box.bigger <- st_buffer(box, dist = 200) # increase the size a little so that you don't get edge bleed problems

# create polygon with features of both
# make function equivalent to ArcGIS 'Identity' - from https://stackoverflow.com/questions/68824805/r-sf-equivalent-of-esri-identity
arc.ident <- function(layer_a, layer_b){
  int_a_b <- st_intersection(layer_a, layer_b)
  rest_of_a <- st_difference(layer_a, st_union(layer_b))
  output <- bind_rows(int_a_b, rest_of_a)
  return(st_as_sf(output))
}
land.merge <- arc.ident(box.bigger, landscape)

# update attributes so that different habitat types have unique values
land.merge$ha <- c(1, 0)

# convert to raster
land.merge.raster <- st_rasterize(land.merge)

# cooerce stars object into a raster layer so that you can write the ascii
# this function will be retired soon, not sure what the best work-around is.
land.raster = as(land.merge.raster, "Raster")

# make a template raster with a extent rounded to appropriate integer and correct resolution

temp <- rast(xmin=floor(xmin(land.raster)), xmax=ceiling(xmax(land.raster)), ymin=floor(ymin(land.raster)), ymax=ceiling(ymax(land.raster)), res=resolution, crs = st_crs(land.raster)$proj4string)

temp.r = as(temp, "Raster")

# resample the land raster so that its resolution matches the template
land.raster.res <- resample(land.raster, temp.r, method = "ngb") 
land.raster.res[is.na(land.raster.res[])] <- 0 

#plot(land.raster.res)

# save as ascii
writeRaster(land.raster.res, output.asc.path, filetype = "AAIGrid", overwrite = TRUE)

