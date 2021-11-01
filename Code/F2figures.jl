# Code for plots of Lecture 2 in Regression and Time Series Analysis courseFolder
# Plot titles and legends in Swedish

using Plots, LaTeXStrings, CSV, DataFrames, GLM, LinearAlgebra, Dates
using StatsBase, RCall, Statistics
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



# Healthdata from 'Regression and Other Stories' book
healthdata = DataFrame(CSV.File(dataFolder*"healthdata.csv"; header = true))

# Scatter - no annotation
scatter(healthdata.spending, healthdata.lifespan, xlab = "Hälsobudget (tusental US dollar per capita, köpkraftsjusterad)", ylab = "Förväntad livslängd (år)")
savefig(figFolder*"healthdata.pdf")

# Scatter - with annotation
Plots.reset_defaults()
gr(legend = nothing, grid = false, color = colors[2], lw = 2, legendfontsize=8,
    xtickfontsize=6, ytickfontsize=6, xguidefontsize=8, yguidefontsize=8, 
    titlefontsize = 10, markersize = 3, markerstrokecolor = :auto)
scatter(healthdata.spending, healthdata.lifespan, series_annotations = text.(healthdata.country, :bottom, :darkslategrey, 4), xlab = "Hälsobudget (tusental US dollar per capita, köpkraftsjusterad)", ylab = "Förväntad livslängd (år)")
savefig(figFolder*"healthdata_text.pdf")

# Health data fit - all data
Plots.reset_defaults()
gr(legend = nothing, grid = false, color = colors[2], lw = 2, legendfontsize=8,
    xtickfontsize=6, ytickfontsize=6, xguidefontsize=8, yguidefontsize=8, 
    titlefontsize = 10, markersize = 3, markerstrokecolor = :auto)

plot(xlab = "Hälsobudget (tusental US dollar per capita, köpkraftsjusterad)", 
    ylab = "Förväntad livslängd (år)", label = nothing, legend = :topleft)

fit = lm(@formula(lifespan ~ spending), healthdata)
βhat = coef(fit)
Plots.abline!(βhat[2], βhat[1], color = colors[4], lw = 2, label ="regressionslinje")

scatter!(healthdata.spending, healthdata.lifespan, series_annotations = text.(healthdata.country, :bottom, :darkslategrey, 4), label = nothing)

savefig(figFolder*"healthdata_text_fit.pdf")

# Correlation examples
gr(xguidefontsize=12, yguidefontsize=12)
x1 = randn(20)
x2 = x1 + 0.1*randn(20)
Corr = cor([x1 x2])
p1 = scatter(x1, x2, xlab = L"x_1", ylab = L"x_2", title = "r = $(round(Corr[1,2], digits = 3))")

x1 = randn(20)
x2 = -x1 + 0.1*randn(20)
Corr = cor([x1 x2])
p2 = scatter(x1, x2, xlab = L"x_1", ylab = L"x_2", title = "r = $(round(Corr[1,2], digits = 3))")

x1 = randn(20)
x2 = x1 + 1*randn(20)
Corr = cor([x1 x2])
p3 = scatter(x1, x2, xlab = L"x_1", ylab = L"x_2", title = "r = $(round(Corr[1,2], digits = 3))")

x1 = randn(20)
x2 = randn(20)
Corr = cor([x1 x2])
p4 = scatter(x1, x2, xlab = L"x_1", ylab = L"x_2", title = "r = $(round(Corr[1,2], digits = 3))")

plot(p1,p2,p3,p4, layout = (2,2))
savefig(figFolder*"correlationexamples.pdf")


# Correlation
cor([healthdata.spending healthdata.lifespan])
scatter(healthdata.spending, healthdata.lifespan, 
    xlab = "Hälsobudget (tusental US dollar per capita, köpkraftsjusterad)", 
    ylab = "Förväntad livslängd (år)", color = colors[2], 
    markersize = 4, title = "korrelation = 0.56")
savefig(figFolder*"healthcorr.pdf")

# Correlation is Linear
gr(xguidefontsize=12, yguidefontsize=12)
x = -10:10
y = x.^2
scatter(x, y, xlab = L"x_1", ylab = L"x_2", title = "noll korrelation", markersize = 4)
savefig(figFolder*"correlationislinear.pdf")

