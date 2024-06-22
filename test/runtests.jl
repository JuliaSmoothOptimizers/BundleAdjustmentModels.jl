using BundleAdjustmentModels, DataFrames, LinearAlgebra, NLPModels, Pkg, Test

if VERSION ≤ VersionNumber(1, 6, 0)
  Pkg.PlatformEngines.probe_platform_engines!()
end

include("testBundleAdjustmentModels.jl")
include("testBundleAdjustmentAllocations.jl")

# https://github.com/JuliaSmoothOptimizers/NLPModelsTest.jl/blob/src/dercheck.jl#L43
function jacobian_residual_check(
  nlp::AbstractNLSModel;
  x::AbstractVector = nlp.meta.x0,
  atol::Float64 = 1.0e-6,
  rtol::Float64 = 1.0e-4,
)

  # Fast exit if there are no constraints.
  J_errs = Dict{Tuple{Int, Int}, Float64}()
  nlp.nls_meta.nequ > 0 || return J_errs

  # Optimal-ish step for second-order centered finite differences.
  step = (eps(Float64) / 3)^(1 / 3)

  # Check constraints Jacobian.
  J = jac_residual(nlp, x)
  h = zeros(nlp.meta.nvar)
  cxph = zeros(nlp.nls_meta.nequ)
  cxmh = zeros(nlp.nls_meta.nequ)
  # Differentiate all constraints with respect to each variable in turn.
  for i = 1:(nlp.meta.nvar)
    h[i] = step
    residual!(nlp, x + h, cxph)
    residual!(nlp, x - h, cxmh)
    dcdxi = (cxph - cxmh) / 2 / step
    for j = 1:(nlp.nls_meta.nequ)
      err = abs(dcdxi[j] - J[j, i])
      if err > atol + rtol * abs(dcdxi[j])
        J_errs[(j, i)] = err
      end
    end
    h[i] = 0
  end
  return J_errs
end

@testset "Test derivative Jacobian of residual" begin
  nls = BundleAdjustmentModel("problem-49-7776-pre")
  x = 10 * [-(-1.0)^i for i = 1:nls.meta.nvar]
  @test length(jacobian_residual_check(nls, x = x)) == 0
end
