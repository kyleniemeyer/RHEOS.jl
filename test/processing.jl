function _resample_strainonly()
    t0 = collect(0.0:0.01:1.0)
    ϵ0 = t0.^2

    t1 = collect(0.0:0.1:1.0)
    ϵ1 = t1.^2

    data0 = RheoTimeData(t = t0, ϵ = ϵ0)
    
    dataout = resample(data0, -10)

    dataout.t==t1 && dataout.ϵ==ϵ1 
end
@test _resample_strainonly()

function _resample_stressonly()
    t0 = collect(0.0:0.01:1.0)
    σ0 = t0.^2

    t1 = collect(0.0:0.1:1.0)
    σ1 = t1.^2

    data0 = RheoTimeData(t = t0, σ = σ0)
    
    dataout = resample(data0, -10)

    dataout.t==t1 && dataout.σ==σ1 
end
@test _resample_stressonly()

function _resample_stressandstrain()
    t0 = collect(0.0:0.01:1.0)
    ϵ0 = t0.^2
    σ0 = t0.^3

    t1 = collect(0.0:0.1:1.0)
    ϵ1 = t1.^2
    σ1 = t1.^3

    data0 = RheoTimeData(t = t0, σ = σ0, ϵ = ϵ0)
    
    dataout = resample(data0, -10)

    dataout.t==t1 && dataout.ϵ==ϵ1 && dataout.σ==σ1 
end
@test _resample_stressandstrain()

function _resample_stressandstrain_multiplesections()
    t0 = collect(-10.0:0.5:10.0)
    ϵ0 = 2*t0
    σ0 = 2*t0

    # data for comparison composed
    # of multiple sections
    t1a = collect(-10.0:0.1:-5.1)
    t1b = collect(-5.0:1.0:0.0)
    t1c = collect(0.05:0.05:4.95)
    t1d = collect(5.0:2.0:10.0)
    t1e = [t0[end]]

    t1 = vcat(t1a, t1b, t1c, t1d, t1e)
    ϵ1 = 2*t1
    σ1 = 2*t1

    data0 = RheoTimeData(t = t0, σ = σ0, ϵ = ϵ0)
    
    dataout = resample(data0, [5, -2, 10, -4]; time_boundaries = [-10.0, -5.0, 0.0, 5.0, 10.0])

    dataout.t==t1 && dataout.ϵ==ϵ1 && dataout.σ==σ1 
end
@test _resample_stressandstrain_multiplesections()

function _cutting_strainonly()
    t0 = collect(0.0:1.0:5.0)
    ϵ0 = t0.^2

    t1 = collect(1.0:1.0:5.0)
    ϵ1 = t1.^2

    data0 = RheoTimeData(t = t0, ϵ = ϵ0)
    
    dataout = cutting(data0, 1.0, 5.0)

    dataout.t==t1 && dataout.ϵ==ϵ1 
end
@test _cutting_strainonly()

function _cutting_stressonly()
    t0 = collect(0.0:1.0:5.0)
    σ0 = t0.^2

    t1 = collect(1.0:1.0:5.0)
    σ1 = t1.^2

    data0 = RheoTimeData(t = t0, σ = σ0)
    
    dataout = cutting(data0, 1.0, 5.0)

    dataout.t==t1 && dataout.σ==σ1 
end
@test _cutting_stressonly()

function _cutting_stressandstrain()
    t0 = collect(0.0:1.0:5.0)
    ϵ0 = t0.^2
    σ0 = t0.^3

    t1 = collect(1.0:1.0:5.0)
    ϵ1 = t1.^2
    σ1 = t1.^3

    data0 = RheoTimeData(t = t0, σ = σ0, ϵ = ϵ0)
    
    dataout = cutting(data0, 1.0, 5.0)

    dataout.t==t1 && dataout.ϵ==ϵ1 && dataout.σ==σ1 
end
@test _cutting_stressandstrain()

function _smooth_stressonly()
    f = 1.0 # Hz
    ω = 2*π*f # rad/s
    t0 = collect(0.0:0.01:4/f)
    σ0 = sin.(ω*t0)

    data0 = RheoTimeData(t = t0, σ = σ0)

    dataout = smooth(data0, 1/f; pad="circular")

    all(i -> isapprox(0.5*data0.σ[i], dataout.σ[i], atol=0.1), eachindex(data0.σ))
end
@test _smooth_stressonly()

function _smooth_strainonly()
    f = 1.0 # Hz
    ω = 2*π*f # rad/s
    t0 = collect(0.0:0.01:4/f)
    ϵ0 = sin.(ω*t0)

    data0 = RheoTimeData(t = t0, ϵ = ϵ0)

    dataout = smooth(data0, 1/f; pad="circular")

    all(i -> isapprox(0.5*data0.ϵ[i], dataout.ϵ[i], atol=0.1), eachindex(data0.ϵ))
end
@test _smooth_strainonly()

function _smooth_stressandstrain()
    f = 1.0 # Hz
    ω = 2*π*f # rad/s
    t0 = collect(0.0:0.01:4/f)
    ϵ0 = sin.(ω*t0)
    σ0 = sin.(ω*t0)

    data0 = RheoTimeData(t = t0, ϵ = ϵ0, σ = σ0)

    dataout = smooth(data0, 1/f; pad="circular")

    test1 = all(i -> isapprox(0.5*data0.ϵ[i], dataout.ϵ[i], atol=0.1), eachindex(data0.ϵ))
    test2 = all(i -> isapprox(0.5*data0.σ[i], dataout.σ[i], atol=0.1), eachindex(data0.σ))

    test1 && test2
end
@test _smooth_stressandstrain()

# extract

