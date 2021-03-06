library(raster)
library(tools)


#Datenpfade definieren
filepath_base <- "D:/Uni/remote_sensing/"
path_temp <- paste0(filepath_base, "temp/")
path_data <- paste0(filepath_base, "data/forest_caldern_tif/raster/")
path_target <- paste0(filepath_base, "data/forest_caldern_tif/rdata/")
path_scripts <- paste0(filepath_base, "scripts/")
rasterOptions(tmpdir = path_temp)

source(paste0(path_scripts, "fun_ngb_aerials.R")) # Load functions from scripts

#Gibt benachbarte Dateinamen aus: Nord, Ost, S�d, West
#Einlesereihenfolge: Oben-links, Unten-links, Oben-mitte, Unten-mitte, Oben-rechts, Unten-rechts
files <- c("474000_5632000.tif", "474000_5630000.tif", "476000_5632000.tif",
           "476000_5630000.tif", "478000_5632000.tif", "478000_5630000.tif")
neighbors <- ngb_aerials(files, step = 2000)



#########################################################

result <- numeric()
res1 <- list()
res2 <- list()
res3 <- list()
res4 <- list()
res5 <- list()
res6 <- list()
res_list <- list(res1, res2, res3, res4, res5, res6)

i <- 1
j <- 2


#Alle 6 Raster durchz�hlen
for(i in 1:6){
  #Erster Raster Einlesen
  center <- stack(paste0(path_data, files[i]))
  #Grenzen berechnen
  c_top <- center[1,]
  c_right <- center[,ncol(center)]
  c_down <- center[nrow(center),]
  c_left <- center[,1]
  c_border <- list(c_top, c_right, c_down, c_left)
  
  
  #Alle vier Seiten durchtesten
  for(j in 1:4){
    #Nachbarraster einlesen
    #Pr�fen ob im aktuellen Schleifendurchgang ein Nachbarraster vorhanden ist
    if(!is.na(neighbors[[i]][j])){
      
    neighbor <- stack(paste0(path_data, neighbors[[i]][j]))
    #Nachbargrenzen berechnen
    n_down <- neighbor[nrow(neighbor),]
    n_left <- neighbor[,1]
    n_top <- neighbor[1,]
    n_right <- neighbor[,ncol(neighbor)]
    n_border <- list(n_down, n_left, n_top, n_right)
    
      #richtige Linie Extrahieren
      c_line <- c_border[[j]]
      n_line <- n_border[[j]]
      
      #Histogram ertellen und counts Vergleichen: Je mehr Nullen oder kleine Werte im Ergebnis desto �hnlicher die beiden Raster
      #ERSTEZEN DURCH VARIANZANALYSE?
      c_hist <- hist(c_line, breaks = seq(0,255,5))
      n_hist <- hist(n_line, breaks = seq(0,255,5))
      result <- c_hist$counts - n_hist$counts
      
      #Ergebnisse speichern
      res_list[[i]][[j]] <- result
    }else{
      res_list[[i]][[j]] <- NA
    }
  }
}
########################################################################

saveRDS(res_list, file = paste0(path_target, "rs-ws-03-2_results.rds"))

ergebnis <- readRDS(file = paste0(path_target, "rs-ws-03-2_results.rds"))






