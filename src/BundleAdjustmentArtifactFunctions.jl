import Base.SHA1, Pkg.PlatformEngines.download_verify

export problems_df,
  get_first_name_and_group,
  fetch_ba_name,
  fetch_ba_group,
  BundleAdjustmentModel,
  delete_ba_artifact!,
  delete_all_ba_artifacts!

const ba_probs_jld2 = joinpath(@__DIR__, "..", "src", "ba_probs_df.jld2")

"""
    problems_df()
    
Return a dataframe of the problems and their characteristics
"""
function problems_df()
  file = jldopen(ba_probs_jld2, "r")
  ba_probs = file["df"]
  close(file)
  return ba_probs
end

"""
    get_first_name_and_group(dataframe::DataFrame)

Return the name and the group of the first row in the DataFrame
"""
function get_first_name_and_group(dataframe::DataFrame)
  name = dataframe[1, :name]
  group = dataframe[1, :group]
  return name, group
end

"""
    get_filename(name::AbstractString, group::AbstractString)

Analyze the `name` and `group` given to check if they match the names and groups known
Return the corrected name if needed
"""
function get_filename(name::AbstractString, group::AbstractString)
  if name[(end - 2):end] == "bz2"
    filename = name
  elseif name[(end - 2):end] == "txt"
    filename = name * ".bz2"
  elseif name[(end - 2):end] == "pre"
    filename = name * ".txt.bz2"
  elseif occursin(r"^[0-9]{64}$"i, name[(end - 3):end])
    filename = name * "-pre.txt.bz2"
  else
    error("Cannot recognize $(name)")
  end

  if !(group in string.(ba_groups))
    error("Cannot recognize $(group)")
  end

  return filename
end

"""
    fetch_ba_name(name::AbstractString, group::AbstractString)

Get the problem with name `name` from the group `group`.
Return the path where the problem is stored.
"""
function fetch_ba_name(name::AbstractString, group::AbstractString)
  filename = get_filename(name, group)

  artifact_name = "$(group)/$(filename)"
  loc = ba_ensure_artifact_installed(
    filename,
    artifact_name,
    joinpath(@__DIR__, "..", "Artifacts.toml"),
  )

  return loc
end

fetch_ba_name(problem::NamedTuple) = fetch_ba_name(problem[1], problem[2])

fetch_ba_name(problem::DataFrameRow) = fetch_ba_name(copy(problem))

"""
    fetch_ba_group(group::AbstractString)

Get all the problems with the group name `group`.
Return an array of the paths where the problems are stored.
Group possibilities are : trafalgar, venice, dubrovnik and ladybug
"""
function fetch_ba_group(group::AbstractString)
  problem_paths = String[]
  for problem ∈ eval(Symbol(group))
    problem_path = fetch_ba_name(problem, group)
    push!(problem_paths, problem_path)
  end
  return problem_paths
end

"""
    BundleAdjustmentModel(name::AbstractString, group::AbstractString, T::Type=Float64)

Alternate constructor of BundleAdjustmentModel
Get the path of the problem name `name` from the group `group` with the precision `T`.
Return a NLSModel generated from this problem data using NLPModels
"""
function BundleAdjustmentModel(name::AbstractString, group::AbstractString; T::Type = Float64)
  filename = get_filename(name, group)

  filedir = fetch_ba_name(filename, group)
  path_and_filename = joinpath(filedir, filename)

  return BundleAdjustmentModel(path_and_filename, T = T)
end

BundleAdjustmentModel(problem::NamedTuple; T::Type = Float64) = BundleAdjustmentModel(problem[1], problem[2]; T)

BundleAdjustmentModel(problem::DataFrameRow; T::Type = Float64) = BundleAdjustmentModel(copy(problem); T)

# DEFAULT_IO, stderr_f and can_fancyprint copied from
# https://github.com/JuliaLang/Pkg.jl/blob/master/src/Pkg.jl
const DEFAULT_IO = Ref{Union{IO, Nothing}}(nothing)
stderr_f() = something(DEFAULT_IO[], stderr)
can_fancyprint(io::IO) = (io isa Base.TTY) && (get(ENV, "CI", nothing) != "true")

