#!/usr/bin/env julia

#=
-----------------------
Preprocessing functions
-----------------------
=#
"""
    resample(self::RheoTimeData, elperiods::Union{Vector{K}, K}; time_boundaries::Union{Nothing, Vector{T}} = nothing)

Resample data with new sample rate(s).

Resample can downsample or upsample data. If the number of elperiods is negative it is going to reduce the number of samples,
viceversa if it is positive. If time boundaries are not specified, resampling is applied to the whole set of data.
If number of elements per period (elperiods) is 1 or -1 it returns the original RheoTimeData, whilst 0 is not accepted as a valid
argument for elperiods.
"""
function resample(self::RheoTimeData, elperiods::Union{Vector{K}, K}; time_boundaries::Union{Nothing, Vector{T}} = nothing) where {K<:Integer,T<:Real}

    @assert (count(iszero, elperiods)==0) "Number of elements cannot be zero"
    # convert boundaries from times to element indicies
    if isnothing(time_boundaries)
        boundaries = [1,length(self.t)];
    else
        boundaries = closestindices(self.t, time_boundaries)
    end

    check = RheoTimeDataType(self)
    if (check == strain_only)
        (time, epsilon) = fixed_resample(self.t, self.ϵ, boundaries, elperiods)
        sigma = [];
    elseif (check == stress_only)
        (time, sigma) = fixed_resample(self.t, self.σ, boundaries, elperiods)
        epsilon = [];
    elseif (check == strain_and_stress)
        (time, sigma) = fixed_resample(self.t, self.σ, boundaries, elperiods)
        (time, epsilon) = fixed_resample(self.t, self.ϵ, boundaries, elperiods)
    end

    log = self.log == nothing ? nothing : [self.log; RheoLogItem( (type=:process, funct=:resample, params=(elperiods = elperiods, ), keywords=(time_boundaries = time_boundaries, ) ),
                                        (comment="Resample the data",) ) ]

    return RheoTimeData(sigma, epsilon, time, log)

end

"""
    cutting(self::RheoTimeData, time_on::T1, time_off::T2) where {T1<:Number, T2<:Number}

Remove the data outside a specified time interval.

By specifing a time interval (time_on, time_off), a new RheoTimeData is returned without the data
lying outside time interval.
"""
function cutting(self::RheoTimeData, time_on::T1, time_off::T2) where {T1<:Number, T2<:Number}

    @assert isreal(time_on) && isreal(time_off) "Boundaries cannot be complex numbers"

    boundary_on = closestindex(self.t, time_on);
    boundary_off = closestindex(self.t, time_off);
    time = self.t[boundary_on:boundary_off]

    check = RheoTimeDataType(self)
    if (check == strain_only)
        ϵ = self.ϵ[boundary_on:boundary_off]
        σ = [];
    elseif (check == stress_only)
        σ = self.σ[boundary_on:boundary_off]
        ϵ = [];
    elseif (check == strain_and_stress)
        ϵ = self.ϵ[boundary_on:boundary_off]
        σ = self.σ[boundary_on:boundary_off]
    end

    log = self.log == nothing ? nothing : [self.log; RheoLogItem( (type=:process, funct=:cutting, params=(time_on = time_on, time_off = time_off), keywords=() ),
                                        (comment="Cut section of the data between $time_on and $time_off",) ) ]

    return RheoTimeData(σ, ϵ, time, log)

end

