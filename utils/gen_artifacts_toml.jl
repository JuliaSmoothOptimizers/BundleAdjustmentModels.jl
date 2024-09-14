# Part of the code directly copied from Pkg doc : https://pkgdocs.julialang.org/v1/artifacts/
# sha256 sum and other code copied from https://github.com/simeonschaub/ArtifactUtils.jl/blob/main/src/ArtifactUtils.jl

using Pkg.Artifacts
using Pkg.PlatformEngines
using SHA
import Pkg.GitTools.tree_hash
import Base.SHA1

include("../src/BundleAdjustmentProblemsList.jl")

const artifact_toml = joinpath(@__DIR__, "..", "Artifacts.toml")

const ba_url = "https://grail.cs.washington.edu/projects/bal/data"

fails = String[]

function sha256sum(path)
  open(path, "r") do io
    return bytes2hex(sha256(io))
  end
end

function ba_sha1(path)
  return SHA1(tree_hash(path))
end

lazybool = true
forcebool = true
global k = 0

for probs_symbol ∈ ba_groups
  problems = eval(probs_symbol)
  group = string(probs_symbol)
  for problem ∈ problems
    global k = k + 1
    url = "$ba_url/$group/$problem"
    @info "Problem $problem of the group $group -- $url"
    try
      problem_hash = artifact_hash("$group/$problem", artifact_toml)
      # If the name was not bound, or the hash it was bound to does not exist, create it!
      if problem_hash === nothing || !artifact_exists(problem_hash)
        # download the artifact in a temporary folder and compute its sha256
        isdir("tmp_pb$k") && rm("tmp_pb$k", recursive = true, force = true)
        mkdir("tmp_pb$k")
        path_folder_artifact = joinpath(@__DIR__, "tmp_pb$k")
        path_artifact = joinpath(path_folder_artifact, problem)
        download(url, path_artifact)
        hash_artifact = sha256sum(path_artifact)

        # Extract the archive *.bz2 such that we can compute the git-tree-sha1
        run(`bzip2 -d $(path_artifact)`)
        problem_hash = ba_sha1(path_folder_artifact)
        rm("tmp_pb$k", recursive = true, force = true)

        # Now bind that hash within our `Artifacts.toml`.
        # `force = true` means that if it already exists, just overwrite with the new content-hash.
        # Unless the source files change, we do not expect the content hash to change,
        # so this should not cause unnecessary version control churn.
        bind_artifact!(
          artifact_toml,
          "$group/$problem",
          problem_hash,
          download_info = [(url, hash_artifact)],
          lazy = lazybool,
          force = forcebool,
        )
      end
    catch
      push!(fails, problem)
    end
  end
end
length(fails) > 0 && @warn "the following matrices could not be downloaded" fails