# Big parts of code copied from ensure_artifact_installed
# https://github.com/JuliaLang/Pkg.jl/blob/master/src/Artifacts.jl
"""
    ba_ensure_artifact_installed(filename::String, artifact_name::String, artifacts_toml::String;
                                    platform::AbstractPlatform = HostPlatform(),
                                    pkg_uuid::Union{Base.UUID,Nothing}=nothing,
                                    verbose::Bool = false,
                                    quiet_download::Bool = false,
                                    io::IO=stderr)

Ensures an artifact is installed, downloading it via the download information stored in
`artifacts_toml` if necessary.  Throws an error if unable to install.
The modifications from the original functions are here to avoid unpacking the archive
and avoid checking from official repository since these files are not official artifacts.
"""
function ba_ensure_artifact_installed(
  filename::String,
  artifact_name::String,
  artifacts_toml::String;
  pkg_uuid::Union{Base.UUID, Nothing} = nothing,
  verbose::Bool = false,
  quiet_download::Bool = false,
  io::IO = stderr_f(),
)
  meta = artifact_meta(artifact_name, artifacts_toml; pkg_uuid = pkg_uuid)

  if meta === nothing
    error("Cannot locate artifact '$(artifact_name)' in '$(artifacts_toml)'")
  end

  hash = SHA1(meta["git-tree-sha1"])

  if !artifact_exists(hash)
    for entry in meta["download"]
      url = entry["url"]
      tarball_hash = entry["sha256"]
      download_success = ba_download_artifact(
        filename,
        hash,
        url,
        tarball_hash;
        verbose = verbose,
        quiet_download = quiet_download,
        io = io,
      )
      download_success && return artifact_path(hash)
      error("Unable to automatically install '$(artifact_name)' from '$(artifacts_toml)'")
    end
  else
    return artifact_path(hash)
  end
end