"""
    smooth(self::RheoTimeData, τ::Real; pad::String="reflect")

Smooth data using a Gaussian Kernel to time scale τ (approximately half power).

Smooths both σ and ϵ. Sampling frequency must be constant as it is based on FFT convolution. Essentially a
low pass filter with frequencies of 1/τ being cut to approximately half power. For other pad types available
see ImageFiltering documentation. As of doc writing, pad options are: "replicate" (repeat edge values to
infinity), "circular" (image edges "wrap around"), "symmetric" (the image reflects relative to a position
between pixels), "reflect" (the image reflects relative to the edge itself).
"""
function smooth(self::RheoTimeData, τ::Real; pad::String="reflect")

    @eval import ImageFiltering: imfilter, Kernel

    # get sample-rate and Gaussian kernel (std. dev)
    samplerate = 1.0/getsampleperiod(self.t)
    Σ = getsigma(τ, samplerate)

    # smooth signal and return
    check = RheoTimeDataType(self)
    if (check == strain_only)
        epsilon = Base.invokelatest(imfilter, self.ϵ, Base.invokelatest(Kernel.reflect, Base.invokelatest(Kernel.gaussian, (Σ,))), pad)
        sigma = [];
    elseif (check == stress_only)
        sigma = Base.invokelatest(imfilter, self.σ, Base.invokelatest(Kernel.reflect, Base.invokelatest(Kernel.gaussian, (Σ,))), pad)
        epsilon = [];
    elseif (check == strain_and_stress)
        sigma = Base.invokelatest(imfilter, self.σ, Base.invokelatest(Kernel.reflect, Base.invokelatest(Kernel.gaussian, (Σ,))), pad)
        epsilon = Base.invokelatest(imfilter, self.ϵ, Base.invokelatest(Kernel.reflect, Base.invokelatest(Kernel.gaussian, (Σ,))), pad)
    end


    log = self.log == nothing ? nothing : [self.log; RheoLogItem( (type=:process, funct=:smooth, params=(τ = τ,), keywords=(pad = pad,) ),
                                        (comment="Smooth data with timescale $τ",) ) ]

    RheoTimeData(sigma, epsilon, self.t, log)

end

"""
    extract(self::Union{RheoTimeData,RheoFreqData}, type::Union{TimeDataType,FreqDataType,Integer})

Extract specific fields form RheoTimeData or RheoFreqData.

Extract can copy one or more fields from a given RheoXData variable into a new RheoXData one. The fields that
are copied are identified by the specified type of data.
If self is a RheoTimeData, the type that can be extracted is time_only (or 0), stress_only (or 1), strain_only (or 2).
Note that strain_and_stress (or 3) is not allowed.
If self is a RheoFreqData, the type that can be extracted is freq_only (or 0).
"""
function extract(self::RheoTimeData, type::Union{TimeDataType,Integer})

        type = typeof(type)==Int ? TimeDataType(type) : type
        @assert (typeof(type)==TimeDataType) || (typeof(type)==Int) "Cannot extract frequency data from RheoTimeData"
        @assert (type!= strain_and_stress) && (type!= invalid_time_data) "Cannot extract both stress and strain"
        @assert (type!= invalid_time_data) "Cannot extract information from invalid time data"
        check = RheoTimeDataType(self)


        log = self.log == nothing ? nothing : [self.log; RheoLogItem( (type=:process, funct=:extract, params=(type=type,), keywords=() ),
                                            (comment="Data field extraction, $type from $check",) ) ]


        if type == time_only
            @assert check!= invalid_time_data "Time not available"
            return RheoTimeData([], [], self.t,log)
        elseif type == strain_only
            @assert (check == strain_and_stress) || (check == strain_only) "Strain not available"
            return RheoTimeData([], self.ϵ, self.t,log)
        elseif type == stress_only
            @assert (check == strain_and_stress) || (check == stress_only) "Stress not available"
            return RheoTimeData(self.σ, [], self.t,log)
        end

end

function extract(self::RheoFreqData, type::Union{FreqDataType,Integer})

        type = typeof(type)==Int ? FreqDataType(type) : type
        @assert (type!= with_modulus) "Cannot extract frequency with moduli"
        @assert (type!= invalid_freq_data) "Cannot extract information from invalid frequency data"
        check = RheoFreqDataType(self)
        @assert (check == with_modulus) "Frequency and modulii required"

        log = self.log == nothing ? nothing : [self.log; RheoLogItem( (type=:process, funct=:extract, params=(type=type,), keywords=() ),
                                            (comment="Frequency field extraction",) ) ]
        return RheoFreqData([], [], self.ω,log)
