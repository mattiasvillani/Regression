# Polynom-regression mtcars data

library("RColorBrewer") # for pretty colors
colors = brewer.pal(12, "Paired")[c(1,2,7,8,3,4,5,6,9,10)]

mtcars$hp = mtcars$hp/max(mtcars$hp) # Normaliserar hp-variabeln så max(hp) = 1
n = nrow(mtcars)

# Linjär regression på hela datamaterialet
fit1 = lm(mpg ~ hp, data = mtcars)
summ1 = summary(fit1)

fit2 = lm(mpg ~ hp + I(hp^2), data = mtcars)
summ2 = summary(fit2)

fit3 = lm(mpg ~ hp + I(hp^2) + I(hp^3), data = mtcars)
summ3 = summary(fit3)

fit4 = lm(mpg ~ hp + I(hp^2) + I(hp^3) + I(hp^4), data = mtcars)
summ4 = summary(fit4)

fit5 = lm(mpg ~ hp + I(hp^2) + I(hp^3) + I(hp^4) + I(hp^5), data = mtcars)
summ5 = summary(fit5)

fit10 = lm(mpg ~ hp + I(hp^2) + I(hp^3) + I(hp^4) + I(hp^5) +
          I(hp^6) + I(hp^7) + I(hp^8) + I(hp^9) + I(hp^10), data = mtcars)
summ10 = summary(fit10)


R2 = c(summ1$r.squared, summ2$r.squared, summ3$r.squared, summ4$r.squared,
       summ5$r.squared,summ10$r.squared)
adjR2 = c(summ1$adj.r.squared, summ2$adj.r.squared, summ3$adj.r.squared, summ4$adj.r.squared,
       summ5$adj.r.squared,summ10$adj.r.squared)
plot(c(1,2,3,4,5), R2[1:5], type = "l", col = colors[2], lwd = 3,
     ylim = c(0.55,0.8), xlab = "Polynomgrad", ylab = "R2")
lines(c(1,2,3,4,5), adjR2[1:5], col = colors[4], lwd = 3)


# kors-validering med K=4 folds
randIdx = matrix(sample(1:n, replace = F), 8, 4)
nFolds = dim(randIdx)[2]
RMSEcv = rep(0,5)

# Grad 1 - linjär modell
MSE = 0
for (k in 1:nFolds){
    fit = lm(mpg ~ hp, data = mtcars[randIdx[,-k],])
    yPred = predict(fit, newdata = mtcars[randIdx[,k],])
    MSE = MSE + sum((mtcars[randIdx[,k],]$mpg - yPred)^2)
}
RMSEcv[1] = sqrt(MSE/n)

# Grad 2 - kvadratisk modell
MSE = 0
for (k in 1:nFolds){
  fit = lm(mpg ~ hp + I(hp^2), data = mtcars[randIdx[,-k],])
  yPred = predict(fit, newdata = mtcars[randIdx[,k],])
  MSE = MSE + sum((mtcars[randIdx[,k],]$mpg - yPred)^2)
}
RMSEcv[2] = sqrt(MSE/n)

# Grad 3
MSE = 0
for (k in 1:nFolds){
  fit = lm(mpg ~ hp + I(hp^2) + I(hp^3), data = mtcars[randIdx[,-k],])
  yPred = predict(fit, newdata = mtcars[randIdx[,k],])
  MSE = MSE + sum((mtcars[randIdx[,k],]$mpg - yPred)^2)
}
RMSEcv[3] = sqrt(MSE/n)

# Grad 4
MSE = 0
for (k in 1:nFolds){
  fit = lm(mpg ~ hp + I(hp^2) + I(hp^3) + I(hp^4), data = mtcars[randIdx[,-k],])
  yPred = predict(fit, newdata = mtcars[randIdx[,k],])
  MSE = MSE + sum((mtcars[randIdx[,k],]$mpg - yPred)^2)
}
RMSEcv[4] = sqrt(MSE/n)

# Grad 5
MSE = 0
for (k in 1:nFolds){
  fit = lm(mpg ~ hp + I(hp^2) + I(hp^3) + I(hp^4) + I(hp^5), data = mtcars[randIdx[,-k],])
  yPred = predict(fit, newdata = mtcars[randIdx[,k],])
  MSE = MSE + sum((mtcars[randIdx[,k],]$mpg - yPred)^2)
}
RMSEcv[5] = sqrt(MSE/n)

plot(1:5, RMSEcv, type = "l", col = colors[6], lwd = 3, xlab = "Polynomgrad", ylab = "RMSE_cv")
