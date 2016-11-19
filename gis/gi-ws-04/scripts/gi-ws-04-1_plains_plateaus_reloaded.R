# gi_ws_04_1 plain plateau reloaded
#
# using system() to operate the SAGA Shell

# define project folder
filepath_base <- "D:/Uni/forest_caldern/"

# initialise the script and save all filepaths in a list
source("D:/Uni/r_functions/Init.R")
path <- Init(filepath_base)

# add saga path to list
path$saga <- paste0(path$data, "saga/")

# execute SAGA modul 'Slope, Aspect, Curvature'
# set path to the input data caldern_DEM.sdat
setwd(path$saga)

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
parameter <- "-T_SLOPE_MIN=5.000000 -T_SLOPE_MAX=15.000000 -T_CURVE_MIN=0.07 -T_CURVE_MAX=3"


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






