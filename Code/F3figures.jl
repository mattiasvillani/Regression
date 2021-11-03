# Code for plots of Lecture 3 in Regression and Time Series Analysis courseFolder
# Plot titles and legends in Swedish

using Plots, LaTeXStrings, CSV, DataFrames, GLM, LinearAlgebra, Dates, StatsPlots
using StatsBase, RCall, Statistics, Distributions
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


gr(legend = :bottomright, titlefontsize = 12)

# Load data
healthdata = DataFrame(CSV.File(download("https://github.com/mattiasvillani/Regression/raw/master/Data/healthdata.csv");header=true));
x = healthdata.spending

# Simulate regression lines from the sampling distribution
function simSimpleReg(x, β₀, β₁, σ)
    n = length(x)
    ε = rand(Normal(0,σ), n)
    y = β₀ .+ β₁*x + ε
    return y
end

β₀ = 77
β₁ = 1
σ = 3
theoreticalDist = Normal(β₁, σ/√(sum((x .- mean(x)).^2)))
nRep = 500
βdraws = zeros(nRep,2)
@gif for i in 1:nRep
    y = simSimpleReg(x, β₀, β₁, σ)
    df = DataFrame(y = y, x = x)
    fit = lm(@formula(y ~ x), df)
    βhat = coef(fit)
    p1 = plot(xlims = (0,8), ylims = (74,90), xlab =L"x", ylab = L"y", 
        title = "Stickprov nummer nr $i")
    scatter!(x, y, label = L"\mathrm{sample\ data}", color = colors[1])
    Plots.abline!(p1, β₁, β₀, color = colors[4], lw = 3, 
        label = L"\mathrm{population:\ } \alpha+\beta x")
    Plots.abline!(p1, βhat[2], βhat[1], color = colors[2], lw = 2, 
        label = L"\mathrm{least\ squares\ fit:\ } a+b x")
    annotate!([(1.5, 89.5, (L"\alpha = %$(round(β₀,digits = 2))\mathrm{\ and\ } \beta = %$(round(β₁,digits = 2))", 12, :top, colors[4]))])
    annotate!([(1.5, 88, (L"a = %$(round(βhat[1],digits = 2))\mathrm{\ and\ } b = %$(round(βhat[2],digits = 2))", 12, :top, colors[2]))])
    ylims!((70,90))
    xlims!((0,8))

    βdraws[i,:] = βhat
    p2 = density(βdraws[1:i,2], linecolor = colors[2], fill=(0, .5, colors[1]), 
        title = "Samplingfördelningen för b", label = "Simulerad", legend = :topleft)
    scatter!(p2, βdraws[1:i,2], zeros(i), color = colors[2], label = nothing)
    #vline!([β₁], color = colors[10], linestyle = :dash)
    plot!(p2, theoreticalDist, color = colors[4], label = "Teoretisk")
    ylims!((0,2))
    xlims!((-1,2.5))

    plot(size = (1000,1000), p1, p2, layout = (2,1))
    #display()
    #sleep(1)
    sleep(0.1)
end every 1


β₀ = 77
β₁ = 1
σ = 3
nRep = 100
βdraws = zeros(nRep,2)
theoreticalDist = Normal(β₁, σ/√(sum((x .- mean(x)).^2)))
for i = 1:nRep
    y = simSimpleReg(x, β₀, β₁, σ)
    df = DataFrame(y = y, x = x)
    fit = lm(@formula(y ~ x), df)
    βhat = coef(fit)
    βdraws[i,:] = βhat
    p = density(βdraws[1:i,2], linecolor = colors[2], fill=(0, .5, colors[1]), 
        title = "Samplingfördelning för b", label = "Simulerad", legend = :topleft)
    scatter!(βdraws[1:i,2], zeros(i), color = colors[2], label = nothing)
    #vline!([β₁], color = colors[10], linestyle = :dash)
    plot!(theoreticalDist, color = colors[4], label = "Teoretisk")
    display(p)
    sleep(0.1)
end



# Regression as a conditional distribution
gr(legend = :topleft)
p = plot(xlab = L"\mathrm{temperatur\ }(x)", ylab = L"\mathrm{antal\ uhyrningar\ }(y)")
b = 6640
a = 1215
sigmaEps = 600
Plots.abline!(b, a, color = colors[4], label = L"\mu_{y \vert x}=\alpha + \beta x", lw = 2)
xPoints = [0.25,0.5,0.75]
for x in xPoints
    μ = a + b*x
    maxpdf = maximum(pdf(distr, yGrid))
    distr = Normal(μ, sigmaEps)
    quant1 = quantile(distr, 0.01)
    quant2 = quantile(distr, 0.99)
    yGrid = quant1:quant2
    tmp = x .+ 0.2*pdf(distr, yGrid)/maxpdf
    plot!(tmp, yGrid, label = nothing)
    plot!([x,maximum(tmp)],[μ,μ], color = colors[1], linestyle = :dash, 
        label = nothing, lw = 1)
    annotate!([(x+0.02, μ+600, (L"\mu_{y\vert x=%$(round(x,digits = 2))}", 12, :right, :black))])
    plot!([x-0.05, x], [μ + 300, μ], arrow=true, lw = 1, c = :gray, label = nothing)
    plot!([x+0.05,x+0.05],[μ-1.5*sigmaEps,μ-0.1*sigmaEps], arrow = arrow(:both), lw = 1, c = :gray, label = nothing)
    annotate!([(x+0.11, μ-0.75*sigmaEps, (L"\sigma_{\varepsilon}", 12, :right, :black))])
end
p
savefig(figFolder*"regdensities.pdf")