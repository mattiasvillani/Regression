# Analys av hälsobudget data

# Installera kurspaket. Avkommentera (ta bort # om du inte redan har installerat remotes)
#install.packages("remotes")
library(remotes)
install_github("StatisticsSU/regkurs")
install_github("StatisticsSU/SUdatasets")

library(regkurs)
library(SUdatasets)
?healthbudget # Hjälp om healthbudget data

# Minsta-kvadratskattning med lm()-funktionen
lmfit = lm(lifespan ~ spending, data = healthbudget)

# Sammanfatta regression - SAS-style
regsummary(lmfit, conf_intervals = T) # Utskrift med 95%-iga konfidensintervall
confint(lmfit, level = 0.99) # Konfidensintervall med annan täckningsgrad

# Residualanalys
res.diagnostics(lmfit)


# Utan USA
lmfit = lm(lifespan ~ spending, data = healthbudget[-30,])
res.diagnostics(lmfit)

