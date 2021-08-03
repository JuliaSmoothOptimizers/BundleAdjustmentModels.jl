# Part of the code directly copied from Pkg doc : https://pkgdocs.julialang.org/v1/artifacts/
# sha256 sum and other code copied from https://github.com/simeonschaub/ArtifactUtils.jl/blob/main/src/ArtifactUtils.jl

using Pkg.Artifacts
using Pkg.PlatformEngines
using SHA
import Base.SHA1

include("../src/BundleAdjustmentProblemsList.jl")

const artifact_toml = joinpath(@__DIR__, "..", "Artifacts.toml")

const ba_url = "https://grail.cs.washington.edu/projects/bal/data"

fails = String[]

function sha256sum(path)
  return open(path, "r") do io
    return bytes2hex(sha256(io))
  end
end

lazybool = true
forcebool = true

for probs_symbol ∈ ba_groups
  problems = eval(probs_symbol)
  group = string(probs_symbol)
  for problem ∈ problems
    url = "$ba_url/$group/$problem"
    println(problem)
    println(url)
    try
      problem_hash = artifact_hash("$group/$problem", artifact_toml)
      # If the name was not bound, or the hash it was bound to does not exist, create it!
      if problem_hash === nothing || !artifact_exists(problem_hash)
        # create_artifact() returns the content-hash of the artifact directory once we're finished creating it
        problem_hash = create_artifact() do artifact_dir
          # We create the artifact by simply downloading a few files into the new artifact directory
          println(joinpath(artifact_dir, "$problem"))
          download("$url", joinpath(artifact_dir, "$problem"))
        end

        path_artifact = artifact_path(problem_hash)
        hash_artifact = sha256sum("$path_artifact/$problem")
        remove_artifact(problem_hash)

        # Now bind that hash within our `Artifacts.toml`.  `force = true` means that if it already exists,
        # just overwrite with the new content-hash.  Unless the source files change, we do not expect
        # the content hash to change, so this should not cause unnecessary version control churn.
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