end

#=
--------------------------------
Fitting and predicting functions
--------------------------------
=#
"""
    modelfit(data::RheoTimeData, model::RheoModelClass, modloading::Symbol; p0::Union{NamedTuple,Tuple} = (), lo::Union{NamedTuple,Tuple} = (), hi::Union{NamedTuple,Tuple} = (), verbose::Bool = false, rel_tol = 1e-4, diff_method="BD")

Fit RheologyData struct to model and return a fitted model as a RheologyModel object.
For the fitting process RHEOS relies on the optimistion package NLopt.jl (https://nlopt.readthedocs.io/en/latest/).
RHEOS makes use of a local derivative free algorithm, specifically the Tom Rowan's "Subplex"

# Arguments

- `data`: RheoTimeData struct containing all data
- `model`: RheoModelClass containing moduli functions and named tuple parameters
- `modloading`: strain_imposed or 1, stress_imposed or 2
- `p0`: Initial parameters to use in fit (uses 0.5 for all parameters if not defined)
- `lo`: Lower bounds for parameters
- `hi`: Upper bounds for parameters
- `verbose`: If true, prints parameters on each optimisation iteration
- `rel_tol`: Relative tolerance of optimization, see NLOpt docs for more details
- `diff_method`: Set finite difference formula to use for derivative, currently "BD" or "CD"
"""
function modelfit(data::RheoTimeData,
                  model::RheoModelClass,
                  modloading::LoadingType;
                  p0::Union{NamedTuple,Tuple} = (),
                  lo::Union{NamedTuple,Tuple} = (),
                  hi::Union{NamedTuple,Tuple} = (),
                  verbose::Bool = false,
                  rel_tol = 1e-4,
                  diff_method="BD")

    if isempty(p0)
        p0a = convert(Array{RheoFloat,1}, fill(0.5,length(model.params)))
        if length(findall(x->(x==:β)||(x==:a),model.params))==2
            index = findall(x->x==:a,model.params)
            p0a[index[1]] = 0.8;
        end
        @warn "Initial values for model parameters is set to $p0a by default"
    else
        p0a = model_parameters(p0,model.params,"initial guess")
    end

    #check_ineq = model.ineq(p0)
    #@assert (all(check_ineq)==true)  "Initial guess not feasible"
    @assert model.constraint(p0a)  "Initial guess not feasible"

    if isempty(lo)
        loa = nothing
    else
        loa = model_parameters(lo,model.params,"low bounds")
    end

    if isempty(hi)
        hia = nothing
    else
        hia = model_parameters(hi,model.params,"high bounds")
    end

    rel_tol = convert(RheoFloat,rel_tol)

    check = RheoTimeDataType(data)
    @assert (check == strain_and_stress) "Both stress and strain are required"

    # use correct method for derivative
    if diff_method=="BD"
        deriv = derivBD
    elseif diff_method=="CD"
        deriv = derivCD
    end

    # get modulus function and derivative
    if modloading == stress_imposed
        dcontrolled = deriv(data.σ, data.t)
        measured = data.ϵ
        modulus = model.Ja
        modsing = (t->model.J(t,p0a))
        modused = "J"
    elseif modloading == strain_imposed
        dcontrolled = deriv(data.ϵ, data.t)
        measured = data.σ
        modulus = model.Ga
        modsing = (t->model.G(t,p0a))
        modused ="G"
    end

    # 5.0 is not meaningful, just an input to check that the function does not return NaN
    # at a non-zero value, which is the default function output for moduli that have
    # not been defined.
    @assert !isnan(modsing(5.0)) "Modulus to use not defined"
    # get singularity presence
    sing = singularitytest(modsing)
    # get time step (only needed for convolution, which requires constant dt so t[2]-t[1] is sufficient)
    dt = data.t[2] - data.t[1]

    # time must start at 0 for convolution to work properly!
    t_zeroed = data.t .- minimum(data.t)

    # fit
    sampling_check = constantcheck(data.t)

    (minf, minx, ret), timetaken, bytes, gctime, memalloc =
                    @timed leastsquares_init(   p0a,
                                                loa,
                                                hia,
                                                modulus,
                                                t_zeroed,
                                                dt,
                                                dcontrolled,
                                                measured;
                                                insight = verbose,
                                                constant_sampling = sampling_check,
                                                singularity = sing,
                                                _rel_tol = rel_tol)

    println("Time: $timetaken s, Why: $ret, Parameters: $minx, Error: $minf")

    nt = NamedTuple{Tuple(model.params)}(minx)

    if data.log != nothing
        # Preparation of data for log item
        info=(comment="Fiting rheological model to data", model_name=model.name, model_params=nt, time_taken=timetaken, stop_reason=ret, error=minf)
        params=(model=model, modloading=modloading)
        keywords=(p0=p0, lo=lo, hi=hi, rel_tol=rel_tol, diff_method=diff_method)
        # Add data to the log
        push!(data.log, RheoLogItem( (type=:analysis, funct=:modelfit, params=params, keywords=keywords), info))
    end

    return RheoModel(model, nt);

