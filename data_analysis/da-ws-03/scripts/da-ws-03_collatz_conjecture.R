#Collatz

n <- 19
res <- numeric()

for(index in seq(1:100)){
  
  for(i in n){
    if(i%%2 == 0){
      res[index] <- i/2
      n <- i/2
    }else{
      res[index] <- 3*i+1
      n <- 3*i+1
    }
  }
}
print(res)


#Sauberer
res2 <- vector(mode = "numeric", length = 1000)
res2[1] <- 500
for(index in seq(1:1000)){
  if(res2[index]%%2 == 0){
    res2[index+1] <- res2[index]/2 
  }else{
    res2[index+1] <- res2[index]*3+1
  }
}
print(res2)

#Noch besser
res2 <- numeric()
res2[1] <- 500
index <- 1
while(res2[index] > 1){
  if(res2[index]%%2 == 0){
    res2[index+1] <- res2[index]/2 
  }else{
    res2[index+1] <- res2[index]*3+1
  }
  index <- index+1
}
print(res2)


