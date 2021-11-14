# Code for plots of Lecture 6 in Regression and Time Series Analysis course
# Plot titles and legends in Swedish

using Plots, LaTeXStrings, CSV, DataFrames, GLM, LinearAlgebra, Dates, StatsPlots, Measures
using StatsBase, RCall, Statistics, Distributions, Lasso
using RDatasets
using Flux: onehot, onehotbatch
import ColorSchemes: Paired_12; colors = Paired_12
colors = Paired_12[[1,2,7,8,3,4,5,6,9,10,11,12]]
courseFolder = "/home/mv/Dropbox/Teaching/Regression/"
figFolder = courseFolder*"Slides/figs/"
dataFolder = courseFolder*"Data/"
giturl = "https://github.com/mattiasvillani/Regression/"

Plots.reset_defaults()
gr(legend = nothing, grid = false, color = colors[2], lw = 2, legendfontsize=10,
    xtickfontsize=12, ytickfontsize=12, xguidefontsize=12, yguidefontsize=12, 
    markersize = 4, markerstrokecolor = :auto)

function RMSECVcars(cars, regFormula, shuffleIdx, K)
    n = size(cars,1)
    S = Int(n/K)
    RMSE = zeros(K)
    for k = 1:K
        subsetTest = shuffleIdx[1+(k-1)*S:k*S]
        subsetTrain = setdiff(1:n,shuffleIdx[1+(k-1)*S:k*S])
        carsTest = cars[subsetTest,:]
        carsTrain = cars[subsetTrain,:]
        fitSubset = lm(regFormula, carsTrain)
        yPred = predict(fitSubset, carsTest)
        yTest = carsTest.mpg
        RMSE[k] = sqrt(mean((yPred .- yTest).^2))
    end
    return mean(RMSE)
end

cars = DataFrame(CSV.File(dataFolder*"cars.csv"))
cars.hp = cars.hp/maximum(cars.hp)
hpGrid = 0:0.01:1
K = 4
n = size(cars,1)
shuffleIdx = sample(1:n, n, replace = false)

# cars - linear fit
polyOrder = 1
regFormula = @formula(mpg ~ hp)
RMSECV = RMSECVcars(cars, regFormula, shuffleIdx, K)
RMSEs = [RMSECV]
plot(ylims = [0,40])
fit = lm(regFormula, cars)
R2s = [r2(fit)]
βhat = coef(fit)
Xgrid = ones(length(hpGrid),1);
for r = 1:polyOrder
    Xgrid = [Xgrid hpGrid.^r];
end
yPred = Xgrid*βhat
plot!(hpGrid, yPred, color = colors[4], 
title = L"R^2 = %$(round(r2(fit), digits = 3))\ \mathrm{and}\ \mathrm{RMSE}_{\mathrm{CV}} = %$(round(RMSECV, digits = 3))")
scatter!(cars.hp, cars.mpg, xlab = "horsepower (hp)", ylab = "miles per gallon (mpg)")
annotate!([(0.50, 38, (L"\mathbf{\mathrm{mpg} = %$(round(βhat[1],digits = 4)) %$(round(βhat[2],digits = 4)) \cdot \mathrm{hp}}", 12, :top, colors[2]))])
savefig(figFolder*"cars_mpg_vs_hpPoly$polyOrder.pdf")

# Residuals vs linear hp
carResiduals = cars.mpg .- (βhat[1] .+ βhat[2]*cars.hp)
scatter(cars.hp, carResiduals, xlab = "horsepower (hp)", ylab = "residuals")
savefig(figFolder*"carresidual.pdf")



# cars - quadratic fit
polyOrder = 2
regFormula = @formula(mpg ~ hp +hp^2)
RMSECV = RMSECVcars(cars, regFormula, shuffleIdx, K)
RMSEs = [RMSEs;RMSECV]
plot(ylims = [0,40])
fit = lm(regFormula, cars)
R2s = [R2s;r2(fit)]
plot(ylims = [0,40])
fit = lm(regFormula, cars)
βhat = coef(fit)
Xgrid = ones(length(hpGrid),1);
for r = 1:polyOrder
    Xgrid = [Xgrid hpGrid.^r];
