filepath_base <- "D:/Uni/data_analysis/"

#Daten einlesen
wood <- read.table(paste0(filepath_base,"data/hessen_holzeinschlag_1997-2014.csv"), header = TRUE, skip = 4, sep = ";")
wood <- wood[1:nrow(wood)-1,] #letzte Zeile Löschen
print(wood)


#Boxplots der einzelnen Baumarten erstellen
par(mfrow = c(1,1))
boxplot(wood[,c(2:7)])
#Skalierung staucht manche Baumarten;besser sechs einzelne Boxplots:
par_test <- par()
par(mfrow = c(2,3))
head <- colnames(wood)

for(i in c(2:7)){
  boxplot(wood[,i], main = head[i])
}

#Kiefer:
#Die Werte streuen weit aber relativ Gleichmäßig um den Median.
#Buche:
#Hohe Werte konzentrieren nahe des Median, niedrie Werte sind seltener und zerstreuter.

par(mfrow =c(2,2))
plot(wood$Buche, wood$Eiche)
plot(wood$Buche, wood$Kiefer)
plot(wood$Buche, wood$Fichte)
plot(wood$Buche, wood$Buntholz)
