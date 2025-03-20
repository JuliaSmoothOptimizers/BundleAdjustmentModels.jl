using BundleAdjustmentModels
using ADNLPModels
using NLPModels
using Printf
using SparseArrays
using MatrixMarket

df = problems_df()
num_pb = size(df, 1)
for i = num_pb:-1:num_pb-9
  name_pb = df[i, :name]
  println("Problem $i / $(num_pb) -- $(name_pb)")

  ## BundleAdjustementModels
  nls = BundleAdjustmentModel(name_pb)
  meta_nls = nls_meta(nls)
  m, n = meta_nls.nequ, meta_nls.nvar 
  rows, cols = jac_structure_residual(nls)
  vals = ones(Bool, meta_nls.nnzj)
  J = sparse(rows, cols, vals, m, n)
  display(J)
  mmwrite(name_pb * ".mtx", J)
end
