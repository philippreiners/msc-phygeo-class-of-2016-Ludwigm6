# fun SAGA Overland Flow Kinematic D8

hy_overland_flow <- function(DEM_path,
                             gauges_path,
                             workdir,
                             time = "24",
                             steps = "0.1",
                             roughness = "0.03",
                             maxiter = "100",
                             epsilon = "0.0001",
                             precip = "0",
                             threshold = "0.0000"){
  library(raster)
  library(gdalUtils)
  
  if(!file.exists(file.path(workdir))){
    dir.create(file.path(workdir), recursive = TRUE)
  }
  setwd(workdir)
    
  system(paste0("saga_cmd sim_hydrology 1 ",
                "-DEM=", DEM_path," ",
                "-FLOW=overland_flow.sdat ",
                "-GAUGES=", gauges_path, " ",
                "-GAUGES_FLOW=gauges_flow.csv ",
                "-TIME_SPAN=", time," ",
                "-TIME_STEP=", steps, " ",
                "-ROUGHNESS=", roughness," ",
                "-NEWTON_MAXITER=", maxiter," ",
                "-NEWTON_EPSILON=",epsilon ," ",
                "-PRECIP=",precip ," ",
                "-THRESHOLD=",threshold))

  gdalwarp(srcfile = paste0(workdir, "overland_flow.sdat"),
           dstfile = paste0(workdir, "overland_flow.tif"),
           overwrite = TRUE,
           of = "GTiff")
  
  res <- list(overland_flow = raster(paste0(workdir, "overland_flow.tif")),
              gauges_flow = read.csv(paste0(workdir, "gauges_flow.csv")))
  saveRDS(res, file = paste0(workdir, "overland_flow.rds"))
  return(res)
  
}