filepath_base <- "D:/Uni/landuse_harvest/"
path_data <- paste0(filepath_base, "data/csv/")
path_target <- paste0(filepath_base, "data/rdata/")
path_scripts <- "D:/Uni/msc-phygeo-class-of-2016-Ludwigm6/data_analysis/da-ws-04-2"

ernte <- read.table(paste0(path_data, "115-46-4_feldfruechte.txt"), skip  = 6, header = TRUE, sep = ";", fill = TRUE, encoding = "ANSI")

#New colums
colnames(ernte) <- c("Year", "ID", "Place", "Winter_wheat", "Rye", "Winter_barley",
                     "Spring_barley", "Oat", "Triticale", "Potatos", "Suggar_beets",
                     "Rapeseed", "Silage_maize")
head(ernte)
str(ernte)

#Tail
tail(ernte)
ernte <- ernte[1:8925,]
tail(ernte)

#Factor to Numeric, NA statt Sonderzeichen
str(ernte)

##############
for(c in colnames(ernte)[4:13]){
  ernte[,c][ernte[,c] == "." | 
            ernte[,c] == "-" |
            ernte[,c] == "," |
            ernte[,c] == "/" ] <- NA
  ernte[,c] <- as.numeric(sub(",", ".", as.character(ernte[,c])))
}


summary(ernte)

#######################################
#Place auftrennen mit Funktion
source(paste0(path_scripts, "split_place_column.R"))
ernte <- placesplit(ernte)
saveRDS(ernte, file = paste0(path_target, "harvest_data.rds"))



