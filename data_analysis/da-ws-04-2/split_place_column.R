placesplit <- function(df){
columns <- colnames(df)

#Prüfen ob genaue eine Spalte mit dem Namen 'Place' vorhanden ist
secure_pl <- 0
for(i in 1:length(columns)){
  if(columns[i] == "Place"){
  secure_pl <- secure_pl+1  
  }
}

if(secure_pl != 1){
  stop("df needs exactly one column with name 'Place'")
} 
##########################

#Text am Komma aufsplitten und in eine Liste schreiben
#Pro Zeile der Tabelle gibt es einen Listeneintrag.
#Jeder Listeneintrag besteht aus Character-Vektoren mit verschiedenen Länge, je nach Anzahl der Kommas

place <- strsplit(as.character(df$Place), ",")

#Aus der 'place' Liste eine neue Liste erstellen die pro Listeneintrag einen dataframe enthält
#Jeder dataframe hat drei Spalten mit jeweils einem aufgetrennten character aus 'place'
#Vorangestellte Leerzeichen werden entfernt (mithilfe reg_exp)
#sub Befehl(Substitute): sub(pattern, replacement, zu durchsuchender Text)
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

#Aus der Liste einen richtigen dataframe machen (rbind = reihen verbinden)
#Was genau macht do.call anders als rbind(place_df)?
place_df <- do.call("rbind", place_df)

#Die 'Primaerschluessel' der Ursprungstabelle der Place-Tabelle hinzufügen
place_df$ID <- df$ID
place_df$Year <- df$Year


#Wenn in Spalte C kein NA steht (also 'Kreisfreie Stadt') 
#dann werden in dieser Zeile Spalte 2 und 3 vertauscht
place_df[!is.na(place_df$C), ] <- place_df[!is.na(place_df$C), c(1,3,2,4,5)]
head(place_df)

#Spalten benennen und umordnen
colnames(place_df) <- c("Place", "Admin_unit", "Admin_misc", "ID", "Year")
place_df <- place_df[,c(4,5,1,2,3)]
head(place_df)

#Die drei neuen Spalten in den Ursprungs-Dataframe einbauen  
df <- cbind(place_df, df[,4:ncol(df)])
  
return(df)  
}