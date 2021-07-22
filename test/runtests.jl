using BALNLSModels, Test, NLPModels, DataFrames, Pkg

Pkg.PlatformEngines.probe_platform_engines!()

include("../src/BALProblemsList.jl")
include("testBALNLSFunctions.jl")
