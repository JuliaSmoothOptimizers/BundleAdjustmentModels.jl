using BundleAdjustmentModels, DataFrames, LinearAlgebra, NLPModels, Pkg, Test, BenchmarkTools

if VERSION ≤ VersionNumber(1, 6, 0)
  Pkg.PlatformEngines.probe_platform_engines!()
end

include("testBundleAdjustmentModels.jl")
include("testBundleAdjustmentAllocations.jl")
