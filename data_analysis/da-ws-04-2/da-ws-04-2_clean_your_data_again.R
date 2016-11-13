filepath_base <- "D:/Uni/data_analysis/"
path_data <- paste0(filepath_base, "data/")
path_scripts <- paste0(filepath_base, "scripts/")

landuse <- read.table(paste0(path_data, "AI001_gebiet_flaeche.txt"), skip = 4, header = TRUE, sep = ";", dec = ",")

head(landuse)
colnames(landuse) <- c("Year", "ID", "Place", 
                       "rate_residential", "rate_recovery",
                       "rate_agriculture", "rate_forest")


tail(landuse)
#Looks OK

str(landuse)

for(c in colnames(landuse)[4:ncol(landuse)]){
  landuse[,c][landuse[,c] == "." | 
              landuse[,c] == "-" |
              landuse[,c] == "," |
              landuse[,c] == "/" ] <- NA
  
  landuse[,c] <- as.numeric(sub(",", ".", as.character(landuse[,c])))
}

summary(landuse)

#function to split the Place column
source(paste0(path_scripts, "split_place_column.R"))
landuse <- placesplit(landuse)

saveRDS(landuse, paste0(path_data, "landuse_data.rds"))