# Big parts of code copied from ensure_artifact_installed
# https://github.com/JuliaLang/Pkg.jl/blob/master/src/Artifacts.jl
"""
    ba_download_artifact(tree_hash::SHA1, tarball_url::String, tarball_hash::String;
                      verbose::Bool = false, io::IO=stderr)

Download/install an artifact into the artifact store.  Returns `true` on success.
The modifications from the original functions are here to avoid unpacking the archive
and avoid checking from official repository since these files are not official artifacts.
"""
function ba_download_artifact(
  filename::String,
  tree_hash::SHA1,
  tarball_url::String,
  tarball_hash::Union{String, Nothing} = nothing;
  verbose::Bool = false,
  quiet_download::Bool = false,
  io::IO = stderr_f(),
)
  if artifact_exists(tree_hash)
    return true
  end

  if Sys.iswindows()
    # The destination directory we're hoping to fill:
    dest_dir = artifact_path(tree_hash; honor_overrides = false)
    mkpath(dest_dir)

    # On Windows, we have some issues around stat() and chmod() that make properly
    # determining the git tree hash problematic; for this reason, we use the "unsafe"
    # artifact unpacking method, which does not properly verify unpacked git tree
    # hash.  This will be fixed in a future Julia release which will properly interrogate
    # the filesystem ACLs for executable permissions, which git tree hashes care about.
    try
      download_verify(
        tarball_url,
        tarball_hash,
        joinpath(dest_dir, "$filename"),
        verbose = verbose,
        quiet_download = quiet_download,
      )
    catch err
      @error "download_artifact error" tree_hash tarball_url tarball_hash err
      # Clean that destination directory out if something went wrong
      rm(dest_dir; force = true, recursive = true)

      if isa(err, InterruptException)
        rethrow(err)
      end
      return false
    end
  else
    # We download by using `create_artifact()`.  We do this because the download may
    # be corrupted or even malicious; we don't want to clobber someone else's artifact
    # by trusting the tree hash that has been given to us; we will instead download it
    # to a temporary directory, calculate the true tree hash, then move it to the proper
    # location only after knowing what it is, and if something goes wrong in the process,
    # everything should be cleaned up.  Luckily, that is precisely what our
    # `create_artifact()` wrapper does, so we use that here.

    # Removed the calc_hash because there is already a verification on the content of the
    # file with download_verify in temp directory and calc_hash calculates the the hash of 
    # the temp directory which seems to be random or at least not consistent enough the way
    # I implemented it in the generation of the artifacts_toml. That being said, wrapping 
    # in create_artifact() is still useful because if there is a hash missmatch the directory
    # and files are deleted
    calc_hash = try
      create_artifact() do dir
        # In case we successfully download the file and the verification works
        # we can move it to the safe location
        download_verify(
          tarball_url,
          tarball_hash,
          joinpath(dir, "$filename"),
          verbose = verbose,
          quiet_download = quiet_download,
        )
        #= dest_dir = artifact_path(tree_hash; honor_overrides=false)
        mkpath(dest_dir)
        mv(joinpath(dir, "$filename"), joinpath(dest_dir, "$filename")) =#
      end
    catch err
      @error "download_artifact error" tree_hash tarball_url tarball_hash err
      if isa(err, InterruptException)
        rethrow(err)
      end
      # If something went wrong during download, return false
      return false
    end

    # Removed calc_hash and the reasons mentioned earlier, so the next lines of code don't work
    # There is a verification on the content of the file but just not on the destination
    # which is tree_hash by default with this code, so we simply force the mv function 
    # Another solution without moving artifacts twice might be slightly faster but less generic for now

    # Did we get what we expected?  If not, freak out.
    #= if calc_hash.bytes != tree_hash.bytes
        msg  = "Tree Hash Mismatch!\n"
        msg *= "  Expected git-tree-sha1:   $(bytes2hex(tree_hash.bytes))\n"
        msg *= "  Calculated git-tree-sha1: $(bytes2hex(calc_hash.bytes))"
        # Since tree hash calculation is still broken on some systems, e.g. Pkg.jl#1860,
        # and Pkg.jl#2317 so we allow setting JULIA_PKG_IGNORE_HASHES=1 to ignore the
        # error and move the artifact to the expected location and return true
        ignore_hash = get(ENV, "JULIA_PKG_IGNORE_HASHES", nothing) == "1"
        if ignore_hash
            msg *= "\n\$JULIA_PKG_IGNORE_HASHES is set to 1: ignoring error and moving artifact to the expected location"
        end
        @error(msg)
        if ignore_hash
            # Move it to the location we expected
            src = artifact_path(calc_hash; honor_overrides=false)
            dst = artifact_path(tree_hash; honor_overrides=false)
            mv(src, dst; force=true)
            return true
        end
        return false
    end =#
    # Move it to the location we expected
    src = artifact_path(calc_hash; honor_overrides = false)
    dst = artifact_path(tree_hash; honor_overrides = false)
    mv(src, dst; force = true)

    return true
  end

  return true
end

"""
    delete_ba_artifact!(name::AbstractString, group::AbstractString)

Delete the artifact `name` from the artifact store
"""
function delete_ba_artifact!(name::AbstractString, group::AbstractString)
  filename = get_filename(name, group)

  artifacts_toml = joinpath(@__DIR__, "..", "Artifacts.toml")

  meta = artifact_meta("$(group)/$(filename)", artifacts_toml)

  if meta === nothing
    error("Cannot locate artifact '$(filename)' in '$(artifacts_toml)'")
  end

  hash = SHA1(meta["git-tree-sha1"])

  if !artifact_exists(hash)
    @info "The artifact $(group)/$(filename) was not found"
  else
    path = artifact_path(hash)
    rm(path, recursive = true)
    @info "The artifact $(group)/$(filename) has been deleted"
  end
end

"""
    delete_all_ba_artifacts!()

Delete all the BundleAdjustmentModels artifacts from the artifact store
"""
function delete_all_ba_artifacts!()
  for probs_symbol ∈ ba_groups
    problems = eval(probs_symbol)
    group = string(probs_symbol)
    for problem ∈ problems
      delete_ba_artifact!(problem, group)
    end
  end
end