end
yPred = Xgrid*βhat
plot!(hpGrid, yPred, color = colors[4], 
title = L"R^2 = %$(round(r2(fit), digits = 3))\ \mathrm{and}\ \mathrm{RMSE}_{\mathrm{CV}} = %$(round(RMSECV, digits = 3))")
scatter!(cars.hp, cars.mpg, xlab = "horsepower (hp)", ylab = "miles per gallon (mpg)")
annotate!([(0.5, 39, (L"\mathbf{\mathrm{mpg} = %$(round(βhat[1],digits = 4)) %$(round(βhat[2],digits = 4)) \cdot \mathrm{hp} + %$(round(βhat[3],digits = 4)) \cdot \mathrm{hp}^2}", 12, :top, colors[2]))])
savefig(figFolder*"cars_mpg_vs_hpPoly$polyOrder.pdf")

# Adding derivative
plot(ylims = [0,40], legend = :topright)
plot!(hpGrid, yPred, color = colors[4], label = "kvadratisk anpassning")
scatter!(cars.hp, cars.mpg, xlab = "horsepower (hp)", ylab = "miles per gallon (mpg)",  label = nothing)

x = 0.25
y = yPred[hpGrid .== x][1]
deriv = βhat[2] + 2*βhat[3]*x
vline!([x], linestyle = :dash, c = colors[5], label = L"x = 0.25")
Plots.abline!(deriv, y-deriv*x, color = colors[6], label = "derivatan vid x = 0.25")

x = 0.7
y = yPred[hpGrid .== x][1]
deriv = βhat[2] + 2*βhat[3]*x
vline!([x], linestyle = :dash, c = colors[9], label = L"x = 0.7")
Plots.abline!(deriv, y-deriv*x, color = colors[10], label = "derivatan vid x = 0.7")

savefig(figFolder*"CarDerivata.pdf")

# Residuals vs quadratic hp
carResiduals = cars.mpg .- (βhat[1] .+ βhat[2]*cars.hp .+ βhat[3]*cars.hp.^2)
scatter(cars.hp, carResiduals, xlab = "horsepower (hp)", ylab = "residuals")
savefig(figFolder*"carresidual_quad.pdf")

# cars - cubic fit
polyOrder = 3
regFormula = @formula(mpg ~ hp +hp^2 +hp^3)
RMSECV = RMSECVcars(cars, regFormula, shuffleIdx, K)
RMSEs = [RMSEs;RMSECV]
fit = lm(regFormula, cars)
R2s = [R2s;r2(fit)]
plot(ylims = [0,40])
fit = lm(regFormula, cars)
βhat = coef(fit)
Xgrid = ones(length(hpGrid),1);
for r = 1:polyOrder
    Xgrid = [Xgrid hpGrid.^r];
end
yPred = Xgrid*βhat
plot!(hpGrid, yPred, color = colors[4], 
title = L"R^2 = %$(round(r2(fit), digits = 3))\ \mathrm{and}\ \mathrm{RMSE}_{\mathrm{CV}} = %$(round(RMSECV, digits = 3))")
scatter!(cars.hp, cars.mpg, xlab = "horsepower (hp)", ylab = "miles per gallon (mpg)")
annotate!([(0.5, 39, (L"\mathbf{\mathrm{mpg} = %$(round(βhat[1],digits = 4)) %$(round(βhat[2],digits = 4)) \cdot \mathrm{hp} + %$(round(βhat[3],digits = 4)) \cdot \mathrm{hp}^2 %$(round(βhat[4],digits = 4)) \cdot \mathrm{hp}^3}", 12, :top, colors[2]))])
savefig(figFolder*"cars_mpg_vs_hpPoly$polyOrder.pdf")


# cars - polynomial order 4 
polyOrder = 4
regFormula = @formula(mpg ~ hp + hp^2 + hp^3 + hp^4)
RMSECV = RMSECVcars(cars, regFormula, shuffleIdx, K)
RMSEs = [RMSEs;RMSECV]
plot(ylims = [0,40])
fit = lm(regFormula, cars)
R2s = [R2s;r2(fit)]
βhat = coef(fit)
Xgrid = ones(length(hpGrid),1);
for r = 1:polyOrder
    Xgrid = [Xgrid hpGrid.^r];
