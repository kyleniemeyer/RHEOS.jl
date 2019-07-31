var documenterSearchIndex = {"docs":
[{"location":"elements/#Spring-pot-1","page":"Basic Elements","title":"Spring-pot","text":"","category":"section"},{"location":"elements/#","page":"Basic Elements","title":"Basic Elements","text":"using RHEOS\nusing PyPlot","category":"page"},{"location":"elements/#","page":"Basic Elements","title":"Basic Elements","text":"┌ Info: Recompiling stale cache file /home/ab2425/.julia/compiled/v1.1/RHEOS/8Ut5K.ji for RHEOS [728860ae-c896-11e8-0b91-0f38ecad5046]\n└ @ Base loading.jl:1184","category":"page"},{"location":"elements/#Consitutive-equation-1","page":"Basic Elements","title":"Consitutive equation","text":"","category":"section"},{"location":"elements/#","page":"Basic Elements","title":"Basic Elements","text":"sigma(t) = c_beta fracd^beta epsilon(t)dt^beta","category":"page"},{"location":"elements/#","page":"Basic Elements","title":"Basic Elements","text":"for 0 leq beta leq 1","category":"page"},{"location":"elements/#","page":"Basic Elements","title":"Basic Elements","text":"By typing the name of the model, it is possible to visualise its graphical representation and its parameters. ","category":"page"},{"location":"elements/#","page":"Basic Elements","title":"Basic Elements","text":"Springpot","category":"page"},{"location":"elements/#","page":"Basic Elements","title":"Basic Elements","text":"Model name: springpot\n\nFree parameters: cᵦ and β\n\n                ____ ╱╲ ____\n                     ╲╱  cᵦ, β","category":"page"},{"location":"elements/#Relaxation-modulus-1","page":"Basic Elements","title":"Relaxation modulus","text":"","category":"section"},{"location":"elements/#","page":"Basic Elements","title":"Basic Elements","text":"G(t) = fracc_beta Gamma(1-beta) t^-beta","category":"page"},{"location":"elements/#Creep-modulus-1","page":"Basic Elements","title":"Creep modulus","text":"","category":"section"},{"location":"elements/#","page":"Basic Elements","title":"Basic Elements","text":"J(t) = frac1c_beta Gamma(1+beta)t^beta","category":"page"},{"location":"elements/#Storage-and-loss-moduli-1","page":"Basic Elements","title":"Storage and loss moduli","text":"","category":"section"},{"location":"elements/#","page":"Basic Elements","title":"Basic Elements","text":"G^*(omega) = c_beta (iomega )^beta","category":"page"},{"location":"elements/#","page":"Basic Elements","title":"Basic Elements","text":"$ G^{\\prime}(\\omega) = c_\\beta \\omega^\\beta \\cos(\\frac{\\pi}{2}\\beta)$","category":"page"},{"location":"elements/#Spring-1","page":"Basic Elements","title":"Spring","text":"","category":"section"},{"location":"elements/#","page":"Basic Elements","title":"Basic Elements","text":"When beta = 0 the springpot specialises to a spring","category":"page"},{"location":"elements/#","page":"Basic Elements","title":"Basic Elements","text":"Spring","category":"page"},{"location":"elements/#","page":"Basic Elements","title":"Basic Elements","text":"Model name: spring\n\nFree parameters: k\n\n                ___╱╲  ╱╲  ╱╲  ________\n                     ╲╱  ╲╱  ╲╱  k","category":"page"},{"location":"elements/#Dashpot-1","page":"Basic Elements","title":"Dashpot","text":"","category":"section"},{"location":"elements/#","page":"Basic Elements","title":"Basic Elements","text":"When beta = 1 the springpot specialises to a dashpot","category":"page"},{"location":"elements/#","page":"Basic Elements","title":"Basic Elements","text":"Dashpot","category":"page"},{"location":"elements/#","page":"Basic Elements","title":"Basic Elements","text":"Model name: dashpot\n\nFree parameters: η\n\n                 ___\n             _____| |_____\n                 _|_|\n                     η","category":"page"},{"location":"elements/#Qualitative-behaviour-1","page":"Basic Elements","title":"Qualitative behaviour","text":"","category":"section"},{"location":"elements/#","page":"Basic Elements","title":"Basic Elements","text":"# Create a time only dataset\ndϵ = timeline()\ndσ = timeline()\n\n# calculate a strain/stress data by appling a function of time (by defalut a unit step otherwise substitute hstep(amp = 2.))\ndϵ = strainfunction(dϵ, hstep())\ndσ = stressfunction(dσ, hstep()) - stressfunction(dσ, hstep(offset = 5.0))\n\ncolplot = [\"#dc7633\", \"#229954\", \"#d4ac0d\"]\n\nfig, ax = subplots(1,2, figsize=(15,7))\n\n\n# plot moduli for varying β\nfor (i,beta) in enumerate([0.3, 0.5, 0.7])\n    \n    springpot_model = RheoModel(Springpot,(cᵦ = 1.0, β = beta))\n    \n    #Relaxation modulus\n    dG_springpot = modelpredict(dϵ, springpot_model)\n    ax[1].plot(dG_springpot.t, dG_springpot.σ./maximum(dG_springpot.σ), color=colplot[i])\n    \n    # Creep modulus\n    dJ_springpot = modelpredict(dσ, springpot_model)\n    ax[2].plot(dJ_springpot.t, dJ_springpot.ϵ./maximum(dJ_springpot.ϵ), color=colplot[i])\n \nend\n\n# Spring\nspring_model = RheoModel(Spring, (k = 1.0,))\n\n#Relaxation modulus\ndG_spring = modelpredict(dϵ, spring_model)\nax[1].plot(dG_spring.t, dG_spring.σ./maximum(dG_spring.σ), color = \"red\");\n\n# Creep modulus\ndJ_spring = modelpredict(dσ, spring_model)\nax[2].plot(dJ_spring.t, dJ_spring.ϵ./maximum(dJ_spring.ϵ), color = \"red\");\n\n# Dashpot \ndashpot_model = RheoModel(Dashpot, (η = 1.0,))\n\n# Creep modulus\ndJ_dashpot = modelpredict(dσ, dashpot_model)\nax[2].plot(dJ_dashpot.t, dJ_dashpot.ϵ./maximum(dJ_dashpot.ϵ), color = \"blue\");\n\nax[1].set_xlabel(\"Time\");\nax[1].set_ylabel(\"Stress\");\n\nax[2].set_xlabel(\"Time\");\nax[2].set_ylabel(\"Strain\");","category":"page"},{"location":"elements/#","page":"Basic Elements","title":"Basic Elements","text":"(Image: png)","category":"page"},{"location":"elements/#","page":"Basic Elements","title":"Basic Elements","text":"dω = frequencyspec()\n\n# plot moduli for varying β\nfor (i,beta) in enumerate([0.3, 0.5, 0.7])\n    \n    springpot_model = RheoModel(Springpot,(cᵦ = 1.0, β = beta))\n    \n    # Storage and Loss moduli\n    d_springpot = dynamicmodelpredict(dω, springpot_model)\n    loglog(d_springpot.ω, d_springpot.Gp, color=colplot[i], \"-\")\n    loglog(d_springpot.ω, d_springpot.Gpp, color=colplot[i], \"--\")\nend","category":"page"},{"location":"elements/#","page":"Basic Elements","title":"Basic Elements","text":"(Image: png)","category":"page"},{"location":"elements/#","page":"Basic Elements","title":"Basic Elements","text":"","category":"page"},{"location":"examples/#RHEOS-Tutorials-1","page":"Examples","title":"RHEOS Tutorials","text":"","category":"section"},{"location":"examples/#","page":"Examples","title":"Examples","text":"using RHEOS","category":"page"},{"location":"examples/#","page":"Examples","title":"Examples","text":"PyPlot needs to be installed to run these examples and display plots of the data.","category":"page"},{"location":"examples/#","page":"Examples","title":"Examples","text":"using PyPlot","category":"page"},{"location":"examples/#Example-1-1","page":"Examples","title":"Example 1","text":"","category":"section"},{"location":"examples/#","page":"Examples","title":"Examples","text":"Loading experimental data from csv file\nFitting model\nComparing original data with fit","category":"page"},{"location":"examples/#","page":"Examples","title":"Examples","text":"using PyPlot\n\n# Make sure the examples folder is the current directory\n# check by typing \"pwd()\"\n\n# Import data\ndata = importcsv(\"example1_data.csv\", t_col=1, ϵ_col=2, σ_col=3)\n\n# Plot data\nplot(data.t,data.ϵ,\"-\")\nplot(data.t,data.σ,\".\")\n\n# We now fit a Standard Linear Solid model\nmaxwell_model = modelfit(data, Maxwell, strain_imposed)\n","category":"page"},{"location":"examples/#","page":"Examples","title":"Examples","text":"┌ Warning: Please note that NaN data rows are not included in resultant data struct.\n└ @ RHEOS /home/ab2425/.julia/dev/RHEOS/src/IO.jl:11\n┌ Warning: Initial values for model parameters is set to [0.5, 0.5] by default\n└ @ RHEOS /home/ab2425/.julia/dev/RHEOS/src/processing.jl:210","category":"page"},{"location":"examples/#","page":"Examples","title":"Examples","text":"(Image: png)","category":"page"},{"location":"examples/#","page":"Examples","title":"Examples","text":"Time: 2.079403156 s, Why: XTOL_REACHED, Parameters: [4.0054, 2.003], Error: 0.022310985023644047","category":"page"},{"location":"examples/#","page":"Examples","title":"Examples","text":"Model: maxwell\n\nParameter values: (η = 4.0054017305374146, k = 2.003000020980835) \n\n                ___\n            _____| |________╱╲  ╱╲  ╱╲  ___\n                _|_|          ╲╱  ╲╱  ╲╱\n                  η                  k","category":"page"},{"location":"examples/#","page":"Examples","title":"Examples","text":"Note that the fitting function requires guidance regarding the type of testing used. It helps optimise the fitting process.","category":"page"},{"location":"examples/#","page":"Examples","title":"Examples","text":"The data in this example is the stress response to a strain ramp followed by plateau. It therefore corresponds to a strain imposed process.","category":"page"},{"location":"examples/#","page":"Examples","title":"Examples","text":"We now want to calculate the stress values predicted by the model given the experimental strain data. Lets create a new data set with the strain profile","category":"page"},{"location":"examples/#","page":"Examples","title":"Examples","text":"\nmaxwell_predict = extract(data, strain_only)\n# and calculate the stress based on the model\nmaxwell_predict = modelpredict(maxwell_predict, maxwell_model)\n# Now we can plot data and model together for comparison\n\n# Plot data\nplot(data.t,data.ϵ,\"-\")\nplot(data.t,data.σ,\".\")\nplot(maxwell_predict.t,maxwell_predict.σ)\n","category":"page"},{"location":"examples/#","page":"Examples","title":"Examples","text":"(Image: png)","category":"page"},{"location":"examples/#","page":"Examples","title":"Examples","text":"1-element Array{PyCall.PyObject,1}:\n PyObject <matplotlib.lines.Line2D object at 0x7fdab9667d30>","category":"page"},{"location":"examples/#Example-2-1","page":"Examples","title":"Example 2","text":"","category":"section"},{"location":"examples/#","page":"Examples","title":"Examples","text":"This script shows how to use RHEOS to explore the behaviour of various modeks This involves:","category":"page"},{"location":"examples/#","page":"Examples","title":"Examples","text":"Creating a strain function\nDefining models based on parameter values","category":"page"},{"location":"examples/#","page":"Examples","title":"Examples","text":"PyPlot needs to be installed to run these examples and display plots of the data.","category":"page"},{"location":"examples/#","page":"Examples","title":"Examples","text":"\n# Creates a time only dataset\ndϵ=timeline()\n# calculates strain data by applying a function of time\ndϵ=strainfunction(dϵ,t->sin(t))\n\n# Plot strain data\nplot(dϵ.t,dϵ.ϵ,\"--b\")\n\n\n# we can now simulate various models based on this strain only dataset\n# Let's study the role of the dashpot strength in the MAxwell model\nfor η in [0.1, 0.3, 1, 3, 10]\n    maxwell_model = RheoModel(Maxwell, k = 2., η = η)\n    d_maxwell = modelpredict(dϵ, maxwell_model)\n    plot(d_maxwell.t,d_maxwell.σ)\nend\nxlabel(\"Time\")\nylabel(L\"\\rm{Stress, }\\sigma\")\ngrid(\"on\")\n","category":"page"},{"location":"examples/#","page":"Examples","title":"Examples","text":"(Image: png)","category":"page"},{"location":"examples/#","page":"Examples","title":"Examples","text":"","category":"page"},{"location":"fractionalMaxwell/#Fractional-Maxwell-1","page":"Maxwell Models","title":"Fractional Maxwell","text":"","category":"section"},{"location":"fractionalMaxwell/#","page":"Maxwell Models","title":"Maxwell Models","text":"using RHEOS\nusing PyPlot","category":"page"},{"location":"fractionalMaxwell/#Consitutive-equation-1","page":"Maxwell Models","title":"Consitutive equation","text":"","category":"section"},{"location":"fractionalMaxwell/#Relaxation-modulus-1","page":"Maxwell Models","title":"Relaxation modulus","text":"","category":"section"},{"location":"fractionalMaxwell/#Creep-modulus-1","page":"Maxwell Models","title":"Creep modulus","text":"","category":"section"},{"location":"fractionalMaxwell/#Storage-and-loss-modulus-1","page":"Maxwell Models","title":"Storage and loss modulus","text":"","category":"section"},{"location":"fractionalMaxwell/#Qualitative-behaviour-1","page":"Maxwell Models","title":"Qualitative behaviour","text":"","category":"section"},{"location":"#RHEOS-RHEology-Open-Source-1","page":"Home","title":"RHEOS - RHEology Open Source","text":"","category":"section"},{"location":"#Please-Note-1","page":"Home","title":"Please Note","text":"","category":"section"},{"location":"#","page":"Home","title":"Home","text":"RHEOS is currently undergoing a major update. The documentation is being updated accordingly. The API section will be the first page to be updated. The tutorials from the previous documentation will be updated after this.","category":"page"},{"location":"#Overview-1","page":"Home","title":"Overview","text":"","category":"section"},{"location":"#","page":"Home","title":"Home","text":"RHEOS is a software package written in the Julia programming language that provides tools for analyzing rheological data. Features include:","category":"page"},{"location":"#","page":"Home","title":"Home","text":"Stress/Strain/Time data can be easily be fitted to a viscoelastic model\nG'/G''/Frequency data can easily be fitted to a viscoelastic model\nMany standard and fractional viscoelastic models have already been implemented within RHEOS new ones can easily be added by users\nA fitted model can be used to predict the behaviour of the material under other loading conditions, enabling the fit/predict paradigm of model selection\nArtificial loading conditions can be generated within RHEOS to better understand a model's response","category":"page"},{"location":"#Documentation-1","page":"Home","title":"Documentation","text":"","category":"section"},{"location":"#","page":"Home","title":"Home","text":"The sections in this documentation each aim to provide tutorials in different elements of RHEOS. The API section is a comprehensive list of RHEOS types and functions, and brief descriptions of their use. For corrections or further questions, please create an issue on the Github repository. Note that whenever you restart your Julia session you will have to reload RHEOS by typing using RHEOS, to avoid repetition this line is not included in every piece of example code.","category":"page"},{"location":"#Installation-1","page":"Home","title":"Installation","text":"","category":"section"},{"location":"#","page":"Home","title":"Home","text":"Install Julia, version 1.1.1\nFrom Julia REPL, enter pkg mode by pressing ]\n(Optional) Enable desired Project.toml environment\nRun the command add \"https://github.com/JuliaRheology/RHEOS.jl\"","category":"page"},{"location":"#Included-Dependencies-1","page":"Home","title":"Included Dependencies","text":"","category":"section"},{"location":"#[FastConv.jl](https://github.com/aamini/FastConv.jl)-1","page":"Home","title":"FastConv.jl","text":"","category":"section"},{"location":"#[MittagLeffler.jl](https://github.com/jlapeyre/MittagLeffler.jl)-1","page":"Home","title":"MittagLeffler.jl","text":"","category":"section"},{"location":"#Citation-1","page":"Home","title":"Citation","text":"","category":"section"},{"location":"#","page":"Home","title":"Home","text":"If you use RHEOS in your work, please consider citing the following paper TBA","category":"page"},{"location":"#References-1","page":"Home","title":"References","text":"","category":"section"},{"location":"#","page":"Home","title":"Home","text":"W. N. Findley, J. S. Lai, K. Onaran — Creep and Relaxation of Nonlinear Viscoelastic Materials (with an Introduction to Linear Viscoelasticity), Dover Publications, New York. (1976)\nS. G. Johnson — The NLopt nonlinear-optimization package, http://ab-initio.mit.edu/nlopt\nJ. Bezanson, A. Edelman, S. Karpinski, V. B. Shah — Julia: A Fresh Approach to Numerical Computing, SIAM Review, doi: 10.1137/141000671. (2017)","category":"page"},{"location":"API/#API-1","page":"API","title":"API","text":"","category":"section"},{"location":"API/#Sampling-and-Filtering-Functions-1","page":"API","title":"Sampling and Filtering Functions","text":"","category":"section"},{"location":"API/#","page":"API","title":"API","text":"resample\ncutting\nsmooth\nextract","category":"page"},{"location":"API/#RHEOS.resample","page":"API","title":"RHEOS.resample","text":"resample(self::RheoTimeData, elperiods::Union{Vector{K}, K}; time_boundaries::Union{Nothing, Vector{T}} = nothing)\n\nResample data with new sample rate(s).\n\nResample can downsample or upsample data. If the number of elperiods is negative it is going to reduce the number of samples, viceversa if it is positive. If time boundaries are not specified, resampling is applied to the whole set of data. If number of elements per period (elperiods) is 1 or -1 it returns the original RheoTimeData, whilst 0 is not accepted as a valid argument for elperiods.\n\n\n\n\n\n","category":"function"},{"location":"API/#RHEOS.cutting","page":"API","title":"RHEOS.cutting","text":"cutting(self::RheoTimeData, time_on::T1, time_off::T2) where {T1<:Number, T2<:Number}\n\nRemove the data outside a specified time interval.\n\nBy specifing a time interval (timeon, timeoff), a new RheoTimeData is returned without the data lying outside time interval.\n\n\n\n\n\n","category":"function"},{"location":"API/#RHEOS.smooth","page":"API","title":"RHEOS.smooth","text":"smooth(self::RheoTimeData, τ::Real; pad::String=\"reflect\")\n\nSmooth data using a Gaussian Kernel to time scale τ (approximately half power).\n\nSmooths both σ and ϵ. Sampling frequency must be constant as it is based on FFT convolution. Essentially a  low pass filter with frequencies of 1/τ being cut to approximately half power. For other pad types available  see ImageFiltering documentation. As of doc writing, pad options are: \"replicate\" (repeat edge values to  infinity), \"circular\" (image edges \"wrap around\"), \"symmetric\" (the image reflects relative to a position  between pixels), \"reflect\" (the image reflects relative to the edge itself).\n\n\n\n\n\n","category":"function"},{"location":"API/#RHEOS.extract","page":"API","title":"RHEOS.extract","text":"extract(self::Union{RheoTimeData,RheoFreqData}, type::Union{TimeDataType,FreqDataType,Integer})\n\nExtract specific fields form RheoTimeData or RheoFreqData.\n\nExtract can copy one or more fields from a given RheoXData variable into a new RheoXData one. The fields that are copied are identified by the specified type of data. If self is a RheoTimeData, the type that can be extracted is timeonly (or 0), stressonly (or 1), strainonly (or 2). Note that strainandstress (or 3) is not allowed. If self is a RheoFreqData, the type that can be extracted is freqonly (or 0).\n\n\n\n\n\n","category":"function"},{"location":"API/#Fitting-and-Predicting-Functions-1","page":"API","title":"Fitting and Predicting Functions","text":"","category":"section"},{"location":"API/#","page":"API","title":"API","text":"modelfit\nmodelpredict\nmodelstepfit\nmodelsteppredict\ndynamicmodelfit\ndynamicmodelpredict","category":"page"},{"location":"API/#RHEOS.modelfit","page":"API","title":"RHEOS.modelfit","text":"modelfit(data::RheoTimeData, model::RheoModelClass, modloading::Symbol; p0::Union{NamedTuple,Tuple} = (), lo::Union{NamedTuple,Tuple} = (), hi::Union{NamedTuple,Tuple} = (), verbose::Bool = false, rel_tol = 1e-4, diff_method=\"BD\")\n\nFit RheologyData struct to model and return a fitted model as a RheologyModel object.\n\nArguments\n\ndata: RheoTimeData struct containing all data\nmodel: RheoModelClass containing moduli functions and named tuple parameters\nmodloading: strainimposed or 1, stressimposed or 2\np0: Initial parameters to use in fit (uses 0.5 for all parameters if not defined)\nlo: Lower bounds for parameters\nhi: Upper bounds for parameters\nverbose: If true, prints parameters on each optimisation iteration\nrel_tol: Relative tolerance of optimization, see NLOpt docs for more details\ndiff_method: Set finite difference formula to use for derivative, currently \"BD\" or \"CD\"\n\n\n\n\n\n","category":"function"},{"location":"API/#RHEOS.modelpredict","page":"API","title":"RHEOS.modelpredict","text":"modelpredict(data::RheoTimeData,model::RheoModel; diff_method=\"BD\")\n\nGiven an incomplete data set (only either stress or strain missing) and model with values substituted into parameters (RheoModel),return a new dataset based on the model. If data is type of stressonly, then creep modulus (:J) is used; if data type is strainonly relaxation modulus (:G). A complete RheoTimeDatadata of type \"strainandstress\" is returned. 'diff_method' sets finite difference for calculating the derivative used in the hereditary integral and can be either backwards difference (\"BD\") or central difference (\"CD\").\n\n\n\n\n\n","category":"function"},{"location":"API/#RHEOS.modelstepfit","page":"API","title":"RHEOS.modelstepfit","text":"modelstepfit(data::RheoTimeData, model::RheoModelClass, modloading::Union{LoadingType,Integer}; step=nothing, p0::Union{NamedTuple,Tuple} = (), lo::Union{NamedTuple,Tuple} = (), hi::Union{NamedTuple,Tuple} = (), verbose::Bool = false, rel_tol = 1e-4) where T<:Real\n\nSame as 'modelfit' except assumes a step loading. If this assumption is appropriate for the data then fitting can be sped up greatly by use of this function. If modloading is strainimposed, relaxation modulus is used, then the element in the middle of the strain is assumed to be the amplitude of the step. If modloading is stressimposed, the creep modulus is used, then the middle element of the stress is assumed to be the amplitude of the step. Alternatively, it is possible to define the value of the step by defining the optional \"step\" parameter.\n\nArguments\n\ndata: RheoTimeData struct containing all data\nmodel: RheoModelClass containing moduli and parameters tuples\nmodloading: strainimposed for relaxation modulus, stressimposed for creep modulus\np0: Named tuple of initial parameters to use in fit (uses 0.5 for all parameters if none given)\nlo: Named tuple of lower bounds for parameters\nhi: Named tuple of upper bounds for parameters\nverbose: If true, prints parameters on each optimisation iteration\nrel_tol: Relative tolerance of optimization, see NLOpt docs for more details\ndiff_method: Set finite difference formula to use for derivative, currently \"BD\" or \"CD\"\n\n\n\n\n\n","category":"function"},{"location":"API/#RHEOS.modelsteppredict","page":"API","title":"RHEOS.modelsteppredict","text":"modelsteppredict(data::RheoTimeData, model::RheoModel; step_on::Real = 0.0, diff_method = \"BD\")\n\nSame as modelpredict but assumes a step loading with step starting at 'step_on'. Singularities are bypassed by adding 1 to the index of the singular element.\n\n\n\n\n\n","category":"function"},{"location":"API/#RHEOS.dynamicmodelfit","page":"API","title":"RHEOS.dynamicmodelfit","text":"dynamicmodelfit(data::RheoFreqData, model::RheoModelClass; p0::Union{NamedTuple,Tuple} = (), lo::Union{NamedTuple,Tuple} = (), hi::Union{NamedTuple,Tuple} = (), verbose::Bool = false, rel_tol = 1e-4) where T<:Real\n\nFits model to the frequency/loss+storage moduli data.\n\nAll arguments are as described below. As this fitting procedure is fitting two functions simultaneously (the storage and loss moduli), if left untransformed the fit would tend to favour the modulus which is larger in magnitude and not fit the other modulus well. To avoid this, RHEOS offers a number of data transforms which can be used by changing \"weights\" argument.\n\nArguments\n\ndata: RheoFreqData struct containing all data\nmodel: RheoModelClass containing moduli and symbols of parameters\np0: Initial parameters to use in fit (uses 0.5 for all parameters if none given)\nlo: Lower bounds for parameters\nhi: Upper bounds for parameters\nverbose: If true, prints parameters on each optimisation iteration\nrel_tol: Relative tolerance of optimization, see NLOpt docs for more details\nweights: Weighting mode for storage and loss modulus (linear, log, global)\n\n\n\n\n\n","category":"function"},{"location":"API/#RHEOS.dynamicmodelpredict","page":"API","title":"RHEOS.dynamicmodelpredict","text":"dynamicmodelpredict(data::RheoFreqData, model::RheoModel)\n\nGiven dynamic rheology data with only frequency and model where parameters have been substituted. Returns another RheoFreqData instance with the predicted Gp and Gpp based on the frequencies and model given as arguments.\n\n\n\n\n\n","category":"function"},{"location":"API/#Data-Generation-Functions-1","page":"API","title":"Data Generation Functions","text":"","category":"section"},{"location":"API/#","page":"API","title":"API","text":"timeline\nstrainfunction\nstressfunction\nhstep\nramp\nstairs\nsquare\nsawtooth\ntriangle\nfrequencyspec","category":"page"},{"location":"API/#RHEOS.timeline","page":"API","title":"RHEOS.timeline","text":"timeline(;t_start::Real=0., t_end::Real=10., step::Real=(t_end - t_start)/250.)\n\nGenerate RheoTimeData struct with only the time data.\n\nArguments\n\nt_start: Starting time, typically 0\nt_end: End time\nstep: Time between sample\n\n\n\n\n\n","category":"function"},{"location":"API/#RHEOS.strainfunction","page":"API","title":"RHEOS.strainfunction","text":"strainfunction(data::RheoTimeData, f::T) where T<:Function\n\nAccepts a RheoTimeData and outputs a new RheoTimeData with a strain imposed. The strain signal is determined by the function provided, which should take time as its only argument. The original data's time signal is used.\n\nNormally used with a RheoTimeData generated using the timeline function.\n\n\n\n\n\n","category":"function"},{"location":"API/#RHEOS.stressfunction","page":"API","title":"RHEOS.stressfunction","text":"stressfunction(data::RheoTimeData, f::T) where T<:Function\n\nAccepts a RheoTimeData and outputs a new RheoTimeData with a stress imposed. The stress signal is determined by the function provided, which should take time as its only argument. The original data's time signal is used.\n\nNormally used with a RheoTimeData generated using the timeline function.\n\n\n\n\n\n","category":"function"},{"location":"API/#RHEOS.hstep","page":"API","title":"RHEOS.hstep","text":"hstep(t; offset=0., amp=1.)\n\nStep generation function for use with stressfunction or strainfunction. offset keyword arguent determines start of step. amp argument determines amplitude (height) of step.\n\n\n\n\n\n","category":"function"},{"location":"API/#RHEOS.ramp","page":"API","title":"RHEOS.ramp","text":"ramp(t; offset=0., gradient=1.)\n\nRamp signal generation function for use with stressfunction or strainfunction. offset keyword arguent determines start of ramp. gradient argument determines the linear gradient of the ramp.\n\n\n\n\n\n","category":"function"},{"location":"API/#RHEOS.stairs","page":"API","title":"RHEOS.stairs","text":"stairs(t; offset=0., amp=1., width=1.)\n\nStairs signal generation function for use with stressfunction or strainfunction. Equivalent to additional steps being added every width seconds. offset keyword arguent determines start of stairs signal. amp argument determines the height of each additional step.\n\n\n\n\n\n","category":"function"},{"location":"API/#RHEOS.square","page":"API","title":"RHEOS.square","text":"square(t; offset=0., amp=1., period=1., width=0.5*period)\n\nSquare signal generation function for use with stressfunction or strainfunction. offset keyword arguent determines start of square signal. amp argument determines the height of each square pulse. period determines the period of one off/on section of the square wave signal. width determines the width of each square pulse.\n\n\n\n\n\n","category":"function"},{"location":"API/#RHEOS.sawtooth","page":"API","title":"RHEOS.sawtooth","text":"sawtooth(t; offset=0., amp=1., period=1.)\n\nSawtooth signal generation function for use with stressfunction or strainfunction. offset keyword arguent determines start of sawtooth signal. amp argument determines the height of each sawtooth pulse. period determines the period of the sawtooth wave signal.\n\n\n\n\n\n","category":"function"},{"location":"API/#RHEOS.triangle","page":"API","title":"RHEOS.triangle","text":"triangle(t; offset=0., amp=1., period=1.)\n\nTriangle signal generation function for use with stressfunction or strainfunction. offset keyword arguent determines start of triangle signal. amp argument determines the height of each triangle pulse. period determines the period of the triangle wave signal. width determines the width of the triangles.\n\n\n\n\n\n","category":"function"},{"location":"API/#RHEOS.frequencyspec","page":"API","title":"RHEOS.frequencyspec","text":"frequencyspec(;ω_start::Real=1.0e-2, ω_end::Real=1.0e2, step::Real=(ω_end-ω_start)/1.0e5)\n\nGenerate RheoFreqData struct with only the frequency data.\n\nArguments\n\nω_start: Starting time, typically 0\nω_end: End time\nstep: Step between frequencies\n\n\n\n\n\n","category":"function"},{"location":"API/#Data-IO-1","page":"API","title":"Data IO","text":"","category":"section"},{"location":"API/#","page":"API","title":"API","text":"importcsv\nexportcsv","category":"page"},{"location":"API/#RHEOS.importcsv","page":"API","title":"RHEOS.importcsv","text":"importcsv(filepath::String; t_col::IntOrNone = nothing, σ_col::IntOrNone = nothing, ϵ_col::IntOrNone = nothing, ω_col::IntOrNone = nothing, Gp_col::IntOrNone = nothing, Gpp_col::IntOrNone = nothing, delimiter=',')\n\nLoad data from a CSV file (two/three columns, comma seperated by default but delimiter can be specified in the delimiter keyword argument). Arguments must be identified by providing the number of the column in which they are contained.\n\nCan be used to construct either a RheoTimeData instance or a RheoFreqData instance. Function detects whether \"time\" or \"frequency\" has been included and proceeds accordingly. For oscillatory data, all three columns (Gp, Gpp, Frequency) must be provided. For regular viscoelastic data only time, or time-stress, or time-strain or time-stress-strain data can be provided.\n\n\n\n\n\n","category":"function"},{"location":"API/#RHEOS.exportcsv","page":"API","title":"RHEOS.exportcsv","text":"exportcsv(self::Union{RheoTimeData, RheoFreqData}, filedir::String; delimiter=',', colorder=nothing)\n\nExport RheoTimeData or RheoFreqData type to csv format. May be useful for plotting/analysis in other software. By default, full time data will be exported with columns ordered as (σ, ϵ, t). Partial time data will be ordered as either (σ, t) or (ϵ, t). Full frequency data will be ordered as (Gp, Gpp, ω). The order of columns can be customised by passing a NamedTuple to the colorder arguments. For example (σ = 2, t = 1, ϵ = 3) would export the columns in the order (t, σ, ϵ). As with importcsv, the delimiter can be set by keyword argument.\n\n\n\n\n\n","category":"function"}]
}
