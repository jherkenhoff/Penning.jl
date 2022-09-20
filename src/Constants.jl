module Constants

export
    m_u,
    m_e,
    k_B,
    e,
    mu_0,
    epsilon_0,
    c

import PhysicalConstants.CODATA2018: 
    AtomicMassConstant, 
    BoltzmannConstant, 
    ElementaryCharge, 
    VacuumElectricPermittivity, 
    ElectronMass,
    SpeedOfLightInVacuum

const m_u = float(AtomicMassConstant).val
const m_e = float(ElectronMass).val
const k_B = float(BoltzmannConstant).val
const e = float(ElementaryCharge).val
const mu_0 = float(VacuumElectricPermittivity).val
const epsilon_0 = float(VacuumElectricPermittivity).val
const c = float(SpeedOfLightInVacuum).val

end # module