end

"""
    modelpredict(data::RheoTimeData, model::RheoModel; diff_method="BD")

Given an incomplete data set (only either stress or strain missing) and model with values substituted into
parameters (RheoModel), return a new dataset based on the model.
If data is type of stress_only, then creep modulus (:J) is used; if data type is strain_only relaxation modulus (:G).
A complete RheoTimeDatadata of type "strain_and_stress" is returned.
'diff_method' sets finite difference for calculating the derivative used in the hereditary integral and
can be either backwards difference ("BD") or central difference ("CD").
"""
function modelpredict(data::RheoTimeData, model::RheoModel; diff_method="BD")

    # use correct method for derivative
    if diff_method=="BD"
        deriv = derivBD
    elseif diff_method=="CD"
        deriv = derivCD
    end

    check = RheoTimeDataType(data)
    @assert (check == strain_only)||(check == stress_only) "Need either strain only or stress only data. Data provide: " * string(check)

    if (check == strain_only)
        modulus = model.Ga
        modsing = model.G
        dcontrolled = deriv(data.ϵ, data.t)
    elseif (check == stress_only)
        modulus = model.Ja
        modsing = model.J
        dcontrolled = deriv(data.σ, data.t)
    end

    # get singularity presence
    sing = singularitytest(modsing)

    # get time step (only needed for convolution, which requires constant so t[2]-t[1] is sufficient)
    dt = data.t[2] - data.t[1]

    # time must start at 0 for convolution to work properly
    t_zeroed = data.t .- minimum(data.t)

    # get convolution
    if !sing && constantcheck(data.t)
        convolved = boltzconvolve(modulus, t_zeroed, dt, dcontrolled)

    elseif sing && constantcheck(data.t)
        t_zeroed[1] = 0.0 + (t_zeroed[2] - t_zeroed[1])/10.0
        convolved = boltzconvolve(modulus, t_zeroed, dt, dcontrolled)

    elseif !sing && !constantcheck(data.t)
        convolved = boltzintegral_nonsing(modulus, t_zeroed, dcontrolled)

    elseif sing && !constantcheck(data.t)
        convolved = boltzintegral_sing(modulus, t_zeroed, dcontrolled)

    end

    if (check == stress_only)
        sigma = data.σ
        epsilon = convolved
        pred_mod = "creep function J"
    elseif (check == strain_only)
        sigma = convolved
        epsilon = data.ϵ
        pred_mod = "relaxation function G"
    end

    log = data.log == nothing ? nothing : [ data.log;
            RheoLogItem( (type=:process, funct=:modelpredict, params=(model::RheoModel,), keywords=(diff_method = diff_method,)),
                         (comment="Predicted data - modulus: $pred_mod, parameters:$(model.params)",) ) ]

    return RheoTimeData(sigma, epsilon, data.t, log)

