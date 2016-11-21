# gi-ws-04-1 plain plateau reloaded
#
# using system() to operate the SAGA Shell


# initialise the script and save all filepaths in a list
source("D:/university/msc-phygeo-class-of-2016-Ludwigm6/fun/Init.R")
path <- Init("gi", "04")


# execute SAGA modul 'Slope, Aspect, Curvature'
# set path to the input data caldern_DEM.sdat
setwd(path$rs$saga)

# execute modul with unit_slope = 0 (radian)
# don't forget Space after each text fragment to separate arguments
system(paste0("saga_cmd ta_morphometry 0 ",
              "-ELEVATION=caldern_DEM.sdat ",
              "-SLOPE=slope ",
              "-ASPECT=aspect ",
              "-C_PROF=profil ",
              "-C_TANG=tangential ",
              "-C_MINI=minimum ",
              "-C_MAXI=maximum ",
              "-METHOD=6 -UNIT_SLOPE=0 -UNIT_ASPECT=0"))


# execute SAGA modul 'Fuzzy Landform Element Classification'
# SLOPETODEG=1 because slope unit is radian
parameter_default <- "-T_SLOPE_MIN=5.000000 -T_SLOPE_MAX=15.000000 -T_CURVE_MIN=0.000002 -T_CURVE_MAX=0.000050"

# getting good results with these parameters:
parameter <- "-T_SLOPE_MIN=5.000000 -T_SLOPE_MAX=15.000000 -T_CURVE_MIN=0.0007 -T_CURVE_MAX=0.15"


system(paste0("saga_cmd ta_morphometry 25 ",
              "-SLOPE=slope.sdat ",
              "-MINCURV=minimum.sdat ",
              "-MAXCURV=maximum.sdat ",
              "-PCURV=profil.sdat ",
              "-TCURV=tangential.sdat ",
              "-PLAIN=class_plain ",
              "-FORM=class_landform ",
              "-MEM=class_membership ",
              "-ENTROPY=class_entropy ",
              "-CI=class_confusion ",
              "-SLOPETODEG=1 ",
              parameter))

# convert output to .tif
system("saga_cmd io_gdal 2 -GRIDS=class_plain.sdat -FILE=class_plain.tif")
system("saga_cmd io_gdal 2 -GRIDS=class_landform.sdat -FILE=class_landform.tif")


########## End of command line part ############

library(raster)
library(glcm)

# initialise the script and save all filepaths in a list
source("D:/university/msc-phygeo-class-of-2016-Ludwigm6/fun/Init.R")
path <- Init("gi", "04")

# show results
plains <- raster(paste0(path$rs$saga, "class_plain.tif"))
plot(plains)


# glcm mean to get rid of some artefacts
plains_mean <- glcm(plains, statistics = c("mean"), window = c(11,11))
plot(plains_mean)

# reclassify all values from 0.7 to 1 as 1
plains_reclass <- reclassify(plains_mean, matrix(c(0.7,1,1)))
plot(plains_reclass)

# reclassify as plain or plateau using the DEM
plains_reclass_backup <- plains_reclass
DEM <- raster(paste0(path$rs$aerial, "caldern_DEM.tif"))

# Bei Höhen größer 250m Plateau; darunter Plain
plains_reclass[plains_reclass_backup == 1 & DEM < 250] <- 1
plains_reclass[plains_reclass_backup == 1 & DEM >= 250] <- 2

# Gelb: Plateau, Grün: Plain
plot(plains_reclass)