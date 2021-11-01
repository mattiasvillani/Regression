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


# MOVIES
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


# BIKE SHARE DATA
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


# Adding regression line to scatter plot nRides vs temp with coeff
scatter(bikeDay[!,:temp],bikeDay[!,:nRides], xlabel = "temperatur (normaliserad)", 
    ylabel  = "antal uthyrningar", color = colors[1], title = L"\mathrm{regressionslinje:\ }y = a + b \cdot x = 1215 + 6641 \cdot x", titlefontsize=14, xticks = 0:0.1:1)
fit = lm(@formula(nRides ~ temp), bikeDay)
βhat = coef(fit)
Plots.abline!(βhat[2], βhat[1], color = colors[4], lw = 3)

# Text for intercept
annotate!([(0.04, βhat[1]*1.03, (L"\mathbf{a = 1215}", 10, :left, colors[8]))])
savefig(figFolder*"cykel_rides_vs_temp_Line_Coeff1.pdf")


# Text for slope
plot!([0.5,0.6],[βhat[1]+βhat[2]*0.5, βhat[1]+βhat[2]*0.5], color = colors[8])
plot!([0.6,0.6],[βhat[1]+βhat[2]*0.5, βhat[1]+βhat[2]*0.6], color = colors[8])
annotate!([(0.55, βhat[1]+βhat[2]*0.45, (L"\mathbf{\Delta x}", 12, :left, colors[8]))])
annotate!([(0.62, βhat[1]+βhat[2]*0.55, (L"\mathbf{\Delta y}", 12, :left, colors[8]))])
annotate!([(0.42, 5800, (L"b = \mathbf{\frac{\Delta y}{\Delta x}}", 12, :left, colors[8]))])
savefig(figFolder*"cykel_rides_vs_temp_Line_Coeff2.pdf")


scatter(bikeDay[!,:temp],bikeDay[!,:nRides], xlabel = "temperatur (normaliserad)", 
    ylabel  = "antal uthyrningar", color = colors[1], title = L"\mathrm{regressionslinje:\ }y = a + b \cdot x = 1215 + 6641 \cdot x", titlefontsize=14, xticks = 0:0.1:1, xlims = [0,1])
fit = lm(@formula(nRides ~ temp), bikeDay)
βhat = coef(fit)
Plots.abline!(βhat[2], βhat[1], color = colors[4], lw = 3)

plot!([0.5,0.5],[0, βhat[1]+βhat[2]*0.5], color = colors[8], linestyle = :dash, lw = 1)
plot!([0.6,0.6],[0, βhat[1]+βhat[2]*0.6], color = colors[8], linestyle = :dash, lw = 1)
plot!([0.0,0.5],[βhat[1]+βhat[2]*0.5, βhat[1]+βhat[2]*0.5], color = colors[8], linestyle = :dash, lw = 1)
plot!([0.0,0.6],[βhat[1]+βhat[2]*0.6, βhat[1]+βhat[2]*0.6], color = colors[8], linestyle = :dash, lw = 1)
annotate!([(0.52, 500, (L"\mathbf{\Delta x}", 12, :left, colors[8]))])
annotate!([(0.52, 1000, (L"\mathbf{\longrightarrow}", 12, :left, colors[8]))])
annotate!([(0.05, βhat[1]+βhat[2]*0.55, (L"\mathbf{\Delta y \uparrow}", 12, :left, colors[8]))])
savefig(figFolder*"cykel_rides_vs_temp_Line_Coeff3.pdf")


# Text for computing slope
plot!(Shape([0.22, 0.8, 0.8, 0.22], [6000, 6000, 8000, 8000]), opacity=1, linecolor = :gray, fillcolor = :white)
annotate!([(0.25, 7000, (L"b = \mathbf{\frac{\Delta y}{\Delta x} = \frac{5199-4535}{0.6-0.5}=6641}", 12, :left, colors[8]))])
savefig(figFolder*"cykel_rides_vs_temp_Line_Coeff4.pdf")


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


# RIKSBANK REPO
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


# EBAY COINS
gr(legend = nothing, grid = false, color = colors[2], lw = 2, legendfontsize=10,
    xtickfontsize=10, ytickfontsize=10, xguidefontsize=10, yguidefontsize=10, 
    markersize = 2, markerstrokecolor = :auto)
coins = DataFrame(CSV.File(dataFolder*"eBayDataUCI.csv"; header = true))

scatter(coins.BookVal, coins.FinalPrice, xlab = "bokvärde", ylab = "slutpris", xlims = [0,200])
savefig(figFolder*"ebaycoins_bookval_price.pdf")

scatter(coins.BookVal, coins.FinalPrice, xscale = :log, yscale = :log, xlab = "bokvärde (logskala)", ylab = "slutpris (logskala)")
savefig(figFolder*"ebaycoins_bookval_price_logskala.pdf")


scatter(coins.ReservePriceFrac, coins.NBidders, xlab = "Reservationspris/bokvärde", 
    ylab ="antal budgivare")
savefig(figFolder*"ebaycoins_bidders_minbidshare.pdf")


