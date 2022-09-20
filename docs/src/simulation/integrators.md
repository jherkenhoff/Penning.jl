
## Particle Integrators

Standard ODE solvers (e.g. 4th order Runge Kutta) add a small numerical error at each timestep, which, over the long run, leads to a drift of the total energy inside the system. This is particularly undesirable for particle simulations, as they are usually being run for many timesteps and would therefore be guaranteed to end up with unphysical particle trajectories.
We therefore have to carefully choose a particle integration algorithm that conserves energy, e.g. one of the family of [symplectic integrators](https://en.wikipedia.org/wiki/Symplectic_integrator).
A very simple aproach for symplectic integration is the leap-frog scheme, in which particle positions and velocities are calculated in a time-staggered manner.

### Boris Method

### Modified Boris Method (DEFAULT)
While the Boris method is good at preserving conserved quantities, it introduces a phase error on the radial modes.
However, there is a simple modification[1], that fixes the phase error in all orders for static magnetic fields. For spatially or time-varying magnetic fields this is not necessarily true, which has to be further evaluated.
The modified Boris pusher is available as `ModifiedBorisPusher` in Penning and is **used by default** if no particle pusher is explicitly specified.