end
yPred = Xgrid*βhat
plot!(hpGrid, yPred, color = colors[4], 
title = L"R^2 = %$(round(r2(fit), digits = 3))\ \mathrm{and}\ \mathrm{RMSE}_{\mathrm{CV}} = %$(round(RMSECV, digits = 3))")
scatter!(cars.hp, cars.mpg, xlab = "horsepower (hp)", ylab = "miles per gallon (mpg)")
savefig(figFolder*"cars_mpg_vs_hpPoly$polyOrder.pdf")


# cars - polynomial order
polyOrder = 5
regFormula = @formula(mpg ~ hp + hp^2 + hp^3 + hp^4 + hp^5)
RMSECV = RMSECVcars(cars, regFormula, shuffleIdx, K)
RMSEs = [RMSEs;RMSECV]
plot(ylims = [0,40])
fit = lm(regFormula, cars)
R2s = [R2s;r2(fit)]
βhat = coef(fit)
Xgrid = ones(length(hpGrid),1);
for r = 1:polyOrder
    Xgrid = [Xgrid hpGrid.^r];
end
yPred = Xgrid*βhat
plot!(hpGrid, yPred, color = colors[4], 
title = L"R^2 = %$(round(r2(fit), digits = 3))\ \mathrm{and}\ \mathrm{RMSE}_{\mathrm{CV}} = %$(round(RMSECV, digits = 3))")
scatter!(cars.hp, cars.mpg, xlab = "horsepower (hp)", ylab = "miles per gallon (mpg)")
savefig(figFolder*"cars_mpg_vs_hpPoly$polyOrder.pdf")

# Cars -plot R2 and RMSE_test
p1 = plot(1:5, R2s, lw = 3, c = colors[2], ylab = L"R^2", xlab = "polynomgrad", title = L"R^2")
p2 = plot(1:5, RMSEs, lw = 3, c = colors[4], ylab = L"\mathrm{RMSE}_\mathrm{test}", xlab = "polynomorder", title = L"\mathrm{RMSE}_\mathrm{test}")
plot(size = (1000,400), p1, p2, layout = (1,2), margin = 5mm)
savefig(figFolder*"carsR2_RMSEtest.pdf")


# cars - polynomial order
polyOrder = 10
regFormula = @formula(mpg ~ hp + hp^2 + hp^3 + hp^4 + hp^5 + hp^6 + hp^7 + hp^8 + hp^9 + hp^10)
RMSECV = RMSECVcars(cars, regFormula, shuffleIdx, K)
plot(ylims = [0,40])
fit = lm(regFormula, cars)
βhat = coef(fit)
Xgrid = ones(length(hpGrid),1);
for r = 1:polyOrder
    Xgrid = [Xgrid hpGrid.^r];
end
yPred = Xgrid*βhat
plot!(hpGrid, yPred, color = colors[4], 
title = L"R^2 = %$(round(r2(fit), digits = 3))\ \mathrm{and}\ \mathrm{RMSE}_{\mathrm{CV}} = %$(round(RMSECV, digits = 3))")
scatter!(cars.hp, cars.mpg, xlab = "horsepower (hp)", ylab = "miles per gallon (mpg)")
savefig(figFolder*"cars_mpg_vs_hpPoly$polyOrder.pdf")

# Cars -plot R2 and RMSE_test
p1 = plot(1:5, R2s, lw = 3, c = colors[2], ylab = L"R^2", xlab = "polynomgrad", title = L"R^2")
p2 = plot(1:5, RMSEs, lw = 3, c = colors[4], ylab = L"\mathrm{RMSE}_\mathrm{test}", xlab = "polynomorder", title = L"\mathrm{RMSE}_\mathrm{test}")
plot(size = (1000,400), p1, p2, layout = (1,2), margin = 5mm)
savefig(figFolder*"carsR2_RMSEtest.pdf")


