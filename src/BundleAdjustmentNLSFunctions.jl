import NLPModels: increment!

export BundleAdjustmentModel,
  residual!,
  residuals!,
  jac_structure!,
  jac_coord!,
  jac_op_residual,
  jac_op_residual_update

"""
Represent a bundle adjustement problem in the form

    minimize    0
    subject to  F(x) = 0,

where `F(x)` is the vector of residuals.
"""
mutable struct BundleAdjustmentModel{T, S} <: AbstractNLSModel{T, S}
  # Meta and counters are required in every model
  meta::NLPModelMeta{T, S}
  # nls_meta
  nls_meta::NLSMeta{T, S}
  # Counters of NLPModel
  counters::NLSCounters
  # For each observation k, cams_indices[k] gives the index of thecamera used for this observation
  cams_indices::Vector{Int}
  # For each observation k, pnts_indices[k] gives the index of the 3D point observed in this observation
  pnts_indices::Vector{Int}
  # Each line contains the 2D coordinates of the observed point
  pt2d::AbstractVector
  # Number of observations
  nobs::Int
  # Number of points
  npnts::Int
  # Number of cameras
  ncams::Int

  ##### Jacobians data #####
  rows::Vector{Int}
  cols::Vector{Int}
  vals::AbstractVector
  Jv::AbstractVector
  Jtv::AbstractVector
end

""" Create name from filename """
function name(filename::AbstractString)
  return splitdir(splitext(splitext(filename)[1])[1])[2]
end

"""
    BundleAdjustmentModel(filename::AbstractString; T::Type=Float64, verbose::Bool=false)

Constructor of BundleAdjustmentModel, creates an NLSModel from a BundleAdjustment archive
"""
function BundleAdjustmentModel(filename::AbstractString; T::Type = Float64)
  cams_indices, pnts_indices, pt2d, x0, ncams, npnts, nobs = readfile(filename, T = T)

  S = typeof(x0)

  # variables: 9 parameters per camera + 3 coords per 3d point
  nvar = 9 * ncams + 3 * npnts
  # number of residuals: two residuals per 2d point
  nequ = 2 * nobs

  @debug "BundleAdjustmentModel $filename" nvar nequ

  meta = NLPModelMeta{T, S}(nvar, x0 = x0, name = name(filename))
  nls_meta = NLSMeta{T, S}(nequ, nvar, x0 = x0, nnzj = 2 * nobs * 12)

  rows = Vector{Int}(undef, nls_meta.nnzj)
  cols = Vector{Int}(undef, nls_meta.nnzj)
  vals = Vector{T}(undef, nls_meta.nnzj)
  Jv = Vector{T}(undef, nls_meta.nequ)
  Jtv = Vector{T}(undef, nls_meta.nvar)

  return BundleAdjustmentModel(
    meta,
    nls_meta,
    NLSCounters(),
    cams_indices,
    pnts_indices,
    pt2d,
    nobs,
    npnts,
    ncams,
    rows,
    cols,
    vals,
    Jv,
    Jtv,
  )
end

function NLPModels.residual!(nls::BundleAdjustmentModel, x::AbstractVector, cx::AbstractVector)
  increment!(nls, :neval_residual)
  residuals!(nls.cams_indices, nls.pnts_indices, x, cx, nls.nobs, nls.npnts)
  cx .-= nls.pt2d
  # If a value is NaN, we put it to 0 not to take it into account
  # @views map!(x -> isnan(x) ? 0 : x, cx, cx)
  return cx
end

function residuals!(
  cam_indices::Vector{Int},
  pnt_indices::Vector{Int},
  xs::AbstractVector,
  r::AbstractVector,
  nobs::Int,
  npts::Int,
)
  q, re = divrem(nobs, nthreads())
  if re != 0
    q += 1
  end

  @threads for t = 1:nthreads()
    @simd for k = (1 + (t - 1) * q):min(t * q, nobs)
      cam_index = cam_indices[k]
      pnt_index = pnt_indices[k]
      @views x = xs[((pnt_index - 1) * 3 + 1):((pnt_index - 1) * 3 + 3)]
      @views c = xs[(3 * npts + (cam_index - 1) * 9 + 1):(3 * npts + (cam_index - 1) * 9 + 9)]
      @views projection!(x, c, r[(2 * k - 1):(2 * k)], k)
    end
  end
  return r
end

#function projection!(p3  :: AbstractVector, r  :: AbstractVector, t  :: AbstractVector, k1 :: AbstractFloat, k2 :: AbstractFloat, f :: AbstractFloat, r2 ::  AbstractVector, idx :: Int)
function projection!(
  p3::AbstractVector,
  r::AbstractVector,
  t::AbstractVector,
  k1,
  k2,
  f,
  r2::AbstractVector,
  idx::Int,
)
  # θ = norm(r)
  θ = sqrt(r[1]^2 + r[2]^2 + r[3]^2)
  # if θ < eps(eltype(p3))
  #   P1 = p3 + cross(r, p3)
  # else
  k = r / θ
  P1 = cos(θ) * p3 + sin(θ) * cross(k, p3) + (1 - cos(θ)) * dot(k, p3) * k + t
  # end
  # if P1[3] == 0
  #   r2 .= NaN
  # else
  P2 = -P1[1:2] / P1[3]
  r2 .= f * scaling_factor(P2, k1, k2) * P2
  # end
  return r2
