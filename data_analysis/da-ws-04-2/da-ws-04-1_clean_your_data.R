filepath_base <- "D:/Uni/data_analysis/"
path_data <- paste0(filepath_base, "data/")
path_scripts <- paste0(filepath_base, "scripts/")

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
saveRDS(ernte, file = paste0(path_data, "harvest_data.rds"))




#################################################
####### Wurde in Funktion ausgelagert ###########
"place <- strsplit(as.character(ernte$Place), ",")
head(place)
max(sapply(place, length))

place_df <- lapply(place, function(i){
  p1 <- sub("^\\s+", "", i[1])
  if(length(i) > 2){
    p2 <- sub("^\\s+", "", i[2])
    p3 <- sub("^\\s+", "", i[3])
  }else if(length(i) > 1){
      p2 <- sub("^\\s+", "", i[2])
      p3 <- NA
  } else{
      p2 <- NA
      p3 <- NA
  }
  data.frame(A = p1, B = p2, C = p3)
})
place_df <- do.call("rbind", place_df)
place_df$ID <- ernte$ID
place_df$Year <- ernte$Year
head(place_df)
unique(place_df[,2])
unique(place_df[,3])
unique(place_df$B[!is.na(place_df$C)])

#B und C tauschen
place_df[!is.na(place_df$C), ] <- place_df[!is.na(place_df$C), c(1,3,2,4,5)]
head(place_df)"


