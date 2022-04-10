# Analys av titanic data
prettycol = RColorBrewer::brewer.pal(12, "Paired")[c(1,2,7,8,3,4,5,6,9,10,11,12)]

# Estimate simple logistic regression against age
library(regkurs)
fit <- glm(survived ~ age, data = titanic, family = binomial)
logisticregsummary(fit)
betas = fit$coef

# Plot survival odds as function of age
ageGrid = seq(min(titanic$age),max(titanic$age), length = 1000)
odds = exp(betas[1]  + betas[2]*ageGrid)
plot(ageGrid, odds, type = "l", xlab = "Age", ylab = "Odds survive",
     lwd = 3, col = prettycol[2])

# Estimate multiple logistic regression against age, sex, firstclass
library(regkurs)
fit <- glm(survived ~ age + sex + firstclass, data = titanic, family = binomial)
logisticregsummary(fit, conf_intervals = T)

betas = fit$coef
