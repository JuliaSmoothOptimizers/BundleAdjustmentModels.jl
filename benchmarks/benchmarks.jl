using BundleAdjustmentModels
using ADNLPModels
using NLPModels
using Printf

debug = false
check_jacobian = false
df = problems_df()
# df = df[ ( df.nequ .≤ 600000 ) .& ( df.nvar .≤ 100000 ), :]
nproblems = size(df)[1]

@printf("| %21s | %7s | %7s | %22s | %15s |\n", "problem", "nequ", "nvar", "backend", "coord_residual")
for i = 1:nproblems
  name_pb = df[i, :name]

  # Smaller problem of the collection
  debug && (i == 1) && (name_pb = "problem-49-7776-pre")
  debug && (i ≠ 1) && continue

  ## BundleAdjustementModels
  nls = BundleAdjustmentModel(name_pb)
  meta_nls = nls_meta(nls)
  Fx = similar(nls.meta.x0, meta_nls.nequ)
  rows = Vector{Int}(undef, meta_nls.nnzj)
  cols = Vector{Int}(undef, meta_nls.nnzj)
  vals = similar(nls.meta.x0, meta_nls.nnzj)
  x = rand(nls.meta.nvar)  # nls.meta.x0

  # warm-start
  residual(nls, nls.meta.x0)
  residual!(nls, nls.meta.x0, Fx)
  jac_structure_residual!(nls, rows, cols)
  jac_coord_residual!(nls, x, vals)

  # benchmarks
  start_timer = time()
  jac_coord_residual!(nls, x, vals)
  end_timer = time()
  timer_coord_residual = end_timer - start_timer
  @printf("| %21s | %7s | %7s | %22s | %6.5f seconds |\n", name_pb, nls.nls_meta.nequ, nls.meta.nvar, "BundleAdjustmentModels", timer_coord_residual)

  ## ADNLPModels
  function F!(Fx, x)
    residual!(nls, x, Fx)
  end
  nls2 = ADNLSModel!(F!, nls.meta.x0, meta_nls.nequ, nls.meta.lvar, nls.meta.uvar, jacobian_residual_backend = ADNLPModels.SparseADJacobian,
                                                                                   jacobian_backend = ADNLPModels.EmptyADbackend,
                                                                                   hessian_backend = ADNLPModels.EmptyADbackend,
                                                                                   hessian_residual_backend = ADNLPModels.EmptyADbackend)
  meta_nls2 = nls_meta(nls2)
  rows2 = Vector{Int}(undef, meta_nls2.nnzj)
  cols2 = Vector{Int}(undef, meta_nls2.nnzj)
  vals2 = similar(nls2.meta.x0, meta_nls2.nnzj)

  # Warm-start
  jac_structure_residual!(nls2, rows2, cols2)
  jac_coord_residual!(nls2, x, vals2)

  # benchmarks
  start_timer = time()
  jac_coord_residual!(nls2, x, vals2)
  end_timer = time()
  timer2_coord_residual = end_timer - start_timer
  @printf("| %21s | %7s | %7s | %22s | %6.5f seconds |\n", name_pb, nls2.nls_meta.nequ, nls2.meta.nvar, "ADNLPModels", timer2_coord_residual)

  if check_jacobian
    println(meta_nls.nnzj)
    println(meta_nls2.nnzj)
    J_nls = sparse(rows, cols, vals)
    J_nls2 = sparse(rows2, cols2, vals2)
    norm(J_nls - J_nls2) |> println
    norm(J_nls - J_nls2, Inf) |> println
  end
end
