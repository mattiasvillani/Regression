# Code for plots of Lecture 1 in Regression and Time Series Analysis courseFolder
# Plot titles and legends in Swedish

using Plots, LaTeXStrings, CSV, DataFrames, GLM, LinearAlgebra, Dates
using StatsBase, RCall
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


# Reading bike share data from file    
bikeDay = DataFrame(CSV.File(dataFolder*"cykeluthyr.csv"; header = true))

# Scatter plot nRides vs temp
scatter(bikeDay[!,:temp],bikeDay[!,:nRides], xlabel = "temperatur (normaliserad)", 
    ylabel  = "antal uthyrningar")
savefig(figFolder*"cykel_rides_vs_temp.pdf")

# Adding regression line to scatter plot nRides vs temp
fit = lm(@formula(nRides ~ temp), bikeDay)
βhat = coef(fit)
Plots.abline!(βhat[2], βhat[1], color = colors[4], lw = 3)
savefig(figFolder*"cykel_rides_vs_temp_Line.pdf")

# Prediction for temp = 0.6
x = 0.6
yPred = [1 x]⋅βhat
plot!([0.6, 0.6], [0,yPred], linestyle  = :dot, color = colors[10])
plot!([0.0, 0.6], [yPred,yPred], linestyle  = :dot, color = colors[10])
savefig(figFolder*"cykel_rides_vs_temp_Pred.pdf")

# Scatter plot nRides vs hum
scatter(bikeDay[!,:hum],bikeDay[!,:nRides], xlabel = "luftfuktighet (normaliserad)", 
    ylabel  = "antal uthyrningar", color = colors[6])
savefig(figFolder*"cykel_rides_vs_hum.pdf")

# Scatter plot nRides vs windspeed
scatter(bikeDay[!,:windspeed],bikeDay[!,:nRides], xlabel = "vindhastighet (normaliserad)", 
    ylabel  = "antal uthyrningar", color = colors[10])
savefig(figFolder*"cykel_rides_vs_wind.pdf")

fit = lm(@formula(nRides ~ temp + hum), bikeDay)
βhat = coef(fit)
Plots.abline!(βhat[2], βhat[1], color = colors[4], lw = 3)

# Scatter plot nRides vs temp by season
scatter(bikeDay[bikeDay.season .== 1,:temp], bikeDay[bikeDay.season .== 1,:nRides], 
    xlabel = "temperatur (normaliserad)", ylabel  = "antal uthyrningar", 
    color = colors[1], label = "season = 1", legend = :topleft)
scatter!(bikeDay[bikeDay.season .== 2,:temp], bikeDay[bikeDay.season .== 2,:nRides], 
    color = colors[5], label = "season = 2")
scatter!(bikeDay[bikeDay.season .== 3,:temp], bikeDay[bikeDay.season .== 3,:nRides], 
    color = colors[4], label = "season = 3")
scatter!(bikeDay[bikeDay.season .== 4,:temp], bikeDay[bikeDay.season .== 4,:nRides], 
    color = colors[12], label = "season = 4")
savefig(figFolder*"cykel_rides_vs_temp_by_season.pdf")

# Time series plot of nRides
plot(bikeDay[!,:dteday], bikeDay[!,:nRides], lw = 1, xlab = "dag", ylab = "antal uthyrningar")
savefig(figFolder*"cykel_tidsserie.pdf")

# Scatterplot nRides vs lag of nRides
bikeDay.lag = [bikeDay[1, :nRides];bikeDay[1:(end-1), :nRides]]
scatter(bikeDay[!,:lag], bikeDay[!,:nRides], xlabel = "antal hyrningar igår", 
    ylabel  = "antal uthyrningar idag", color = colors[6])
savefig(figFolder*"cykel_rides_vs_lag.pdf")

# Scatterplot nRides vs lag of nRides by season
scatter(bikeDay[!,:lag], bikeDay[!,:nRides], xlabel = "antal hyrningar igår", 
    ylabel  = "antal uthyrningar idag", color = colors[1], legend = :topleft, label = "season = 1")
scatter!(bikeDay[bikeDay.season .== 1, :lag], bikeDay[bikeDay.season .== 2,:nRides], 
    color = colors[5], label = "season = 2")
scatter!(bikeDay[bikeDay.season .== 3,:lag], bikeDay[bikeDay.season .== 3,:nRides], 
    color = colors[4], label = "season = 3")
scatter!(bikeDay[bikeDay.season .== 4,:lag], bikeDay[bikeDay.season .== 4,:nRides], 
    color = colors[12], label = "season = 4")
savefig(figFolder*"cykel_rides_vs_lag_by_season.pdf")

# Time series plot - Inflation and repo rate
inflrepo = DataFrame(CSV.File(dataFolder*"InflationReporanta.csv"; header = true))
inflrepo.Datum = Date.(inflrepo.Datum,"mm/dd/yyyy")
inflrepo = inflrepo[37:end,:]
plot(inflrepo.Datum, inflrepo.KPIF, label = "Inflation", legend = :topright, xlabel = "månad")
plot!(inflrepo.Datum, inflrepo.repo, label = "Reporänta", color = colors[4])
savefig(figFolder*"inflrepo.pdf")

# Scatterplot Inflation vs fourth lag of repo rate
inflrepo.lag4 = [zeros(4);inflrepo.repo[1:(end-4)]]
scatter(inflrepo.lag4[5:end], inflrepo.KPIF[5:end], 
    xlabel = "reporänta fyra månader sen", ylabel = "inflation", markersize = 4)
