if VERSION ≥ VersionNumber(1, 7, 3)
  @testset "residual allocations" begin
    df = problems_df()
    filter_df = df[(df.name .== "problem-49-7776-pre"), :]
    name = filter_df[1, :name]
    model = BundleAdjustmentModel(name)
    meta_nls = nls_meta(model)
    S = typeof(model.meta.x0)
    F = S(undef, meta_nls.nequ)

    residual!(model, model.meta.x0, F)
    residual_alloc(model) = @allocated residual!(model, model.meta.x0, F)
    @test residual_alloc(model) == 0
  end

  @testset "jac_structure_residual allocations" begin
    df = problems_df()
    filter_df = df[(df.name .== "problem-49-7776-pre"), :]
    name = filter_df[1, :name]
    model = BundleAdjustmentModel(name)
    S = typeof(model.meta.x0)
    meta_nls = nls_meta(model)
    rows = Vector{Int}(undef, meta_nls.nnzj)
    cols = Vector{Int}(undef, meta_nls.nnzj)

    jac_structure_residual!(model, rows, cols)
    jac_structure_residual_alloc(model, rows, cols) =
      @allocated jac_structure_residual!(model, rows, cols)
    @test jac_structure_residual_alloc(model, rows, cols) == 0
  end

  @testset "jac_coord_residual allocations" begin
    df = problems_df()
    filter_df = df[(df.name .== "problem-49-7776-pre"), :]
    name = filter_df[1, :name]
    model = BundleAdjustmentModel(name)
    S = typeof(model.meta.x0)
    meta_nls = nls_meta(model)
    vals = S(undef, meta_nls.nnzj)

    jac_coord_residual!(model, model.meta.x0, vals)
    jac_coord_residual_alloc(model, vals) =
      @allocated jac_coord_residual!(model, model.meta.x0, vals)
    @test jac_coord_residual_alloc(model, vals) == 0
  end
end
