import Base.SHA1, Pkg.PlatformEngines.download_verify

export fetch_bal_name, fetch_bal_group, BALNLSModel

"""
    analyze_name_and_group(name::AbstractString, group::AbstractString)

Analyze the `name` and `group` given to check if they match the names and groups known
"""
function analyze_name_and_group(name::AbstractString, group::AbstractString)
  if name[end-2:end] == "bz2"
    real_name = name
  elseif name[end-2:end] == "txt"
    real_name = name*".bz2"
  elseif name[end-2:end] == "pre"
    real_name = name*".txt.bz2"
  elseif oococcursin(r"^[0-9]{64}$"i, name[end-3:end])
    real_name = name*"-pre.txt.bz2"
  else
    error("Cannot recognize $(name)")
  end

  if !(group in ["trafalgar", "dubrovnik", "venice", "ladybug"])
    error("Cannot recognize $(group)")
  end

  return real_name, group
end

"""
    analyze_group(group::AbstractString)

Analyze the `group` given to check if it matches the groups known.
If so, return an array with the corresponding problems
"""
function analyze_group(group::AbstractString)

  if group == "dubrovnik"
    real_group = dubrovnik_prob
  elseif group == "trafalgar"
    real_group = trafalgar_prob
  elseif group == "ladybug"
    real_group = ladybug_prob
  elseif group == "venice"
    real_group = venice_prob
  else
    error("Cannot recognize $(group)")
  end

  return real_group
end

"""
    fetch_bal_name(name::AbstractString, group::AbstractString)

Get the problem with name `name` from the group `group`.
Return the path where the problem is stored.
"""
function fetch_bal_name(name::AbstractString, group::AbstractString)

  real_name, group = analyze_name_and_group(name, group)

  final_name = "$group/$real_name"
  loc = cust_ensure_artifact_installed(real_name, final_name, joinpath(@__DIR__, "..", "Artifacts.toml"))

  return loc
end

"""
    fetch_bal_group(group::AbstractString)

Get all the problems with the group name `group`.
Return an array of the paths where the problems are stored.
"""
function fetch_bal_group(group::AbstractString)

  real_group = analyze_group(group)

  problem_paths = String[]
  for problem ∈ real_group
    problem_path = fetch_bal_name(problem, group)
    push!(problem_paths, problem_path)
  end
  return problem_paths
end


"""
    BALNLSModel(name::AbstractString, group::AbstractString, T::Type=Float64)

Alternate constructor of BALNLSModel
Get the path of the problem name `name` from the group `group` with the precision `T`.
Return a NLSModel generated from this problem data using NLPModels
"""
function BALNLSModel(name::AbstractString, group::AbstractString; T::Type=Float64)

  real_name, group = analyze_name_and_group(name, group)

  filedir = fetch_bal_name(real_name, group)
  filename = joinpath(filedir, real_name)

  return BALNLSModel(filename, T=T)
end


# DEFAULT_IO, stderr_f and can_fancyprint copied from
# https://github.com/JuliaLang/Pkg.jl/blob/master/src/Pkg.jl
const DEFAULT_IO = Ref{Union{IO,Nothing}}(nothing)
stderr_f() = something(DEFAULT_IO[], stderr)
can_fancyprint(io::IO) = (io isa Base.TTY) && (get(ENV, "CI", nothing) != "true")

# Big parts of code copied from ensure_artifact_installed
# https://github.com/JuliaLang/Pkg.jl/blob/master/src/Artifacts.jl
"""
    cust_ensure_artifact_installed(name::String, artifacts_toml::String;
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
function cust_ensure_artifact_installed(real_name::String,
                                        name::String, 
                                        artifacts_toml::String, 
                                        pkg_uuid::Union{Base.UUID,Nothing}=nothing,
                                        verbose::Bool = false,
                                        quiet_download::Bool = false,
                                        io::IO=stderr_f())

  meta = artifact_meta(name, artifacts_toml; pkg_uuid=pkg_uuid)

  if meta === nothing
      error("Cannot locate artifact '$(name)' in '$(artifacts_toml)'")
  end

  hash = SHA1(meta["git-tree-sha1"])

  if !artifact_exists(hash)
    for entry in meta["download"]
      url = entry["url"]
      tarball_hash = entry["sha256"]
      download_success = cust_download_artifact(real_name, hash, url, tarball_hash; verbose=verbose, quiet_download=quiet_download, io=io)
      download_success && return artifact_path(hash)
      error("Unable to automatically install '$(name)' from '$(artifacts_toml)'")
    end
  else
    return artifact_path(hash)
  end
end

# Big parts of code copied from ensure_artifact_installed
# https://github.com/JuliaLang/Pkg.jl/blob/master/src/Artifacts.jl
"""
    download_artifact(tree_hash::SHA1, tarball_url::String, tarball_hash::String;
                      verbose::Bool = false, io::IO=stderr)

Download/install an artifact into the artifact store.  Returns `true` on success.
The modifications from the original functions are here to avoid unpacking the archive
and avoid checking from official repository since these files are not official artifacts.
"""
function cust_download_artifact(
  real_name::String,
  tree_hash::SHA1,
  tarball_url::String,
  tarball_hash::Union{String, Nothing} = nothing;
  verbose::Bool = false,
  quiet_download::Bool = false,
  io::IO=stderr_f(),
)
  if artifact_exists(tree_hash)
      return true
  end

  if Sys.iswindows()
      # The destination directory we're hoping to fill:
      dest_dir = artifact_path(tree_hash; honor_overrides=false)
      mkpath(dest_dir)

      # On Windows, we have some issues around stat() and chmod() that make properly
      # determining the git tree hash problematic; for this reason, we use the "unsafe"
      # artifact unpacking method, which does not properly verify unpacked git tree
      # hash.  This will be fixed in a future Julia release which will properly interrogate
      # the filesystem ACLs for executable permissions, which git tree hashes care about.
      try
          #cust_download_verify(real_name, tarball_url, tarball_hash, dest_dir, quiet_download=true)
          download_verify(tarball_url, tarball_hash, joinpath(dest_dir, "$real_name"))
      catch err
          @debug "download_artifact error" tree_hash tarball_url tarball_hash err
          # Clean that destination directory out if something went wrong
          rm(dest_dir; force=true, recursive=true)

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
              download_verify(tarball_url, tarball_hash, joinpath(dir, "$real_name"))
                  #= dest_dir = artifact_path(tree_hash; honor_overrides=false)
                  mkpath(dest_dir)
                  mv(joinpath(dir, "$real_name"), joinpath(dest_dir, "$real_name")) =#
          end
      catch err
          @debug "download_artifact error" tree_hash tarball_url tarball_hash err
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
      src = artifact_path(calc_hash; honor_overrides=false)
      dst = artifact_path(tree_hash; honor_overrides=false)
      mv(src, dst; force=true)
      
      return true
  end

  return true
end