fit = lm(@formula(KPIF ~ lag4), inflrepo)
βhat = coef(fit)
Plots.abline!(βhat[2], βhat[1], color = colors[4], lw = 3)
savefig(figFolder*"inflreposcatter.png")

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
    scatter!(eval(Meta.parse("anscombe.X"*i)), eval(Meta.parse("anscombe.Y"*i)), title = L"\hat\beta_0 = %$(round(βhat[1], digits = 2)), \hat\beta_1 = %$(round(βhat[2], digits = 2))")
end
plot(p..., layout = (2,2))
savefig(figFolder*"anscombeQuartet.pdf")

# Healthdata from 'Regression and Other Stories' book
healthdata = DataFrame(CSV.File(dataFolder*"healthdata.txt"; header = true))

# Scatter - no annotation
scatter(healthdata.spending, healthdata.lifespan, xlab = "Hälsobudget (US dollar, köpkraftsjusterad)", ylab = "Förväntad livslängd (år)")
savefig(figFolder*"healthdata.pdf")

# Scatter - with annotation
Plots.reset_defaults()
gr(legend = nothing, grid = false, color = colors[2], lw = 2, legendfontsize=8,
    xtickfontsize=6, ytickfontsize=6, xguidefontsize=8, yguidefontsize=8, 
    titlefontsize = 10, markersize = 3, markerstrokecolor = :auto)
scatter(healthdata.spending, healthdata.lifespan, series_annotations = text.(healthdata.country, :bottom, :darkslategrey, 4), xlab = "Hälsobudget (US dollar, köpkraftsjusterad)", ylab = "Förväntad livslängd (år)")
savefig(figFolder*"healthdata_text.pdf")

# Health data fit with and without the US
Plots.reset_defaults()
gr(legend = nothing, grid = false, color = colors[2], lw = 2, legendfontsize=8,
    xtickfontsize=6, ytickfontsize=6, xguidefontsize=8, yguidefontsize=8, 
    titlefontsize = 10, markersize = 3, markerstrokecolor = :auto)

plot(xlab = "Hälsobudget (US dollar, köpkraftsjusterad)", 
    ylab = "Förväntad livslängd (år)", label = nothing, legend = :topleft)

fit = lm(@formula(lifespan ~ spending), healthdata)
βhat = coef(fit)
Plots.abline!(βhat[2], βhat[1], color = colors[4], lw = 2, label ="med USA")
    
fit = lm(@formula(lifespan ~ spending), healthdata[Not(healthdata.country .== "USA"),:])
βhat = coef(fit)
Plots.abline!(βhat[2], βhat[1], color = colors[1], lw = 2, label ="utan USA")

scatter!(healthdata.spending, healthdata.lifespan, series_annotations = text.(healthdata.country, :bottom, :darkslategrey, 4), label = nothing)

savefig(figFolder*"healthdata_text_fit.pdf")

# O-rings data
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

# electric = DataFrame(CSV.File(dataFolder*"electricity.csv"; header = true))

movies = DataFrame(CSV.File(dataFolder*"movies_metadata.csv";header = true))
dropmissing!(movies)
select!(movies, Not(:belongs_to_collection))
select!(movies, Not(:homepage))
select!(movies, Not(:id))
select!(movies, Not(:imdb_id))
select!(movies, Not(:overview))
select!(movies, Not(:genres))
select!(movies, Not(:poster_path))
select!(movies, Not(:production_companies))
select!(movies, Not(:production_countries))
select!(movies, Not(:spoken_languages))
select!(movies, Not(:status))
select!(movies, Not(:tagline))
select!(movies, Not(:original_title))


movies = movies[movies.original_language .== "en",:]
movies.release_date = Date.(movies.release_date)
ms = movies[movies.release_date .> Date("2013-01-01"),:]
ms.budget = parse.(Float64, ms.budget)
ms.popularity = parse.(Float64, ms.popularity)

ms = ms[ms.budget .> 100000,:]
ms = ms[ms.vote_average .> 0,:]
ms = ms[ms.revenue .> 0,:]
ms.logrevenue = log10.(ms.revenue)
ms.logbudget = log10.(ms.budget)
ms.logpopularity = log10.(ms.popularity)

scatter(ms.logbudget, ms.logpopularity, ylab = "popularitet", 
    xlab ="budget i miljoner US dollar (log skala)")
fit = lm(@formula(logpopularity ~ logbudget), ms)
βhat = coef(fit)
Plots.abline!(βhat[2], βhat[1], color = colors[4], lw = 2)
bigbudget = ms.logbudget .> 8.42
scatter!(ms[bigbudget,:].logbudget, ms[bigbudget,:].logpopularity, 
    series_annotations = text.( ms[bigbudget,:title], :right, :black, 4 ))

lowbudget = ms.logbudget .< 6.73
scatter!(ms[lowbudget,:].logbudget, ms[lowbudget,:].logpopularity, 
    series_annotations = text.( ms[lowbudget,:title], :left, :black, 4 ))

highpop = ms.logpopularity .> 2.17
scatter!(ms[highpop,:].logbudget, ms[highpop,:].logpopularity, 
    series_annotations = text.( ms[highpop,:title], :right, :black, 4 ))
        
lowpop = ms.logpopularity .< 0.65
scatter!(ms[lowpop,:].logbudget, ms[lowpop,:].logpopularity, 
    series_annotations = text.( ms[lowpop,:title], :left, :black, 4 ))
          
savefig(figFolder*"movies_logpop_logbudget.pdf")
