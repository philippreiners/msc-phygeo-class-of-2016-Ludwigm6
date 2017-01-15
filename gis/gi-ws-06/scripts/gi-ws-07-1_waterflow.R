# gi-ws-07-1 waterflow#
# # # # # # # # # # # #

# initialize script
source("d:/university/msc-phygeo-class-of-2016-Ludwigm6/fun/init.R")
path <- fun_init("gi", "07")

library(raster)
library(rgdal)
library(gdalUtils)
source(path$fun$fun_hy_analysis.R)
source(path$fun$overland_flow.R)

# # # # # # # # #

# new folders for the basic analysis and the flow simulation
path$hydro <- paste0(path$gi$run, "hydrology/")
path$two <- paste0(path$gi$run, "two_cells/")
path$sim <- paste0(path$gi$run, "overland_flow/")

#dir.create(path$hydro)
#dir.create(path$two)
#dir.create(path$sim)

# load DEM and get the filepath
DEM <- raster::raster(paste0(path$gi$input, "geonode_las_dtm_01m.tif"))
path$DEM <- DEM@file@name

# preprocess DEM: fill sinks (Wang & Liu)
hy_pre <- hy_basic_analysis(DEM_path = path$DEM, workdir = path$hydro)
print(summary(hy_pre))

# # # # # # # # # # # # # # # # # # # # 

# # # # Calculate catchment area for a given point (gauge = Pegel) # # # #
# # Correct position for gauge to biggest drainage (=Abfluss) in a buffered area # #

# create spatial point at estimate gauge
gauge <- data.frame(y = 50.840860, x = 8.684456, name = "gauge")
coordinates(gauge) <- ~ x + y

# WGS84_longlat because of the coordinate format; then transform to format of DEM
projection(gauge) <- CRS("+init=epsg:4326")
gauge <- spTransform(gauge, CRS("+init=epsg:25832"))

# extract values from the catchment_area raster around the estimate gauge
gauge_buffer <- as.data.frame(extract(hy_pre$catchment_area, gauge, buffer = 25, cellnumbers = TRUE)[[1]])

# position with biggest value is the new position of the gauge
gauge@coords <- xyFromCell(DEM, gauge_buffer$cell[which.max(gauge_buffer$value)])
# save as shapefile for input of the simulation
writeOGR(gauge, dsn = paste0(path$sim, "gauge.shp"), driver = "ESRI Shapefile", layer = "gauge", overwrite_layer = TRUE)


# # # # # # # # # # # # # # #

# # # # crop DEM to catchment area of corrected gauge # # # #
# Saga Upslope Area
upslope_output <- paste0(path$sim, "catchment_gauge.sdat")
system(paste0("saga_cmd ta_hydrology 4 ",
              " -TARGET_PT_X ", gauge@coords[1,1],
              " -TARGET_PT_Y ", gauge@coords[1,2],
              " -ELEVATION DEM_no_sinks.sdat",
              " -AREA ", upslope_output,
              " -METHOD 0", 
              " -CONVERGE=1.100000"))

# convert to tif
gdalwarp(srcfile = paste0(path$sim, "catchment_gauge.sdat"),
        dstfile = paste0(path$sim, "catchment_gauge.tif"),
        overwrite = TRUE,
        of = "GTiff")

# load catchment of the gauge tif
catchment_gauge <- raster(paste0(path$sim, "catchment_gauge.tif"))

# get nothing but the catchment area
catchment_gauge[catchment_gauge < 100] <- NA
catchment_gauge <- trim(catchment_gauge)
# crop the DEM
DEM_gauge <- crop(hy_pre$DEM_no_sinks, catchment_gauge)

# save croped DEM as sgrd and tif
writeRaster(DEM_gauge, filename = paste0(path$sim, "DEM_gauge.tif"), overwrite = TRUE)
writeRaster(DEM_gauge, filename = paste0(path$sim, "DEM_gauge.sdat"), overwrite = TRUE)

# # # # # # # # # # # # # # # # # # # # #

# # # # Create raster with two cells to get the percipitation values of the used module # # # #
# create raster with two cells
two <- raster(nrows = 1, ncols = 2, xmn = 0, xmx = 2, ymn=0, ymx = 1)
values(two) <- c(2000, 1)

# create gauges at both cells to observate the simulation
two_gauges <- as.data.frame(rasterToPoints(two))
coordinates(two_gauges) <- ~ x + y

# save both
writeRaster(two, filename = paste0(path$two, "two_cell.sdat"), overwrite  = TRUE)
writeOGR(two_gauges, dsn = paste0(path$two, "two_gauge.shp"), driver = "ESRI Shapefile", layer = "gauge", overwrite_layer = TRUE)


# # # # # # # # # # # # # # # # # #
# finally all input data is ready #
# # # # # # # # # # # # # # # # # #

# # # # run precipitation simulation # # # #

# two cells to test precipitation
sim_two_cells <- hy_overland_flow(DEM_path = paste0(path$two, "two_cell.sgrd"),
                                  gauges_path = paste0(path$two, "two_gauge.shp"),
                                  workdir = path$two,
                                  time = "1",
                                  steps = "1",
                                  roughness = "0")

# simulation with catchment area for three different time steps
timesteps <- c("0.1", "0.5", "1")

sim_catchment <- lapply(timesteps, function(x){
  output_dir <- paste0(path$sim, x, "/")
  
  hy_overland_flow(DEM_path = paste0(path$sim, "DEM_gauge.sgrd"),
                   gauges_path = paste0(path$sim, "gauge.shp"),
                   workdir = output_dir,
                   time = "24",
                   steps = x)
  
})
names(sim_catchment) <- timesteps

# save results
saveRDS(sim_two_cells, file = paste0(path$gi$run, "sim_two_cells.rds"))
saveRDS(sim_catchment, file = paste0(path$gi$run, "sim_catchment.rds"))



