# Part of the code directly copied from Pkg doc : https://pkgdocs.julialang.org/v1/artifacts/
# sha256 sum and other code copied from https://github.com/simeonschaub/ArtifactUtils.jl/blob/main/src/ArtifactUtils.jl
# Don't forget to mention in the license with license for BAL problems

using Pkg.Artifacts
using Pkg.PlatformEngines
using SHA
import Base.SHA1

dubrovnik_prob = ["problem-16-22106-pre.txt.bz2",
                  "problem-88-64298-pre.txt.bz2",
                  "problem-135-90642-pre.txt.bz2",
                  "problem-142-93602-pre.txt.bz2",
                  "problem-150-95821-pre.txt.bz2",
                  "problem-161-103832-pre.txt.bz2",
                  "problem-173-111908-pre.txt.bz2",
                  "problem-182-116770-pre.txt.bz2",
                  "problem-202-132796-pre.txt.bz2",
                  "problem-237-154414-pre.txt.bz2",
                  "problem-253-163691-pre.txt.bz2",
                  "problem-262-169354-pre.txt.bz2",
                  "problem-273-176305-pre.txt.bz2",
                  "problem-287-182023-pre.txt.bz2",
                  "problem-308-195089-pre.txt.bz2",
                  "problem-356-226730-pre.txt.bz2"]


trafalgar_prob = ["problem-21-11315-pre.txt.bz2",
                  "problem-39-18060-pre.txt.bz2",
                  "problem-50-20431-pre.txt.bz2",
                  "problem-126-40037-pre.txt.bz2",
                  "problem-138-44033-pre.txt.bz2",
                  "problem-161-48126-pre.txt.bz2",
                  "problem-170-49267-pre.txt.bz2",
                  "problem-174-50489-pre.txt.bz2",
                  "problem-193-53101-pre.txt.bz2",
                  "problem-201-54427-pre.txt.bz2",
                  "problem-206-54562-pre.txt.bz2",
                  "problem-215-55910-pre.txt.bz2",
                  "problem-225-57665-pre.txt.bz2",
                  "problem-257-65132-pre.txt.bz2"]

ladybug_prob = ["problem-49-7776-pre.txt.bz2",
                "problem-73-11032-pre.txt.bz2",
                "problem-138-19878-pre.txt.bz2",
                "problem-318-41628-pre.txt.bz2",
                "problem-372-47423-pre.txt.bz2",
                "problem-412-52215-pre.txt.bz2",
                "problem-460-56811-pre.txt.bz2",
                "problem-539-65220-pre.txt.bz2",
                "problem-598-69218-pre.txt.bz2",
                "problem-646-73584-pre.txt.bz2",
                "problem-707-78455-pre.txt.bz2",
                "problem-783-84444-pre.txt.bz2",
                "problem-810-88814-pre.txt.bz2",
                "problem-856-93344-pre.txt.bz2",
                "problem-885-97473-pre.txt.bz2",
                "problem-931-102699-pre.txt.bz2",
                "problem-969-105826-pre.txt.bz2",
                "problem-1031-110968-pre.txt.bz2",
                "problem-1064-113655-pre.txt.bz2",
                "problem-1118-118384-pre.txt.bz2",
                "problem-1152-122269-pre.txt.bz2",
                "problem-1197-126327-pre.txt.bz2",
                "problem-1235-129634-pre.txt.bz2",
                "problem-1266-132593-pre.txt.bz2",
                "problem-1340-137079-pre.txt.bz2",
                "problem-1469-145199-pre.txt.bz2",
                "problem-1514-147317-pre.txt.bz2",
                "problem-1587-150845-pre.txt.bz2",
                "problem-1642-153820-pre.txt.bz2",
                "problem-1695-155710-pre.txt.bz2"]

venice_prob = ["problem-52-64053-pre.txt.bz2",
               "problem-89-110973-pre.txt.bz2",
               "problem-245-198739-pre.txt.bz2",
               "problem-427-310384-pre.txt.bz2",
               "problem-744-543562-pre.txt.bz2",
               "problem-951-708276-pre.txt.bz2",
               "problem-1102-780462-pre.txt.bz2",
               "problem-1158-802917-pre.txt.bz2",
               "problem-1184-816583-pre.txt.bz2",
               "problem-1238-843534-pre.txt.bz2",
               "problem-1288-866452-pre.txt.bz2",
               "problem-1350-894716-pre.txt.bz2",
               "problem-1408-912229-pre.txt.bz2",
               "problem-1778-993923-pre.txt.bz2"]

total_prob = [[dubrovnik_prob, "dubrovnik"], [trafalgar_prob, "trafalgar"], [ladybug_prob, "ladybug"], [venice_prob, "venice"]]

const artifact_toml = joinpath(@__DIR__, "..", "Artifacts.toml")
               
const bal_url = "https://grail.cs.washington.edu/projects/bal/data"

fails = String[]

function sha256sum(path)
    return open(path, "r") do io
        return bytes2hex(sha256(io))
    end
end

lazybool = true
forcebool = true

for problem_categ ∈ total_prob
    for problem ∈ problem_categ[1]
        category = problem_categ[2]
        url = "$bal_url/$category/$problem"
        println(problem)
        println(url)
        #try
            problem_hash = artifact_hash("$category/$problem", artifact_toml)
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
                bind_artifact!(artifact_toml, 
                               "$category/$problem", 
                               problem_hash, 
                               download_info = [(url, hash_artifact)],
                               lazy = lazybool,
                               force = forcebool)
            end
        #= catch
            push!(fails, problem)
        end =#
    end
end
length(fails) > 0 && @warn "the following matrices could not be downloaded" fails