# Lasso
lassoFit = Lasso.fit(LassoModel, regFormula, cars)
βhat = coef(lassoFit)
yPred = Xgrid*βhat
plot(ylims = [0,40], title = "Polynom ordning 10 - Lasso regularisering")
plot!(hpGrid, yPred, color = colors[4])
scatter!(cars.hp, cars.mpg, xlab = "horsepower (hp)", ylab = "miles per gallon (mpg)")
savefig(figFolder*"cars_mpg_vs_hpPolyLasso$polyOrder.pdf")


# China's growth 2000-2012
china_gdp = DataFrame(CSV.File(dataFolder*"china_gdp.csv"))
china_gdp = china_gdp[41:53,:]
china_gdp.year = 1:13
china_gdp.loggdp = log10.(china_gdp.gdp)
fit = lm(@formula(loggdp ~ year), china_gdp)
βtilde = coef(fit)
β = 10 .^ βtilde
scatter(Int.(2000 .+ china_gdp.year), china_gdp.gdp, xlab = "year", ylab = "GDP per capita (USD)")
plot!(Int.(2000 .+ china_gdp.year), β[1]*β[2].^china_gdp.year, color = colors[4], lw = 3)
annotate!([(2005,5000, (L"\mathbf{\mathrm{gdp} = %$(round(β[1],digits = 4)) \cdot %$(round(β[2],digits = 4)) ^{(\mathrm{year}-1999)}}", 12, :top, colors[2]))])
savefig(figFolder*"chinagdp2000_12.pdf")

china_gdp = DataFrame(CSV.File(dataFolder*"china_gdp.csv"))
china_gdp = china_gdp[41:61,:]
china_gdp.year = 1:21
china_gdp.loggdp = log10.(china_gdp.gdp)
fit = lm(@formula(loggdp ~ year), china_gdp)
βtilde = coef(fit)
β = 10 .^ βtilde
scatter(Int.(2000 .+ china_gdp.year), china_gdp.gdp, xlab = "year", ylab = "GDP per capita (USD)")
plot!(Int.(2000 .+ china_gdp.year), β[1]*β[2].^china_gdp.year, color = colors[4], lw = 3)
annotate!([(2008,10000, (L"\mathbf{\mathrm{gdp} = %$(round(β[1],digits = 4)) \cdot %$(round(β[2],digits = 4)) ^{(\mathrm{year}-1999)}}", 12, :top, colors[2]))])
savefig(figFolder*"chinagdp2000_now.pdf")
# Reading the univerisity salaries dataset from the RDatasets package
df = dataset("car","Salaries")
df.logsalary = log.(df.Salary)
df.phdage = df.YrsSincePhD ./ maximum(df.YrsSincePhD) # normalize academic age
df.phdagesqr = df.phdage.^2

# Create binary dummy variables for categorical covariates (one-hot encoding)
Z = onehotbatch(df.Rank, ["AsstProf", "AssocProf", "Prof"])'
for k ∈ 2:size(Z,2)
	df[!,Symbol("rank",k)] = Z[:,k]
end
df.sex = (df.Sex .== "Male")
df.discipline = (df.Discipline .== "A")

# Salary histogram
p1 = histogram(df.Salary, bins = 15, normalize = true, linecolor = :white, title = "Lön")
density!(p1, df.Salary, color = colors[4], lw = 3)

p2 = histogram(df.logsalary, bins = 15, normalize = true, linecolor = :white, title = "Log lön")
density!(p2, df.logsalary, color = colors[4], lw = 3)
plot(size = (1000,400), p1, p2, layout = (1,2))
savefig(figFolder*"salaryHist.pdf")


# Plot salary against phdage
p1 = scatter(df.phdage, df.Salary, color = colors[2], 
    ylabel = "salary", xlabel = "years since PhD (normalized)", label = "")
p2 = scatter(df.phdage, df.logsalary, color = colors[2], 
    ylabel = "log salary", xlabel = "years since PhD (normalized)", label = "")
plot(size = (1000,400), p1, p2, layout = (1,2))
savefig(figFolder*"SalariesVsPhdAge.pdf")

# Plot logsalary against phdage
scatter(df.phdage, df.logsalary, color = colors[2], 
    ylabel = "log salary", xlabel = "years since PhD (normalized)", label = "")
savefig(figFolder*"LogSalariesVsPhdAge.pdf")