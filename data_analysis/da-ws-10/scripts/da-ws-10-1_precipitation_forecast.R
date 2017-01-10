# da-ws-10-1 precipitation forecast

install.packages("forecast")
library(forecast)

# initialise script
source("d:/university/msc-phygeo-class-of-2016-Ludwigm6/fun/init.R")
path <-  fun_init("da", "10")

# read data
data <- read.table(paste0(path$da$csv, "produkt_synop_Terminwerte_20060701_20151231_03164.txt"), sep = ";", header = TRUE)

# create new column with the first 6 digits of MESS_DATUM (year and month)
data$agg <- substr(data$MESS_DATUM, 1, 6)

# aggregate the monthly precipitation 
prec <- aggregate(data$NIEDERSCHLAGSHOEHE, by = list(data$agg), FUN = sum)
names(prec) <- c("date", "prec")

# divide data in test (last 2 years) and train (rest)
train <- prec[prec$date < 201401,]
test <- prec[prec$date >= 201401,]

# create data frame with all possible parameter combinations
parameters <- expand.grid(p = seq(0,5), d = seq(0,2), q = seq(0, 5), ps = seq(0, 2), ds = seq(0, 2), qs = seq(0, 2))



res <- lapply(seq(10), function(x){
  mod <- arima(prec$prec,
               order = c(parameters$p[x], parameters$d[x], parameters$q[x]),
               seasonal = c(parameters$ps[x], parameters$ds[x], parameters$qs[x]),
               method = "ML")
  pre <- predict(mod, n.ahead = 24)
  
  return(data.frame(p = parameters$p[x], d = parameters$d[x], q = parameters$q[x],
                    ps = parameters$ps[x], ds = parameters$ds[x], qs = parameters$qs[x],
                    rmse = sqrt(mean((pre$pred - test$prec)^2)),
                    aic = mod$aic))
})
res <- do.call("rbind", res)


automod <- forecast::auto.arima(prec$prec, max.p = 5, max.d = 2, max.q = 5, stationary = TRUE, seasonal = FALSE)
summary(automod)
