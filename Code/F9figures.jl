# Code for plots of Lecture 8 in Regression and Time Series Analysis course
# Plot titles and legends in Swedish

using Plots, LaTeXStrings, CSV, DataFrames, GLM, LinearAlgebra, Dates, StatsPlots, Dates
using StatsBase, RCall, Statistics, Distributions, LaTeXTabulars, RegressionTables
import ColorSchemes: Paired_12; colors = Paired_12
colors = Paired_12[[1,2,7,8,3,4,5,6,9,10,11,12]]
courseFolder = "/home/mv/Dropbox/Teaching/Regression/"
figFolder = courseFolder*"Slides/figs/"
dataFolder = courseFolder*"Data/"

Plots.reset_defaults()
gr(legend = nothing, grid = false, color = colors[2], lw = 2, legendfontsize=12,
    xtickfontsize=12, ytickfontsize=12, xguidefontsize=12, yguidefontsize=12, 
    markersize = 4, markerstrokecolor = :auto)

gr(legend = :bottomright, titlefontsize = 12)

# Create binary dummy variables for categorical covariates (one-hot encoding)
function seasonDummies(seasonVar)
    nObs = length(seasonVar)
    nSeason = length(unique(seasonVar))
    Dummies = zeros(Int, n, nSeason)
    for i = 1:n
        Dummies[i,seasonVar[i]] = 1
    end
    return Dummies # All dummies returned
end




# Airline data
airline = DataFrame(CSV.File(dataFolder*"airpassenger.csv"; header = true))
airlineMat = Matrix(airline[!,2:end])
n = length(1949:1960)*12
airlinevect = zeros(n)
for year = 1:12
    airlinevect[1+(year-1)*12: 12*year] = airlineMat[year,:]
end

airlinedates = Vector{Date}(undef,length(airlinevect));
t = 0;
for y = 1949:1960
    for m = 1:12
        t = t + 1
        airlinedates[t]  = Date(string(y)*"-"*string(m), "yyyy-mm")
    end
end

n = length(airlinevect)
airlineSeason = repeat(1:12, Int(n/12))

D = seasonDummies(airlineSeason)
dfSeasonDummies = DataFrame(D)
rename!(dfSeasonDummies,names(airline)[2:end])
dfSeasonDummies = [airlinedates dfSeasonDummies]
rename!(dfSeasonDummies, :x1 => :month)
dfSeasonDummies.nPass = Int.(airlinevect)
dfSeasonDummies = dfSeasonDummies[!,[1,14,2,3,4,5,6,7,8,9,10,11,12,13]]

# Make table with data
latex_tabular(figFolder*"airlinedummytable.tex",
    Tabular("l|lllllllllllll"),
    [Rule(:top),
    ["Year";"nPass";names(airline)[2:end]],
    Rule(),           
    string.(Matrix(dfSeasonDummies[1:14,:])),
    repeat(["\\vdots"],13),
    string.(Matrix(dfSeasonDummies[143:144,:])),
    Rule(:bottom)]
)
dfSeasonDummies.time = 1:n

# Linear trend model:
fit = lm(@formula(nPass ~ time + Jan + Feb + Mar + Apr + May + Jun + Jul + Aug + Sep + Oct + Nov), dfSeasonDummies)
β = coef(fit)
yBar = mean(dfSeasonDummies.nPass)
tBar = mean(1:n)
a = β[1]
b = β[2]
a₀ = yBar - b*tBar
S = zeros(12)
for season = 1:11
    S[season] = a + β[2+season] - a₀ 
end
S[12] = a - a₀
bar(["Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct", "Nov", "Dec"], S, lw = 0, ylab = "Additive seasonal factor", title = "Regression with additive seasonal dummies",)
savefig(figFolder*"airlineAdditiveRegrSeasonalFactors.pdf")

seasonFit = repeat(S, Int(n/season))
plot(dfSeasonDummies.nPass, label = "data", xlab = "month (t)", ylab = "number of passengers", legend = :topleft)
plot!(a₀ .+ β[2]*(1:n), color = colors[4], label = "linear trend")
plot!(a₀ .+ β[2]*(1:n) .+ seasonFit, color = colors[1], label = "linear trend + seasonal")
savefig(figFolder*"airlineRegrSeasonalFactorsFit.pdf")

# Quadratic trend model:
fit = lm(@formula(nPass ~ time + time^2 + Jan + Feb + Mar + Apr + May + Jun + Jul + Aug + Sep + Oct + Nov), dfSeasonDummies)
β = coef(fit)
yBar = mean(dfSeasonDummies.nPass)
tBar = mean(1:n)
t2Bar = mean((1:n).^2)
a = β[1]
b₁ = β[2]
b₂ = β[3]
a₀ = yBar - b₁*tBar - b₂*t2Bar
S = zeros(12)
for season = 1:11
    S[season] = a + β[3+season] - a₀ 
end
S[12] = a - a₀
bar(["Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct", "Nov", "Dec"], S, lw = 0, ylab = "Additive seasonal factor", title = "Regression seasonal dummies - quadratic trend",)
savefig(figFolder*"airlineAdditiveRegrSeasonalFactorsQuad.pdf")

seasonFit = repeat(S, Int(n/season))
plot(dfSeasonDummies.nPass, label = "data", xlab = "month (t)", ylab = "number of passengers", legend = :topleft)
plot!(a₀ .+ b₁*(1:n) + b₂*((1:n).^2), color = colors[4], label = "quadratic trend")
plot!(a₀ .+ b₁*(1:n) + b₂*((1:n).^2) .+ seasonFit, color = colors[1], label = "quadratic trend + seasonal")
savefig(figFolder*"airlineRegrSeasonalFactorsFitQuad.pdf")


#regtable(fit; renderSettings = latexOutput(figFolder*"airlinedummyreg.tex"))


# bikeShare
bikeDay = DataFrame(CSV.File(dataFolder*"bikeDayDummy.csv"))
