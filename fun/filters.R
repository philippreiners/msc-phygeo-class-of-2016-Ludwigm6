## Filter function


# Funktion übergibt: Stack mit den Indizes, Zielverzeichnis, Präfix der erzeugten Datei
#                    zu berechnende Filter, Fenstergrößen
filter <- function(filepath, targetpath = dirname(filepath), prefix = "file_", window = c(21,29,33),
                   statistics = c("homogeneity", "contrast", "correlation", "mean")){
  
  library(glcm)
  library(raster)
  
  
  
  # read indice tif and rds file
  stack <- stack(filepath)
  indices <- readRDS(paste0(substr(filepath,1,nchar(filepath)-3),"rds"))
  
  # get number of layers from stack
  n_indices <- nlayers(r)
  
  
  # Erste apply-Schleife: durchschalten der Layer des Stacks --> also der Indices
  all_indices <- lapply(1:n_indices, function(i){
    # Ein Indizes laden
    r <- stack[[i]]
    # Zweite apply-Schleife: durchschalten der Statistics
    filter_different_windowsize <- lapply(statistics, function(s){
      # Dritte apply-Schleife: durchschalten der Fenstergrößen
      filter_same_windowsize <- lapply(window, function(w){
        
        glcm(r, statistics = s, window = c(w,w))
        
      })
      stack(filter_same_windowsize)
    })
    stack(filter_different_windowsize)
  })
  
  
  
  stacknames <- indices$Index
  for(j in 1:n_indices){
    
    writeRaster(all_indices[[j]], paste0(targetpath, stacknames[j],".tif"))
    writeRDS(data.frame(Layer = seq(1,n_indices), Filter = statistics), paste0(targetpath, stacknames[j],".rds")
              }
}