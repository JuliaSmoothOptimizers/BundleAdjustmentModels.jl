using BALNLSModels, Test, NLPModels, DataFrames, Pkg

if VERSION ≤ VersionNumber(1,6,0)
    Pkg.PlatformEngines.probe_platform_engines!()
end

include("../src/BALProblemsList.jl")
include("testBALNLSFunctions.jl")