end

"""
    modelstepfit(data::RheoTimeData, model::RheoModelClass, modloading::Union{LoadingType,Integer}; step=nothing, p0::Union{NamedTuple,Tuple} = (), lo::Union{NamedTuple,Tuple} = (), hi::Union{NamedTuple,Tuple} = (), verbose::Bool = false, rel_tol = 1e-4) where T<:Real

Same as 'modelfit' except assumes a step loading. If this assumption is appropriate for the data
then fitting can be sped up greatly by use of this function. If modloading is strain_imposed, relaxation modulus is used,
then the element in the middle of the strain is assumed to be the amplitude of the step. If modloading is stress_imposed,
the creep modulus is used, then the middle element of the stress is assumed to be the amplitude of the step.
Alternatively, it is possible to define the value of the step by defining the optional "step" parameter.

# Arguments

- `data`: RheoTimeData struct containing all data
- `model`: RheoModelClass containing moduli and parameters tuples
- `modloading`: strain_imposed for relaxation modulus, stress_imposed for creep modulus
- `p0`: Named tuple of initial parameters to use in fit (uses 0.5 for all parameters if none given)
- `lo`: Named tuple of lower bounds for parameters
- `hi`: Named tuple of upper bounds for parameters
- `verbose`: If true, prints parameters on each optimisation iteration
- `rel_tol`: Relative tolerance of optimization, see NLOpt docs for more details
"""
function modelstepfit(data::RheoTimeData,
                  model::RheoModelClass,
                  modloading::Union{LoadingType,Integer};
                  step = nothing,
                  p0::Union{NamedTuple, Tuple} = (),
                  lo::Union{NamedTuple, Tuple} = (),
                  hi::Union{NamedTuple, Tuple} = (),
                  verbose::Bool = false,
                  rel_tol = 1e-4) where {T1<:Real, T2<:Real, T3<:Real}

    if isempty(p0)
        p0a = ones(RheoFloat, length(model.params))./2
        if length(findall(x->(x==:β)||(x==:a), model.params))==2
            index = findall(x->x==:a, model.params)
            p0a[index[1]] = 0.8;
        end
        @warn "Initial model parameter value(s) is/are set to $p0a by default"
    else
        p0a = model_parameters(p0, model.params,"initial guess")
    end

    if isempty(lo)
       loa = nothing
    else
       loa = model_parameters(lo, model.params,"low bounds")
    end

    if isempty(hi)
       hia = nothing
    else
       hia = model_parameters(hi, model.params,"high bounds")
    end

    rel_tol = convert(RheoFloat, rel_tol)

    # get data type provided
    check = RheoTimeDataType(data)
    # if step amplitude not provided, use loading data specified
    if isnothing(step)
        @assert (check == strain_and_stress) "Both stress and strain are required if step amplitude not provided."
        if (modloading == stress_imposed)
            # step amplitude is set to the middle value of the 'loading' data array
            controlled = data.σ[round(Integer, length(data.σ)/2)]
            measured = data.ϵ
            modulus = model.Ja
            modsing = (t->model.J(t, p0a))
            modused = "J"
        elseif (modloading == strain_imposed)
            # step amplitude is set to the middle value of the 'loading' data array
            controlled = data.ϵ[round(Integer, length(data.σ)/2)]
            measured = data.σ
            modulus = model.Ga
            modsing = (t->model.G(t, p0a))
            modused = "G"
        end
    # if step provided then can use that value
    elseif !isnothing(step)
        if (modloading == stress_imposed)
            @assert (check == strain_only)||(check == strain_and_stress) "Strain required"
            modulus = model.Ja
            modsing = (t->model.J(t, p0a))
            controlled = convert(RheoFloat, step);
            measured = data.ϵ
            modused = "J"
        elseif (modloading == strain_imposed)
            @assert (check == stress_only)||(check == strain_and_stress) "Stress required"
            measured = data.σ
            modulus = model.Ga
            modsing = (t->model.G(t, p0a))
            controlled =convert(RheoFloat, step);
            modused = "G"
        end
    end

    # 5.0 is not meaningful, just an input to check that the function does not return NaN
    # at a non-zero value, which is the default function output for moduli that have
    # not been defined.
    @assert !isnan(modsing(5.0)) "Modulus to use not defined"
    # get singularity presence
    sing = singularitytest(modsing)

    # time must start at 0 for modulus to be defined properly
    t_zeroed = data.t .- minimum(data.t)

    # start fit
    (minf, minx, ret), timetaken, bytes, gctime, memalloc =
                        @timed leastsquares_stepinit(p0a,
                                                    loa,
                                                    hia,
                                                    modulus,
                                                    t_zeroed,
                                                    controlled,
                                                    measured;
                                                    insight = verbose,
                                                    singularity = sing,
                                                    _rel_tol = rel_tol)

    nt = NamedTuple{Tuple(model.params)}(minx)

    if data.log != nothing
        # Preparation of data for log item
        info=(comment="Fiting rheological model to data (step input assumed)", model_name=model.name, model_params=nt, time_taken=timetaken, stop_reason=ret, error=minf)
        params = (model = model, modloading = modloading)
        keywords = (step = step, p0 = p0, lo = lo, hi = hi, rel_tol = rel_tol)
        # Add data to the log
        push!(data.log, RheoLogItem( (type=:analysis, funct=:modelstepfit, params=params, keywords=keywords), info))
    end

    print("Time: $timetaken s, Why: $ret, Parameters: $minx, Error: $minf")

    return RheoModel(model, nt)
