# Code for plots of Lecture 8 in Regression and Time Series Analysis course
# Plot titles and legends in Swedish

using Plots, LaTeXStrings, CSV, DataFrames, GLM, LinearAlgebra, Dates, StatsPlots, Dates
using StatsBase, RCall, Statistics, Distributions, LaTeXTabulars, Utils
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


# OMITTED VARIABLE BIAS
healthdata = DataFrame(CSV.File(download("https://github.com/mattiasvillani/Regression/raw/master/Data/healthdata.csv");header=true));
x = healthdata.spending

# Simulate regression lines from the sampling distribution
function simReg(X, β, σ)
    n = size(X,1)
    ε = rand(Normal(0,σ), n)
    y = X*β + ε
    return y
end

n = 100
σ1 = 1
σ2 = 1
ρ = 0.7
Σ = [σ1^2 σ1*σ2*ρ; σ1*σ2*ρ σ2^2];
X = rand(MvNormal([0,0], Σ), n)';
X = [ones(n,1) X];
β = [1,1,1];
σₑ = 1
covβhat = (σₑ^2)*inv(X'*X)
theoreticalDist = Normal(β[2],√covβhat[2,2])

nRep = 500
βdraws = zeros(nRep,2) 
@gif for i in 1:nRep
    y = simReg(X, β, σₑ)
    df = DataFrame(y = y, x1 = X[:,2], x2 = X[:,3])
    fit = lm(@formula(y ~ x1), df)
    βhat = coef(fit)
    p1 = plot(xlims = (-3,3), ylims = (-5,5), xlab =L"x", ylab = L"y", 
        title = "Sample no. $i")
    scatter!(X[:,2], y, label = L"\mathrm{sample\ data}", color = colors[1])
    Plots.abline!(p1, β[2], β[1], color = colors[4], lw = 3, 
        label = L"\mathrm{population:\ } \alpha+\beta_1 x_1 + \beta_2 x_2")
    Plots.abline!(p1, βhat[2], βhat[1], color = colors[2], lw = 2, 
        label = L"\mathrm{least\ squares\ fit:\ } a+b_1 x_1")
    annotate!([(-2.5, 3.5, (L"\alpha = %$(round(β[1],digits = 2))\mathrm{\ and\ } \beta_1 = %$(round(β[2],digits = 2))", 12, :left, colors[4]))])
    annotate!([(-2.5, 3, (L"a = %$(round(βhat[1],digits = 2))\mathrm{\ and\ } b_1 = %$(round(βhat[2],digits = 2))", 12, :left, colors[2]))])
    ylims!((-5,5))
    xlims!((-3,3))

    βdraws[i,:] = βhat
    p2 = density(βdraws[1:i,2], linecolor = colors[2], fill=(0, .5, colors[1]), 
        title = L"\mathrm{Sampling\ distribution\ for\ b} - \mathrm{corr}(x_1,x_2) = %$ρ", label = "simulated fitted without x2", legend = :topleft, xlab = L"b_1")
    plot!(p2, theoreticalDist, color = colors[4], label = "theoretical fitted with both x1 and x2")
    scatter!(p2, βdraws[1:i,2], zeros(i), color = colors[2], label = "estimates")
    ylims!((0,4))
    xlims!((0,2))
    plot(size = (1000,1000), p1, p2, layout = (2,1))
    sleep(0.1)
end every 1


# Sthlm pollution
pm25 = DataFrame(CSV.File(dataFolder*"PM25.csv"; header = true))
pm25 = pm25[66513:end,:]
pm25.datetime = DateTime.(pm25.Datum, pm25.Kl)

plot(pm25.datetime, log.(pm25.Hornsgatan .+ 10), label = "PM2.5", legend = :topright, xlabel = "tid", ylab = "log PM2.5", title = "Hornsgatan - varje timme")
savefig(figFolder*"pm25timme.pdf")

plot(pm25.datetime[1:24:end], log.(pm25.Hornsgatan[1:24:end] .+ 10), label = "PM2.5", legend = :topright, xlabel = "tid", ylab = "log PM2.5", title = "Hornsgatan - varje dag")
savefig(figFolder*"pm25dag.pdf")

plot(pm25.datetime[1:(24*7):end], log.(pm25.Hornsgatan[1:(24*7):end] .+ 10), label = "PM2.5", legend = :topright, xlabel = "tid", ylab = "log PM2.5", title = "Hornsgatan - varje vecka")
savefig(figFolder*"pm25vecka.pdf")

gr(legendfontsize=10)
labels = ["onsdag", "torsdag", "fredag", "lördag"]
p = plot(legend = :topright)
for i = 1:4
    plot!(p, 0:23, log.(pm25.Hornsgatan[(99352+24*(i-1)):(99351+24*i)] .+ 10), label = labels[i], xlabel = "tid på dagen", ylab = "log PM2.5", title = "Hornsgatan - dec 4-7, 2019", 
    c = colors[i])
end
p
savefig(figFolder*"pm25_dagar_dec2019.pdf")

# SP500
sp500 = DataFrame(CSV.File(dataFolder*"SP500.csv"; missingstrings=["."], header = true))
dropmissing!(sp500)
dates = sp500.DATE
sp500 = sp500.SP500
returns = 100*(log.(sp500) - log.(lag(sp500,1))) 
returns = returns[2:end]
dates = dates[2:end]
plot(dates, returns, xlab = "day", ylab = "daily returns (%)", xtickfontsize=10, ytickfontsize=10, label = "SP500", legend = :topleft, lw = 1)
savefig(figFolder*"sp500.pdf")

# Global temperatures
tempanomaly = DataFrame(CSV.File(dataFolder*"globaltemp.csv"; header = true))
plot(tempanomaly.Year, tempanomaly.temp, title = "global temperature relative mean over 1951-1980 ", ylab = "global temperature anomaly (C)", xlab = "year", legend = :topleft, c = colors[6], label = "global temp anomaly")
savefig(figFolder*"globaltempanomaly.pdf")

# exponential trend
tempanomaly.logtemp = log.(tempanomaly.temp .+ 1)
fit = lm(@formula(logtemp ~ Year), tempanomaly)
βtilde = coef(fit)
β = exp.(βtilde)
yTildePred = predict(fit, tempanomaly)
plot!(tempanomaly.Year, exp.(yTildePred) .-1 , c = colors[5], label = "exponential growth fit")
savefig(figFolder*"globaltempanomalyExpTrend.pdf")

# Time series decomp
nYears = 50
time = 1:(nYears*4)
a = 2
b = 0.1
T = a .+ b*time;

# Additive
S = repeat(3*[0,-0.2,0.1,1], nYears);
C = 5*sin.(0.05*time)
E = 1*randn(nYears*4)
y = T + C + S + E
plot(time, T, label = L"T", c = colors[8], lw = 2, xlab = "tid", ylab = "komponenter", title= L"\mathrm{additiv\ modell\ } Y = T + C + S + E")
plot!(time, T + C, label = L"T+C", c = colors[4])
plot!(time, T + C + S, label = L"T+C+S", c = colors[6])
plot!(time, T + C + S + E, label = L"T+C+S+E", c = colors[1], lw = 1)
savefig(figFolder*"additiv_komp_uppdelning.pdf")

# Multiplicative
S = repeat([1,0.98,1.01,1.1], nYears);
C = 1 .+ 0.3*sin.(0.05*time)
E = exp.(0.1*randn(nYears*4))
y = T.*C.*S.*E
plot(time, T, label = L"T", c = colors[8], lw = 2, xlab = "tid", ylab = "komponenter", title = L"\mathrm{multiplikativ\ modell\ } Y = T \cdot C \cdot S \cdot E")
plot!(time, T.*C, label = L"T \cdot C", c = colors[4])
plot!(time, T.*C.*S, label = L"T \cdot C \cdot S", c = colors[6])
plot!(time, T.*C.*S.*E, label = L"T \cdot C \cdot S \cdot E", c = colors[1], lw = 1)
savefig(figFolder*"multiplikativ_komp_uppdelning.pdf")

# Air passenger
airline = DataFrame(CSV.File(dataFolder*"airpassenger.csv"; header = true))
airlineMat = Matrix(airline[!,2:end])
n = length(1949:1960)*12
airlinevect = zeros(n)
for year = 1:12
    airlinevect[1+(year-1)*12: 12*year] = airlineMat[year,:]
end
df = DataFrame(:passengers => airlinevect, :time => 1:n)
df.logpassengers = log10.(df.passengers)
plot(airlinevect, label = "data", xlab = "month (t)", ylab = "number of passengers")
savefig(figFolder*"airline.pdf")

# Make table with data
latex_tabular(figFolder*"airlinetable.tex",
    Tabular("l|llllllllllll"),
    [Rule(:top),
    ["Year";names(airline)[2:end]],
    Rule(),           
    Matrix(airline[1:5,1:end]),
    repeat(["\\vdots"],13),
    airline[end,1:end],
    Rule(:bottom)]
)

# Linjär trend
plot(airlinevect, label = "data", xlab = "month (t)", ylab = "number of passengers")
fit = lm(@formula(passengers ~ time), df)
β = coef(fit)
passPred = predict(fit)
plot!(df.time, passPred, color = colors[4], label = "linear trend fit")
annotate!([(10, 500, (L"y = %$(round(β[1],digits = 3)) + %$(round(β[2],digits = 3)) \cdot t", 14, :left, colors[4]))])
savefig(figFolder*"airlineLinearTrend.pdf")

# Quadratic trend
plot(airlinevect, label = "data", xlab = "month (t)", ylab = "number of passengers")
fit = lm(@formula(passengers ~ time + time^2), df)
β = coef(fit)
passPred = predict(fit)
plot!(df.time, passPred, color = colors[4], label = "quadratic trend fit")
annotate!([(10, 500, (L"y = %$(round(β[1],digits = 3)) + %$(round(β[2],digits = 3)) \cdot t + %$(round(β[3],digits = 3)) \cdot t^2", 14, :left, colors[4]))])
savefig(figFolder*"airlineQuadTrend.pdf")

# Exponentiell trend
plot(airlinevect, label = "data", xlab = "month (t)", ylab = "number of passengers")
df = DataFrame(:passengers => airlinevect, :time => 1:n)
df.logpassengers = log10.(df.passengers)
fit = lm(@formula(logpassengers ~ time), df)
passPred = 10 .^ (predict(fit))
βtilde = coef(fit)
β = 10 .^ (βtilde)
plot!(df.time, passPred, color = colors[4], label = "exponential trend fit")
annotate!([(30, 500, (L"y = %$(round(β[1],digits = 3)) \cdot %$(round(β[2],digits = 3))^t", 14, :left, colors[4]))])
savefig(figFolder*"airlineExpTrend.pdf")

# Moving average
function movingaverage(x, w)
    n = length(x)
    if length(w) == 1
        w = (1/w)*ones(w)
    end
    nwindow = length(w)
    if iseven(nwindow) 
        error("only odd window length supported")
    end
    nside = floor(Int,nwindow/2)
    movavg = Vector{Union{Missing,Float64}}(missing,n)
    for t = (nside+1):(n-nside)
        movavg[t] = sum(w.*x[t-nside:t+nside])
    end
    return movavg
end

function movingaveragemonthly(x)
    n = length(x)
    w = (2/24)*ones(13)
    w[1] = w[end] = 1/24
    nwindow = length(w)
    nside = floor(Int,nwindow/2)
    movavg = Vector{Union{Missing,Float64}}(missing,n)
    for t = (nside+1):(n-nside)
        movavg[t] = sum(w.*x[t-nside:t+nside])
    end
    return movavg
end

# Airline passenger additive decomp
n = length(airlinevect)
airlinedates = Vector{Date}(undef,length(airlinevect));
t = 0;
for y = 1949:1960
    for m = 1:12
        t = t + 1
        airlinedates[t]  = Date(string(y)*"-"*string(m), "yyyy-mm")
    end
end
airTable = DataFrame()
airTable.dates = airlinedates
airTable.nPassengers = Int.(airlinevect)
#airTable.trend = round.(movingaverage(airTable.nPassengers, 5), digits = 3)
airTable.trend = round.(movingaveragemonthly(airTable.nPassengers), digits = 3)
season = 12
yNoTrend = airlinevect - airTable.trend
airTable.GrovSasong = round.(yNoTrend, digits = 3)
sBar = zeros(season)
for s = 1:season # the first period in the data is labelled season 1
    sBar[s] = mean(skipmissing(yNoTrend[s:season:end]))
end
sPlus = round.(sBar .- mean(sBar), digits = 3)
airTable.sasong = repeat(sPlus, Int(n/season))
airTable.sasongsrensad = round.(airTable.nPassengers - airTable.sasong, digits = 3)
airTable.sasong = pad_digits(airTable.sasong)
airTable.sasongsrensad = pad_digits(airTable.sasongsrensad)

bluelatex = "\\cellcolor{blue}"
lbluelatex = "\\cellcolor{lblue}"
orange = "\\cellcolor{orange}"
lorange = "\\cellcolor{lorange}"

strMat1 = string.(Matrix(airTable[1:29,1:end]))
strMat1[3:15,2] .= lorange.*strMat1[3:15,2]
strMat1[9,3] = orange*strMat1[9,3]
offset = 14
strMat1[(3:15) .+ offset,2] .= lorange.*strMat1[(3:15) .+ offset,2]
strMat1[9 + offset,3] = orange*strMat1[9 + offset,3]
strMat1[7:12:27,4] .= lbluelatex.*strMat1[7:12:27,4]
strMat1[7:12:27,5] .= bluelatex.*strMat1[7:12:27,5]
strMat1[strMat1 .== "missing"] .= "\$ \\cdot \$"
# Make table with additive decomp data
latex_tabular(figFolder*"airlinetable_add_decomp.tex",
    Tabular("l|rrrrr"),
    [Rule(:top),
    [" ";
    "\\multicolumn{1}{c}{tidsserie}";
    "\\multicolumn{1}{c}{trend}";
    "\\multicolumn{1}{c}{grov säsong}";
    "\\multicolumn{1}{c}{säsong}";
    "\\multicolumn{1}{c}{säsongsjust.}"],
    ["\\multicolumn{1}{c}{månad}";
    "\\multicolumn{1}{c}{\$y_t\$}";
    "\\multicolumn{1}{c}{\$ \\hat{T}_t\$}";
    "\\multicolumn{1}{c}{\$ y_t - \\hat{T}_t\$}";
    "\\multicolumn{1}{c}{\$ S^{+} \$}";
    "\\multicolumn{1}{c}{\$ y_t - S^{+} \$}"],
    Rule(),           
    strMat1,
    repeat(["\\vdots"],6),
    #string.(Vector(airTable[end,1:end])),
    Rule(:bottom)]
)


# Global temperatures
tempanomaly = DataFrame(CSV.File(dataFolder*"globaltemp.csv"; header = true))
plot(tempanomaly.Year, tempanomaly.temp, title = "global temperature relative mean over 1951-1980 ", ylab = "global temperature anomaly (C)", xlab = "year", legend = :topleft, c = colors[1], label = L"\mathrm{global\ temp\ anomaly}")
tempanomalyMA5 = movingaverage(tempanomaly.temp,5)
tempanomalyMA11 = movingaverage(tempanomaly.temp,11)
plot!(tempanomaly.Year, tempanomalyMA5, c = colors[2], label = L"5\mathrm{-point\ moving\ average}")
plot!(tempanomaly.Year, tempanomalyMA11, c = colors[4], label = L"11\mathrm{-point\ moving\ average}")
savefig(figFolder*"globaltempanomaly_MA.pdf")

# Equal weights   
MApass3 = movingaverage(df.passengers,3)
MApass5 = movingaverage(df.passengers,5)
plot(df.passengers, c = colors[2], label = L"\mathrm{original\ series}", legend = :topleft, legendfontsize = 10, xlab = "month (t)", ylab = "number of passengers")
plot!(MApass3, c = colors[1], label = L"3\mathrm{-point\ moving\ average}")
plot!(MApass5, c = colors[4], label = L"5\mathrm{-point\ moving\ average}")
savefig(figFolder*"airline_MA.pdf")

# Seasonal MA weights
w = [1,2,2,2,2,2,2,2,2,2,2,2,1]/24
MApassMonth = movingaverage(df.passengers, w)
plot(df.passengers, c = colors[1], label = L"\mathrm{original\ series}", legend = :topleft, legendfontsize = 10, xlab = "month (t)", ylab = "number of passengers")
plot!(df.time, passPred, color = colors[4], label = L"\mathrm{exponential\ trend\ fit}")
plot!(MApassMonth, c = colors[2], label = L"\mathrm{seasonal\ moving\ average}, M_t^{(13)}")
savefig(figFolder*"airline_MAseasonal.pdf")

# Seasonal decomp airline data - additive
MAorder = 5
season = 12
y = airlinevect
T = movingaveragemonthly(y)
yNoTrend = y - T
sBar = zeros(season)
for s = 1:season # the first period in the data is labelled season 1
    sBar[s] = mean(skipmissing(yNoTrend[s:season:end]))
end
sPlus = sBar .- mean(sBar)
bar(["Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct", "Nov", "Dec"], sPlus, lw = 0, ylab = "Additive seasonal factor", title = "additive model", label = "")
savefig(figFolder*"airlineAdditiveSeasonalFactors.pdf")

seasonFit = repeat(sPlus, Int(length(y)/season))
TrendFit = T #movingaverage(y - seasonFit, MAorder)
plot(airlinevect, label = "data", xlab = "month (t)", ylab = "number of passengers", 
    title = "additive model", legend = :topleft )
plot!(TrendFit, color = colors[1], label = "trend fit")
plot!(TrendFit + seasonFit, color = colors[4], label = "trendfit + seasonfit")
savefig(figFolder*"airline_component_additive_fit.pdf")

# Seasonal decomp airline data - multiplicative
MAorder = 5
season = 12
y = log10.(airlinevect)
T = movingaveragemonthly(y)
yNoTrend = y - T
sBar = zeros(season)
for s = 1:season # the first period in the data is labelled season 1
    sBar[s] = mean(skipmissing(yNoTrend[s:season:end]))
end
sPlus = sBar .- mean(sBar)
hline([1], color = colors[1], label = "")
bar!(["Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct", "Nov", "Dec"], 
    10 .^ sPlus, lw = 0, ylab = "Multiplicative seasonal factor", title = "multiplicative model", label = "")
ylims!((0.8,1.15))
savefig(figFolder*"airlineSeasonalFactors.pdf")

seasonFit = repeat(sPlus, Int(length(y)/season))
TrendFit = T #movingaverage(y - seasonFit, MAorder)
plot(airlinevect, label = "data", xlab = "month (t)", ylab = "number of passengers", 
    title = "multiplicative model", legend = :topleft )
plot!(10 .^ TrendFit, color = colors[1], label = "trend fit")
plot!(10 .^ (TrendFit + seasonFit), color = colors[4], label = "trendfit + seasonfit")
savefig(figFolder*"airline_component_fit.pdf")

# Stockholm monthly temp - NOT USED CURRENTLY
sthlmtemp = DataFrame(CSV.File(dataFolder*"sthlmMonthlyTemp.csv"; header = true))
sthlmtempvec = Matrix(sthlmtemp[!,2:13])'[:]
sthlmtempvec = sthlmtempvec'
sthlmdates = Vector{Date}(undef,length(sthlmtempvec));
t = 0;
for y = 1756:2019
    for m = 1:12
        t = t + 1
        sthlmdates[t]  = Date(string(y)*"-"*string(m), "yyyy-mm")
    end
end
