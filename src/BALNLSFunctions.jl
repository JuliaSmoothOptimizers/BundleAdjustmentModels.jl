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
  loc = ensure_artifact_installed(final_name, joinpath(@__DIR__, "..", "Artifacts.toml"), quiet_download=true)
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