end

"""
    modelsteppredict(data::RheoTimeData, model::RheoModel; step_on::Real = 0.0)

Same as modelpredict but assumes a step loading with step starting at 'step_on'. Singularities are bypassed
by adding 1 to the index of the singular element.
"""
function modelsteppredict(data::RheoTimeData, model::RheoModel; step_on::Real = 0.0)

    step_on = convert(RheoFloat,step_on)

    check = RheoTimeDataType(data)
    @assert (check == strain_only)||(check == stress_only) "Need either strain only or stress only data. Data provide: " * string(check)

    if (check == strain_only)
        modulus = model.Ga
        modsing = model.G
        controlled = data.ϵ[round(Integer, length(data.ϵ)/2)]
    elseif (check == stress_only)
        modulus = model.Ja
        modsing = model.J
        controlled = data.σ[round(Integer, length(data.σ)/2)]
    end

    # get closest index to desired step-on time point
    stepon_el = closestindex(data.t, step_on)

    # check singularity presence at time closest to step
    sing = singularitytest(modsing)

    # get predicted
    if !sing
        predicted = zeros(length(data.t))
        predicted[stepon_el:end] = controlled*modulus(data.t[stepon_el:end] .- step_on)

    elseif sing
        predicted = zeros(length(data.t))
        predicted[(stepon_el + 1):end] = controlled*modulus(data.t[(stepon_el + 1):end] .- step_on)

    end

    if check == stress_only
        σ = data.σ
        ϵ = predicted
    elseif check == strain_only
        σ = predicted
        ϵ = data.ϵ
    end

    # store operation
    if (check == stress_only)
        sigma = data.σ
        epsilon = predicted
        pred_mod = "creep function J"
    elseif (check == strain_only)
        sigma = predicted
        epsilon = data.ϵ
        pred_mod = "relaxation function G"
    end
    time = data.t

    log = data.log == nothing ? nothing : [ data.log;
            RheoLogItem( (type=:process, funct=:modelsteppredict, params=(model::RheoModel,), keywords=(step_on = step_on,)),
                         (comment="Predicted step response - modulus: $pred_mod, parameters:$(model.params)",) ) ]


    return RheoTimeData(sigma,epsilon,time, log)
end

