module BALProblems

"""
     fetch_bal(group::AbstractString, name::AbstractString)
Download the matrix with name `name` in group `group`.
Return the path where the matrix is stored.
"""
function fetch_bal(group::AbstractString, name::AbstractString)
  group_and_name = group * "/" * name * ".txt.bz2"
  # download lazy artifact if not already done and obtain path
  loc = ensure_artifact_installed(group_and_name, joinpath(@__DIR__, "..", "Artifacts.toml"))
  return joinpath(loc, name)
end

end
