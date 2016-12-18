# fun hydro preprocessing

hy_basic_analysis <- function(DEM_path, workdir, sink_min_slope = "0.1"){
  
  library(gdalUtils)
  library(rgdal)
  library(raster)

  
  # Create output- and workfolder
  if(!file.exists(file.path(workdir))){
    dir.create(file.path(workdir), recursive = TRUE)
  }
  setwd(workdir)
  
  # if the function already were executet, just read the output RDS
  if(file.exists(paste0(workdir, "hy_results.rds"))){
    
    res <- readRDS(paste0(workdir, "hy_results.rds"))
    return(res)
    
  # if there is no hy_results.rds in the work directory, execute SAGA Moduls  
  }else{
    
    # 1. convert tif to SAGA Format
    gdalwarp(srcfile = DEM_path, dstfile = paste0(workdir, "DEM.sdat"), overwrite = TRUE, of = 'SAGA')
    
    # 2. Preprocessing the DEM: Fill Sinks (Wang & Liu)
    system(paste0("saga_cmd ta_preprocessor 4 ",
                  "-ELEV=DEM.sdat ",
                  "-FILLED=DEM_no_sinks.sdat ",
                  "-FDIR=flow_direction.sdat ",
                  "-WSHED=watershed.sdat ",
                  "-MINSLOPE=",sink_min_slope))
    
    
    # 3. Catchment areas
    system(paste0("saga_cmd garden_learn_to_program 7 ",
                  " -ELEVATION=DEM_no_sinks.sdat ",
                  " -AREA=catchment_area.sdat ",
                  " -METHOD=0"))
    
    
    # Last: convert output to tif
    # task: files besser in liste ordnen; liste benennen
    output <- list.files(workdir, pattern = "*.sgrd", full.names = TRUE)
    
    ret <- lapply(seq(length(output)),function(i){
      
      gdalwarp(srcfile = sub(".sgrd",".sdat",output[i]),
               dstfile = sub(".sgrd",".tif",output[i]),
               overwrite = TRUE, of = 'GTiff')
      
      raster(sub(".sgrd",".tif",output[i]))
      
    })
    names(ret) <- substr(list.files(workdir, pattern = "*.tif"), start = 1, stop = nchar(list.files(workdir, pattern = "*.tif"))-4)
    saveRDS(ret, file = paste0(workdir, "hy_results.rds"))
    return(ret)
    
  }
}  