end

projection!(x, c, r2, k) = projection!(x, c[1:3], c[4:6], c[7], c[8], c[9], r2, k)

function scaling_factor(point::AbstractVector, k1::AbstractFloat, k2::AbstractFloat)
  sq_norm_point = dot(point, point)
  return 1.0 + k1 * sq_norm_point + k2 * sq_norm_point^2
end

function NLPModels.jac_structure!(
  nls::BundleAdjustmentModel,
  rows::AbstractVector{<:Integer},
  cols::AbstractVector{<:Integer},
)
  increment!(nls, :neval_jac)
  nobs = nls.nobs
  npnts_3 = 3 * nls.npnts

  q, re = divrem(nobs, nthreads())
  if re != 0
    q += 1
  end
  @threads for t = 1:nthreads()
    @simd for k = (1 + (t - 1) * q):min(t * q, nobs)
      idx_obs = (k - 1) * 24
      idx_cam = npnts_3 + 9 * (nls.cams_indices[k] - 1)
      idx_pnt = 3 * (nls.pnts_indices[k] - 1)

      # Only the two rows corresponding to the observation k are not empty
      p = 2 * k
      @views fill!(rows[(idx_obs + 1):(idx_obs + 12)], p - 1)
      @views fill!(rows[(idx_obs + 13):(idx_obs + 24)], p)

      # 3 columns for the 3D point observed
      @inbounds cols[(idx_obs + 1):(idx_obs + 3)] = (idx_pnt + 1):(idx_pnt + 3)
      # 9 columns for the camera
      @inbounds cols[(idx_obs + 4):(idx_obs + 12)] = (idx_cam + 1):(idx_cam + 9)
      # 3 columns for the 3D point observed
      @inbounds cols[(idx_obs + 13):(idx_obs + 15)] = (idx_pnt + 1):(idx_pnt + 3)
      # 9 columns for the camera
      @inbounds cols[(idx_obs + 16):(idx_obs + 24)] = (idx_cam + 1):(idx_cam + 9)
    end
  end
  return rows, cols
end

function NLPModels.jac_coord!(nls::BundleAdjustmentModel, x::AbstractVector, vals::AbstractVector)
  increment!(nls, :neval_jac)
  nobs = nls.nobs
  npnts = nls.npnts
  T = eltype(x)

  # jac_coord is optimal with 3 threads
  nthreads_used = min(3, nthreads())

  q, re = divrem(nobs, nthreads_used)
  if re != 0
    q += 1
  end

  @threads for t = 1:nthreads_used
    denseJ = Matrix{T}(undef, 2, 12)
    JP1_mat = zeros(6, 12)
    JP1_mat[1, 7], JP1_mat[2, 8], JP1_mat[3, 9], JP1_mat[4, 10], JP1_mat[5, 11], JP1_mat[6, 12] =
      1, 1, 1, 1, 1, 1
    JP2_mat = zeros(5, 6)
    JP2_mat[3, 4], JP2_mat[4, 5], JP2_mat[5, 6] = 1, 1, 1
    JP3_mat = Matrix{T}(undef, 2, 5)

    @simd for k = (1 + (t - 1) * q):min(t * q, nobs)
      idx_cam = nls.cams_indices[k]
      idx_pnt = nls.pnts_indices[k]
      @views X = x[((idx_pnt - 1) * 3 + 1):((idx_pnt - 1) * 3 + 3)] # 3D point coordinates
      @views C = x[(3 * npnts + (idx_cam - 1) * 9 + 1):(3 * npnts + (idx_cam - 1) * 9 + 9)] # camera parameters
      r = C[1:3]  # Rodrigues vector for the rotation
      t = C[4:6]  # translation vector
      k1, k2, f = C[7:9]  # focal length and radial distortion factors

      # denseJ = JP3∘P2∘P1 x JP2∘P1 x JP1
      p1 = P1(r, t, X)
      JP1!(JP1_mat, r, X)
      JP2!(JP2_mat, p1)
      JP3!(JP3_mat, P2(p1), f, k1, k2)
      mul!(denseJ, JP3_mat * JP2_mat, JP1_mat)

      # Feel vals with the values of denseJ = [[∂P.x/∂X ∂P.x/∂C], [∂P.y/∂X ∂P.y/∂C]]
      # If a value is NaN, we put it to 0 not to take it into account
      vals[((k - 1) * 24 + 1):((k - 1) * 24 + 24)] .= map(x -> isnan(x) ? 0 : x, denseJ'[:])
    end
  end
  return vals
end

function NLPModels.jac_op_residual(nls::BundleAdjustmentModel, x::AbstractVector)
  jac_structure!(nls, nls.rows, nls.cols)
  jac_coord!(nls, x, nls.vals)
  Jx = jac_op_residual!(nls, nls.rows, nls.cols, nls.vals, nls.Jv, nls.Jtv)
  return Jx
end

"""
    jac_op_residual_update(nls :: BundleAdjustmentModel, x :: AbstractVector)

Update the jacobian operator of the residual wihtout jac_structure! instead
of using jac_op_residual
"""
function jac_op_residual_update(nls::BundleAdjustmentModel, x::AbstractVector)
  jac_coord!(nls, x, nls.vals)
  Jx = jac_op_residual!(nls, nls.rows, nls.cols, nls.vals, nls.Jv, nls.Jtv)
  return Jx
end
