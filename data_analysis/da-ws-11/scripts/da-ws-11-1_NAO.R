# da-ws-11-1 NAO and Coelbe

# initialise script
source("d:/university/msc-phygeo-class-of-2016-Ludwigm6/fun/init.R")
path <-  fun_init("da", "11")

# load libraries
library(forecast)

# load raw data
NAO <- read.table(paste0(path$da$csv, "dwd/nao_norm_1950-2000.txt"),
                  header = TRUE, dec = ".")
dwd <- read.table(paste0(path$da$csv, "dwd/produkt_monat_Monatswerte_19460101_20141231_03164.txt"),
                header = TRUE, sep = ";", dec = ".")


# # # Part 1: Trends in Temperature # # #

# extract temperature
t <- data.frame(date = dwd$MESS_DATUM_BEGINN,
                t = dwd$LUFTTEMPERATUR)

# get only data between 1950 and 1990
t <- t[t$date > 19500000 & t$date < 19910000,]
t$year <- substr(t$date, 1, 4)
t$month <- substr(t$date, 5, 6)

# convert date to correct format
t$date <- strptime(paste0(substr(t$date, 1, 6), "010000"), format = "%Y%m%d%H%M", tz = "UTC")

# clean seasonality by subtracting the mean of each month from the actual monthly temperature
# so we get the deviation from the mean for each month
monthly_mean <- aggregate(t$t, by = list(t$month), FUN = mean)
t$t_minus_mean <- t$t - monthly_mean$x

# for the lm we need a continuous time variable
# this divides the years in 12 equal parts:
ts <- seq(1950, 1990+11/12, length = nrow(t))

# compute linear model
mod_t <- lm(t$t_minus_mean ~ ts)
# show results
plot(ts, t$t_minus_mean, type = "l", xlab = "Time", ylab = "temperature difference from mean")
abline(mod_t, col = "red")


# # # Part 2.1: Temperature ~ NAO

# only data between 1950 and 1990
NAO <- NAO[NAO$YEAR < 1991,]

# categorize NAO
NAO$cat <- "negative"
NAO$cat[NAO$INDEX >= 0] <- "positive"
NAO$cat <- as.factor(NAO$cat)  

mod_nao <- lm(t$t_minus_mean ~ NAO$cat + sin(2*pi*ts) + cos(2*pi*ts))
summary(mod_nao)

# # # Part 2.2: Quality check by dummy models

# create dummy models with random NAO values
# Falls die Verteilung von positiv-negativ nicht 50/50 ist wie in diesem Fall,
# muss bei der Zufälligkeit berücksichtigt werden?

dummys <- lapply(seq(2001), function(i){
  # create dummy column
  NAO$dummy_cat <- "negative"
  # sample half and assign positive
  set.seed(i)
  s <- sample(nrow(NAO), size = nrow(NAO)/2)
  NAO$dummy_cat[s] <- "positive"
  NAO$dummy_cat <- as.factor(NAO$dummy_cat)
  # compute dummy lm
  mod_dummy <- lm(t$t_minus_mean ~ NAO$dummy_cat + sin(2*pi*ts) + cos(2*pi*ts))
  
  # use intercept[1] or nao[2] ??
  return(mod_dummy$coefficients[2])
})
dummys <- do.call(rbind, dummys)

# two different methods to identify lowest and hightest 2.5%
dummys <- sort(dummys)
lowest <- dummys[length(dummys)*0.0025]
highest <- dummys[length(dummys)*0.975]

lowest <- quantile(dummys, 0.025)
highest <- quantile(dummys, 0.975)

mod_nao$coefficients[2] < lowest | mod_nao$coefficients[2] > highest
