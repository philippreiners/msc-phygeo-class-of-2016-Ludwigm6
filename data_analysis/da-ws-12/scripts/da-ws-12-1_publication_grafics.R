# da-ws-12-1 visualisation

# install.packages("latticeExtra")
# install.packages("reshape2")
# install.packages("gridExtra")
library(lattice)
library(latticeExtra)
library(reshape2)
library(gridExtra)

source("d:/university/msc-phygeo-class-of-2016-Ludwigm6/fun/init.R")
path <-  fun_init("da", "12")

list.files(path$da$csv)
landuse <- readRDS(paste0(path$da$csv, "landuse_data.rds"))
c_name <- colnames(landuse)
c_name[6] <- "residental"
c_name[7] <- "recreation"
c_name[8] <- "agriculture"
c_name[9] <- "forest"
colnames(landuse) <- c_name

# boxplot with settlement, recreation, agriculture, forest
landuse_melt <- reshape2::melt(landuse, id.vars = seq(5))
bp_landuse <- bwplot(value ~ variable, data = landuse_melt, ylab = "rate", xlab = "landuse type")
bp_landuse

bp_opt <- trellis.par.get()
bp_opt$fontsize$text <- 10
bp_opt$box.dot$pch <- "|"
bp_opt$box.rectangle$col <- "black"
bp_opt$box.rectangle$lwd <- 2
bp_opt$box.umbrella$lty <- 1
bp_opt$box.umbrella$col <- "black"
bp_opt$plot.symbol$pch <- "*"
bp_opt$plot.symbol$col <- "black"

update(bp_landuse, par.settings = bp_opt)


# four plot, different transformations
trellis.par.set(bp_opt)

bp_org <- bwplot(value ~ variable, data = landuse_melt, main = "Original", ylab = "")
bp_root2 <- bwplot(value**0.5 ~ variable, data = landuse_melt, main = "Square Root", ylab = "")
bp_root3 <- bwplot(value**(1/3) ~ variable, data = landuse_melt, main = "Cube Root", ylab = "")
bp_log <- bwplot(log(value) ~ variable, data = landuse_melt, main = "Log", ylab = "")


grid.arrange(update(bp_org, par.settings = bp_opt),
             update(bp_root2, par.settings = bp_opt),
             update(bp_root3, par.settings = bp_opt),
             update(bp_log, par.settings = bp_opt),
             ncol = 2)


