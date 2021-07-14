import Base.SHA1, Pkg.PlatformEngines.download_verify

export fetch_bal_name, fetch_bal_group, generate_NLSModel

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

"""
fetch_bal_name(name::AbstractString, group::AbstractString)
Get the problem with name `name` from the group `group`.
Return the path where the problem is stored.
"""
function fetch_bal_name(name::AbstractString, group::AbstractString)
  real_name = ""
  try
    if name[end-2:end] == "bz2"
      real_name = name
    elseif name[end-2:end] == "txt"
      real_name = name*".bz2"
    elseif name[end-2:end] == "pre"
      real_name = name*".txt.bz2"
    else
      real_name = name*"-pre.txt.bz2"
    end
  catch err
    @warn "The name and group were not recognized"
    throw(err)
  end
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
  real_group = ""
  try
    if group == "dubrovnik"
      real_group = dubrovnik_prob
    elseif group == "trafalgar"
      real_group = trafalgar_prob
    elseif group == "ladybug"
      real_group = ladybug_prob
    elseif group == "venice"
      real_group = venice_prob
    end
  catch err
    @warn "The group was not recognized"
    throw(err)
  end
  problem_paths = String[]
  for problem ∈ real_group
    problem_path = fetch_bal_name(problem, group)
    push!(problem_paths, problem_path)
  end
  return problem_paths
end

"""
generate_NLSModel(name::AbstractString, group::AbstractString, T::Type=Float64)
Get the path of the problem name `name` from the group `group` with the precision `T`.
Return a NLSModel generated from this problem data using NLPModels
"""
function generate_NLSModel(name::AbstractString, group::AbstractString, T::Type=Float64)
  real_name = ""
  try
    if name[end-2:end] == "bz2"
      real_name = name
    elseif name[end-2:end] == "txt"
      real_name = name*".bz2"
    elseif name[end-2:end] == "pre"
      real_name = name*".txt.bz2"
    else
      real_name = name*"-pre.txt.bz2"
    end
  catch err
    @warn "The name and group were not recognized"
    throw(err)
  end
  filedir = fetch_bal_name(name, group)
  filename = joinpath(filedir, real_name)
  return BALNLSModel(filename, T=T)
end

const DEFAULT_IO = Ref{Union{IO,Nothing}}(nothing)
stderr_f() = something(DEFAULT_IO[], stderr)
can_fancyprint(io::IO) = (io isa Base.TTY) && (get(ENV, "CI", nothing) != "true")

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

function cust_download_verify(
  real_name::String,
  url::AbstractString,
  hash::Union{AbstractString, Nothing},
  dest::AbstractString;
  verbose::Bool = false,
  force::Bool = false,
  quiet_download::Bool = false,
)
  # Whether the file existed in the first place
  file_existed = false

  if isfile(dest)
      file_existed = true
      if verbose
          @info("Destination file $(dest) already exists, verifying...")
      end

      # verify download, if it passes, return happy.  If it fails, (and
      # `force` is `true`, re-download!)
      if hash !== nothing && verify(dest, hash; verbose=verbose)
          return true
      elseif !force
          error("Verification failed, not overwriting $(dest)")
      end
  end

  # Make sure the containing folder exists
  mkpath(dirname(dest))

  # Download the file, optionally continuing
  download(url, joinpath(dest, "$real_name"))
  if hash !== nothing && !verify(dest, hash; verbose=verbose)
      # If the file already existed, it's possible the initially downloaded chunk
      # was bad.  If verification fails after downloading, auto-delete the file
      # and start over from scratch.
      if file_existed
          if verbose
              @info("Continued download didn't work, restarting from scratch")
          end
          Base.rm(joinpath(dest, "$real_name"); force=true)

          # Download and verify from scratch
          download(url, joinpath(dest, "$real_name"))
          if hash !== nothing && !verify(dest, hash; verbose=verbose)
              error("Verification failed")
          end
      else
          # If it didn't verify properly and we didn't resume, something is
          # very wrong and we must complain mightily.
          error("Verification failed")
      end
  end

  # If the file previously existed, this means we removed it (due to `force`)
  # and redownloaded, so return `false`.  If it didn't exist, then this means
  # that we successfully downloaded it, so return `true`.
  return !file_existed
end
