function _RheoTimeData_explicit_nolog()
    a = Vector{RheoFloat}(1.0:1.0:3.0)
    b = Vector{RheoFloat}(4.0:1.0:6.0)
    c = Vector{RheoFloat}(7.0:1.0:9.0)

    data = RheoTimeData(a, b, c, nothing)

    data.σ==a && data.ϵ==b && data.t==c && isnothing(data.log)
end

function _operators_logs()
    d1=strainfunction(timeline(),t->exp(-t))
    d2=strainfunction(timeline(),t->1-exp(-t))
    d=2*d1 - (-d2) + d2

    d3=rheologrun(d.log)

    (d3.ϵ == d.ϵ) && all([ abs(e-2.)<=eps(RheoFloat) for e in d.ϵ ])
end
@test _operators_logs()

function _freeze_params()
    SLS2_mod = freeze_params( SLS2, (G₀=2,η₂=3.5))

    SLS2.G(1,[2,1,2,3,3.5])≈SLS2_mod.G(1,[1,2,3])
end
@test _freeze_params()