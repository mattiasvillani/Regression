library(mlbench)
data(BreastCancer)
head(BreastCancer)
n = dim(BreastCancer)[1]
BreastCancer$Clthickness = as.numeric(BreastCancer$Cl.thickness)
BreastCancer$Cellsize = as.numeric(BreastCancer$Cell.size)
BreastCancer$Cellshape = as.numeric(BreastCancer$Cell.shape)
BreastCancer$Margadhesion = as.numeric(BreastCancer$Marg.adhesion)
BreastCancer$Epithcsize = as.numeric(BreastCancer$Epith.c.size)
BreastCancer$Barenuclei = as.numeric(BreastCancer$Bare.nuclei)
BreastCancer$Blcromatin = as.numeric(BreastCancer$Bl.cromatin)
BreastCancer$Normalnucleoli = as.numeric(BreastCancer$Normal.nucleoli)
BreastCancer$Mitoses = as.numeric(BreastCancer$Mitoses)
BreastCancer = data.frame(Clthickness = BreastCancer$Clthickness, Cellsize = BreastCancer$Cellsize, Cellshape = BreastCancer$Cellshape, Margadhesion = BreastCancer$Margadhesion,
                          Epithcsize = BreastCancer$Epithcsize, Barenuclei = BreastCancer$Barenuclei, Blcromatin = BreastCancer$Blcromatin, Normalnucleoli = BreastCancer$Normalnucleoli,
                          Mitoses = BreastCancer$Mitoses, Class = BreastCancer$Class)
write.csv(BreastCancer, file = "/home/mv/Dropbox/Teaching/Regression/Data/breastcancer.csv")

# Simple logistic
fitSimple = glm(Class ~ Cell.size, family = binomial(), data = BreastCancer)
summary(fitSimple)
yProbSimple = predict(fitSimple, type = "response")
yPredSimple = as.factor(ifelse(yProbSimple>0.5, "malignant", "benign"))
table(yPredSimple, BreastCancer$Class)




# Mutiple logistic regression
fitMultiple = glm(Class ~ Cl.thickness + Cell.size + Cell.shape + Marg.adhesion + Epith.c.size + Bl.cromatin + Normal.nucleoli + Mitoses, family = binomial(), data = BreastCancer)
summary(fitMultiple)
yProbMultiple = predict(fitMultiple, type = "response")
yPredMultiple = as.factor(ifelse(yProbMultiple>0.5, "malignant", "benign"))
table(yPredMultiple, BreastCancer$Class)