function obj_dynamic(params, grad, ω, dataGp, dataGpp, modelGp, modelGpp; _insight::Bool = false)

    if _insight
        println("Current Parameters: ", params)
    end

    costGp = sum((dataGp - modelGp(ω, params)).^2)
    costGpp = sum((dataGpp - modelGpp(ω, params)).^2)

    cost = costGp + costGpp
end

function obj_dynamic_mean(params, grad, ω, dataGp, dataGpp, modelGp, modelGpp, meanGp, meanGpp; _insight::Bool = false)

    if _insight
        println("Current Parameters: ", params)
    end

    costGp = sum((dataGp/meanGp - modelGp(ω, params)/meanGp).^2)
    costGpp = sum((dataGpp/meanGpp - modelGpp(ω, params)/meanGpp).^2)

    cost = costGp + costGpp

end

function obj_dynamic_log(params, grad, ω, dataGp, dataGpp, modelGp, modelGpp; _insight::Bool = false)

    if _insight
        println("Current Parameters: ", params)
    end

    costGp = sum((log.(dataGp) - log.(modelGp(ω, params))).^2)
    costGpp = sum((log.(dataGpp) - log.(modelGpp(ω, params))).^2)

    cost = costGp + costGpp

end

function obj_dynamic_local(params, grad, ω, dataGp, dataGpp, modelGp, modelGpp; _insight::Bool = false)

    if _insight
        println("Current Parameters: ", params)
    end

    costGp = sum(((dataGp - modelGp(ω, params))./dataGp).^2)
    costGpp = sum(((dataGpp - modelGpp(ω, params))./dataGpp).^2)

    cost = costGp + costGpp

end

function obj_dynamic_manual(params, grad, ω, dataGp, dataGpp, modelGp, modelGpp, weights; _insight::Bool = false)

    if _insight
        println("Current Parameters: ", params)
    end

    costGp = sum((dataGp - modelGp(ω, params)).^2)
    costGpp = sum((dataGpp - modelGpp(ω, params)).^2)

    cost = weights[1]*costGp + weights[2]*costGpp
end

