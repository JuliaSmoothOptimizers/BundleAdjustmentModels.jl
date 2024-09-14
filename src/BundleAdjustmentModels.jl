module BundleAdjustmentModels

using Pkg.Artifacts,
  Pkg.PlatformEngines, NLPModels, .Threads, CodecBzip2, SHA, DataFrames, JLD2, LinearAlgebra

const ba_jld2 = joinpath(@__DIR__, "ba_probs_df.jld2")
const ba_artifacts = joinpath(@__DIR__, "..", "Artifacts.toml") |> normpath

include("BundleAdjustmentProblemsList.jl")
include("BundleAdjustmentNLSFunctions.jl")
include("BundleAdjustmentArtifactFunctions.jl")
include("ReadFiles.jl")
include("JacobianByHand.jl")

end