# Health data fit with and without the US
Plots.reset_defaults()
gr(legend = nothing, grid = false, color = colors[2], lw = 2, legendfontsize=8,
    xtickfontsize=6, ytickfontsize=6, xguidefontsize=8, yguidefontsize=8, 
    titlefontsize = 10, markersize = 3, markerstrokecolor = :auto)

plot(xlab = "Hälsobudget (tusental US dollar per capita, köpkraftsjusterad)", 
    ylab = "Förväntad livslängd (år)", label = nothing, legend = :topleft)

fit = lm(@formula(lifespan ~ spending), healthdata)
βhat = coef(fit)
Plots.abline!(βhat[2], βhat[1], color = colors[4], lw = 2, label ="med USA")
    
fit = lm(@formula(lifespan ~ spending), healthdata[Not(healthdata.country .== "USA"),:])
βhat = coef(fit)
Plots.abline!(βhat[2], βhat[1], color = colors[1], lw = 2, label ="utan USA")

scatter!(healthdata.spending, healthdata.lifespan, series_annotations = text.(healthdata.country, :bottom, :darkslategrey, 4), label = nothing)

savefig(figFolder*"healthdata_text_fit_USA.pdf")



# Anscombe quartet
Plots.reset_defaults()
gr(legend = nothing, grid = false, color = colors[2], lw = 2, legendfontsize=8,
    xtickfontsize=6, ytickfontsize=6, xguidefontsize=8, yguidefontsize=8, 
    titlefontsize = 10, markersize = 4, markerstrokecolor = :auto)
anscombe = RDatasets.dataset("datasets", "anscombe")
p = []
for i in "1234"
    push!(p, scatter(eval(Meta.parse("anscombe.X"*i)), eval(Meta.parse("anscombe.Y"*i)), 
        label = nothing, xlab = "x", ylab = "y", xlims = [4,20], ylims = [0,15]))
    fit = lm(@formula(Y1 ~ X1), anscombe)
    βhat = coef(fit)
    Plots.abline!(βhat[2], βhat[1], color = colors[4], lw = 3)
    scatter!(eval(Meta.parse("anscombe.X"*i)), eval(Meta.parse("anscombe.Y"*i)), title = L"a = %$(round(βhat[1], digits = 2)), b = %$(round(βhat[2], digits = 2))")
end
plot(p..., layout = (2,2))
savefig(figFolder*"anscombeQuartet.pdf")


# O-rings data - Extrapolation
oring = DataFrame(CSV.File(dataFolder*"orings.csv"; header = true))
oring.fracDistress = oring.nDistress./oring.nRisk
sort!(oring, :tempLaunch)
oring.nDistressViz = float(oring.nDistress)
for temp in minimum(oring.tempLaunch):maximum(oring.tempLaunch)
    if sum(oring.tempLaunch .== temp) == 2
        oring.nDistressViz[oring.tempLaunch .== temp] .= oring.nDistressViz[oring.tempLaunch .== temp] + [0.03, -0.03]
    end
    if sum(oring.tempLaunch .== temp) == 3
        oring.nDistressViz[oring.tempLaunch .== temp] .= oring.nDistressViz[oring.tempLaunch .== temp] + [0.03, 0, -0.03]
    end
    if sum(oring.tempLaunch .== temp) == 4
        oring.nDistressViz[oring.tempLaunch .== temp] .= oring.nDistressViz[oring.tempLaunch .== temp] + [0.03, 0.03, -0.03, -0.03]
    end
end
scatter(oring.tempLaunch, oring.nDistressViz, xlims = [30,80], ylims = [0,6], 
    legend = :topright, label = "data från tidigare avfärder", ylab = "antal skadade gummipackningar (jittered)", xlab = "temperatur (Fahrenheit)")
vline!([31], color = colors[4], label = "förväntad temperatur vid avfärd")
savefig(figFolder*"oring.pdf")


# ANOVA
healthNoUS = healthdata[Not(30),:];
plot()
fit = lm(@formula(lifespan ~ spending), healthNoUS)
βhat = coef(fit)
Plots.abline!(βhat[2], βhat[1], color = colors[4], lw = 2)
Plots.abline!(0, mean(healthNoUS.lifespan), color = colors[10], lw = 2)
annotate!([(0, mean(healthNoUS.lifespan), (L"\mathbf{\bar y}", 10, :bottom, colors[10]))])
annotate!([(2.3, 78, (L"\mathbf{\hat y = a+b \cdot x}", 10, :left, colors[4]))])
scatter!(healthNoUS.spending, healthNoUS.lifespan, c = colors[2])