"""
    dynamicmodelfit(data::RheoFreqData, model::RheoModelClass; p0::Union{NamedTuple,Tuple} = (), lo::Union{NamedTuple,Tuple} = (), hi::Union{NamedTuple,Tuple} = (), verbose::Bool = false, rel_tol = 1e-4) where T<:Real

Fits model to the frequency/loss+storage moduli data.

All arguments are as described below.
As this fitting procedure is fitting two functions simultaneously (the storage
and loss moduli), if left untransformed the fit would tend to favour the
modulus which is larger in magnitude and not fit the other modulus well. To avoid this,
RHEOS offers a number of data transforms which can be used by changing "weights" argument.

# Arguments

- `data`: RheoFreqData struct containing all data
- `model`: RheoModelClass containing moduli and symbols of parameters
- `p0`: Initial parameters to use in fit (uses 0.5 for all parameters if none given)
- `lo`: Lower bounds for parameters
- `hi`: Upper bounds for parameters
- `verbose`: If true, prints parameters on each optimisation iteration
- `rel_tol`: Relative tolerance of optimization, see NLOpt docs for more details
- `weights`: Weighting mode for storage and loss modulus ("none", "mean", "log", "local" or manually specified)
"""
function dynamicmodelfit(data::RheoFreqData,
                model::RheoModelClass;
                p0::Union{NamedTuple,Tuple} = (),
                lo::Union{NamedTuple,Tuple} = (),
                hi::Union{NamedTuple,Tuple} = (),
                verbose::Bool = false,
                rel_tol::T = 1e-4,
                weights::Union{String, Vector{T}}="local") where T<:Real

    if isempty(p0)
        p0 = ones(RheoFloat, length(model.params))./2
        if length(findall(x->(x==:β)||(x==:a), model.params))==2
            index = findall(x->x==:a, model.params)
            p0[index[1]] = 0.8;
        end
        @warn "Initial model parameter value(s) is/are set to $p0 by default"
    else
        p0 = model_parameters(p0, model.params,"initial guess")
    end

    # initialise NLOpt.Opt object with :LN_SBPLX Subplex algorithm
    opt = Opt(:LN_SBPLX, length(p0))

    if !isempty(lo)
       lo = model_parameters(lo,model.params, "low bounds")
       lower_bounds!(opt, lo)
    end

    if !isempty(hi)
       hi = model_parameters(hi,model.params, "high bounds")
       upper_bounds!(opt, hi)
    end

    # set relative tolerance
    rel_tol = convert(RheoFloat, rel_tol)
    xtol_rel!(opt, rel_tol)

    # set objective/cost function
    if weights=="none"
        min_objective!(opt, (params, grad) -> obj_dynamic(params, grad, data.ω, data.Gp, data.Gpp, model.Gpa, model.Gppa; _insight = verbose))

    elseif weights=="mean"
        meanGp = sum(data.Gp)/length(data.Gp)
        meanGpp = sum(data.Gp)/length(data.Gp)
        min_objective!(opt, (params, grad) -> obj_dynamic_mean(params, grad, data.ω, data.Gp, data.Gpp, model.Gpa, model.Gppa, meanGp, meanGpp; _insight = verbose))

    elseif weights=="log"
        @warn "Note that a logarithmic rescaling will fail if Gp or Gpp data contain 0.0 values as it will result in -Inf cost. Trying a different rescaling scheme, or not fitting around ω≈0.0 may alleviate the issue."
        min_objective!(opt, (params, grad) -> obj_dynamic_log(params, grad, data.ω, data.Gp, data.Gpp, model.Gpa, model.Gppa; _insight = verbose))

    elseif weights=="local"
        @warn "Note that a local rescaling will fail if Gp or Gpp data contain 0.0 values as it will result in division by 0.0. Trying a different rescaling scheme, or not fitting around ω≈0.0 may alleviate the issue."
        min_objective!(opt, (params, grad) -> obj_dynamic_local(params, grad, data.ω, data.Gp, data.Gpp, model.Gpa, model.Gppa; _insight = verbose))

    elseif typeof(weights)==Vector{T} && length(weights)==2
        min_objective!(opt, (params, grad) -> obj_dynamic_manual(params, grad, data.ω, data.Gp, data.Gpp, model.Gpa, model.Gppa, weights; _insight = verbose))

    end

    # timed fitting
    (minf, minx, ret), timetaken, bytes, gctime, memalloc =
                        @timed NLopt.optimize(opt,
                                            p0)

    nt = NamedTuple{Tuple(model.params)}(minx)

    if data.log != nothing
        # Preparation of data for log item
        info = (comment="Fiting rheological model to frequency spectrum", model_name=model.name, model_params=nt, time_taken=timetaken, stop_reason=ret, error=minf)
        params = (model=model, )
        keywords = (p0=p0, lo=lo, hi=hi, rel_tol=rel_tol, weights=weights)
        # Add data to the log
        push!(data.log, RheoLogItem( (type=:analysis, funct=:dynamicmodelfit, params=params, keywords=keywords), info))
    end

    print("Time: $timetaken s, Why: $ret, Parameters: $minx, Error: $minf")

    return RheoModel(model, nt)
end

"""
    dynamicmodelpredict(data::RheoFreqData, model::RheoModel)

Given dynamic rheology data with only frequency and model where parameters have been substituted.
Returns another RheoFreqData instance with the predicted Gp and Gpp based on the
frequencies and model given as arguments.
"""
function dynamicmodelpredict(data::RheoFreqData, model::RheoModel)

    predGp = model.Gpa(data.ω)
    predGpp = model.Gppa(data.ω)

    log = data.log == nothing ? nothing : [ data.log;
            RheoLogItem( (type=:process, funct=:dynamicmodelpredict, params=(model::RheoModel,), keywords=() ),
                         (comment="Calculated frequency spectrum - parameters:$(model.params)",) ) ]

    return RheoFreqData(predGp, predGpp, data.ω, log)

end
