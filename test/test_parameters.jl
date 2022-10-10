
using Penning.Utils

@testset "Parameters" begin
    @info "Testing parameters..."


    t = 0.0

    @testset "ConstantParameter" begin
        # Float parameter
        param = ConstantParameter(5e-3)
        @test param(0.0) == 5e-3

        # Integer parameter
        param = ConstantParameter(90)
        @test param(0.0) == 90
    end

    @testset "LinearDriftParameter" begin
        param = LinearDriftParameter(1e-3)
        @test param(0.0) ≈ 0.0
        @test param(1.0) ≈ 1e-3
        @test param(2.5) ≈ 2.5e-3

        param = LinearDriftParameter(-1)
        @test param(0.0) ≈ 0.0
        @test param(0.5) ≈ -0.5
        @test param(1.0) ≈ -1
    end

    @testset "AddParameter" begin
        param_a = ConstantParameter(8)
        param_b = ConstantParameter(3)
        param = param_a + param_b
        @test param(t) == 11
    end
end