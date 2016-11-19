landuse <- readRDS(file.choose())
harvest <- readRDS(file.choose())
install.packages('car')
library(car)

model <- lm(landuse$rate_recovery ~ landuse$rate_residential)
plot(model)

plot(landuse$rate_residential, landuse$rate_recovery)
regLine(model, col = "red")

plot(model, which = 4)
