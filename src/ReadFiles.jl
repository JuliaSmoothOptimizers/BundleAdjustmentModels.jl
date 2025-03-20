"""
    readfile(filename::String; T::Type=Float64)

Reads the `.txt.bzip2` file specified in `filename` and extracts data. 
Returns:
  - `cam_indices`: Vector of camera indices (Int)
  - `pnt_indices`: Vector of point indices (Int)
  - `pt2d`: Observed 2D points (Vector{T})
  - `x0`: Combined vector of 3D points and camera parameters (Vector{T})
  - `ncams`: Number of cameras (Int)
  - `npnts`: Number of 3D points (Int)
  - `nobs`: Number of observations (Int)

Expected file structure:
  - First line: `ncams npnts nobs`
  - Following `nobs` lines: `cam_index point_index xcoord ycoord`
  - Camera parameters: 9 lines per camera
  - 3D points: 3 lines per point
"""
function readfile(filename::String; T::Type = Float64)
    open(filename) do io
        f = Bzip2DecompressorStream(io)

        # First line: number of cameras, points, and observations
        ncams, npnts, nobs = map(x -> parse(Int, x), split(readline(f)))
        @debug "$filename: reading $ncams cameras, $npnts points, $nobs observations"

        # Preallocate vectors
        cam_indices = Vector{Int}(undef, nobs)
        pnt_indices = Vector{Int}(undef, nobs)
        pt2d = Vector{T}(undef, 2 * nobs)
        x0 = Vector{T}(undef, 3 * npnts + 9 * ncams)

        # Read observations
        for i = 1:nobs
            cam, pnt, x, y = split(readline(f))
            cam_indices[i] = parse(Int, cam) + 1  # Convert to 1-based indexing
            pnt_indices[i] = parse(Int, pnt) + 1
            pt2d[2 * i - 1] = parse(T, x)
            pt2d[2 * i] = parse(T, y)
        end

        # Read camera parameters (9 values per camera)
        for i = 1:ncams
            offset = 3 * npnts + 9 * (i - 1)
            for j = 1:9
                x0[offset + j] = parse(T, readline(f))
            end
        end

        # Read 3D points (3 coordinates per point)
        for k = 1:(3 * npnts)
            x0[k] = parse(T, readline(f))
        end

        return cam_indices, pnt_indices, pt2d, x0, ncams, npnts, nobs
    end
end
