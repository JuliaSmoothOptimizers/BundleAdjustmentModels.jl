if VERSION ≥ VersionNumber(1, 7, 3)
  @testset "residual allocations" begin
    df = problems_df()
    filter_df = df[(df.name .== "problem-49-7776-pre"), :]
    name, group = get_first_name_and_group(filter_df)
    model = BundleAdjustmentModel(name, group)

    residual!(model, model.meta.x0, model.F)
    residual_alloc(model) = @allocated residual!(model, model.meta.x0, model.F)
    @test residual_alloc(model) == 0
  end

  @testset "jac_structure_residual allocations" begin
    df = problems_df()
    filter_df = df[(df.name .== "problem-49-7776-pre"), :]
    name, group = get_first_name_and_group(filter_df)
    model = BundleAdjustmentModel(name, group)

    jac_structure_residual!(model, model.rows, model.cols)
    jac_structure_residual_alloc(model) = @allocated jac_structure_residual!(model, model.rows, model.cols)
    @test jac_structure_residual_alloc(model) == 0
  end

  @testset "jac_coord_residual allocations" begin
    df = problems_df()
    filter_df = df[(df.name .== "problem-49-7776-pre"), :]
    name, group = get_first_name_and_group(filter_df)
    model = BundleAdjustmentModel(name, group)

    jac_coord_residual!(model, model.meta.x0, model.vals)
    jac_coord_residual_alloc(model) = @allocated jac_coord_residual!(model, model.meta.x0, model.vals)
    @test jac_coord_residual_alloc(model) == 0
  end
end
