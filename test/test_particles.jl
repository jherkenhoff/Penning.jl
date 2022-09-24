using Penning.Particles

@testset "Species" begin
    
    @testset "Ion" begin
        species = Ion(187, 29)
        @test species.m ≈ 3.105208e-25 atol=0.000001e-25
        @test species.q ≈ 4.6463122e-18 atol=0.0000001e-18
    end

    @testset "Electron" begin
        species = Electron()
        @test species.m ≈ 9.10938e-31 atol=0.00001e-31
        @test species.q ≈ -1.6021766e-19 atol=0.0000001e-19
    end
end