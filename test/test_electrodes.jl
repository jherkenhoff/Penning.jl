
using Penning.Electrodes


@testset "Electrodes" begin
    @info "Testing electrodes..."

    electrode = AxialParallelPlateElectrode(5e-3)
    @test calc_induced_current(electrode, [0, 0, 0], [0, 0, 0], 1.0) == 0
    @test calc_induced_current(electrode, [0, 0, 0], [2, 2, 0], 1.0) == 0
    @test calc_induced_current(electrode, [0, 0, 0], [0, 0, 2], 1.0) == 400
    @test calc_backaction_field(electrode, [0, 0, 0], 0) == [0, 0, 0]
    @test calc_backaction_field(electrode, [0, 0, 0], 1) == [0, 0, -200]

    electrode = RadialParallelPlateElectrode(5e-3)
    @test calc_induced_current(electrode, [0, 0, 0], [0, 0, 0], 1.0) == 0
    @test calc_induced_current(electrode, [0, 0, 0], [2, 2, 0], 1.0) == 400
    @test calc_induced_current(electrode, [0, 0, 0], [0, 0, 2], 1.0) == 0
    @test calc_backaction_field(electrode, [0, 0, 0], 0) == [0, 0, 0]
    @test calc_backaction_field(electrode, [0, 0, 0], 1) == [-200, 0, 0]

end