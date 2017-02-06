# gi-ws-10-1 forest metrics part 2

# DBH estimates:
# https://www.srs.fs.usda.gov/pubs/ja/uncaptured/ja_gering002.pdf

source("d:/university/msc-phygeo-class-of-2016-Ludwigm6/fun/init.R")
path <-  fun_init("gi", "10")

library(link2GI)
library(raster)
library(rgrass7)
library(gdalUtils)
library(rgdal)
library(rgeos)

trees <- readOGR(paste0(path$gi$output, "trees_final.shp"))

# DBH:
# linear regression between crown diameter and DBH
# dont forget to convert units
# dbh [inch] = a + b * diameter_crown [feet]
trees@data$dbh <- (2.082 + 0.4636*(trees@data$diameter*3.28084))*0.0254

# Reinekes stand density index:
# sdi = N [trees / ha] * (mean dbh²/ 25)^1.605
# circle with 1ha area has a radius of 56.4m

# N: how many trees in a hektar
trees_buffer <-  gBuffer(spgeom = trees, byid = TRUE, width = 56.4)
contain <- gContains(spgeom1 = trees_buffer, spgeom2 = trees, byid = TRUE, returnDense = FALSE)
N <- unlist(lapply(contain, length))
# mean dbh:
mean_dbh <- lapply(contain, function(x){
  return(mean(!is.na(trees@data$dbh[x])))
})
mean_dbh <- unlist(mean_dbh)
# sdi
trees@data$sdi <- N*(mean_dbh/25)^1.605
trees@data$sdi[is.na(trees@data$dbh)] <- NA

# save results
writeOGR(trees, dsn = paste0(path$gi$output, "trees_final.shp"), driver = "ESRI Shapefile", layer = "trees")


