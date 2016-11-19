## Initialise any R Script


initialize <- function(filepath_base){
  
  # change backslashes with regular expression
  filepath_base <- gsub("\\\\", "/", path.expand(filepath_base))
  
  # set filepaths
  path_data <- paste0(filepath_base, "data/")
  path_aerial <- paste0(path_data, "aerial/")
  path_aerial_merged <- paste0(path_data, "aerial_merged/")
  path_aerial_croped <- paste0(path_data, "aerial_croped/")
  path_raster <- paste0(path_data, "raster/")
  path_rdata <- paste0(path_data, "rdata/")
  path_functions <- "D:/Uni/r_functions"
  path_scripts <- paste0(filepath_base, "scripts/")
  path_temp <- paste0(filepath_base, "temp/")
  
  
  # create directories if needed
  folders <- list("data" = path_data,
                  "aerial" = path_aerial,
                  "aerial_merged" = path_aerial_merged,
                  "aerial_croped" = path_aerial_croped,
                  "rdata" = path_rdata,
                  "raster" = path_raster,
                  "scripts" = path_scripts,
                  "temp" = path_temp)
  
  
  for(folder in folders){
    if (!file.exists(file.path(folder))) {
      dir.create(file.path(folder), recursive = TRUE)
    }
  }
  
  # set rasteroptions to working directory
  raster::rasterOptions(tmpdir = path.expand(path_temp))
  
  # setting R environ temp folder to the current working directory
  Sys.setenv(TMPDIR = file.path(path_temp))
  
  # initialise SAGA 3.0.0 shell
  saga_path <- "C:\\Program Files\\SAGA-GIS"
  Sys.setenv(PATH=paste0(saga_path,";",Sys.getenv("PATH")))
  
  # set directory
  setwd(filepath_base)
  
  # return the list of paths
  return(folders)
  
  
  
}