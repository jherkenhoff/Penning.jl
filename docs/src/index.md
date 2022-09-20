# Penning.jl

*Flexible and extensible Julia framework for simulating the motion of particles in Penning traps.*


Penning.jl is a flexible and extensible simulation framework written in Julia that uses a symplectic time stepper to solve for the motion of charged particles in a Penning trap and features an integrated circuit simulator that is coupled to the Penning trap simulation.
It scales from simple single-particle systems up to complex N-body problems, possibly in multiple interconnected Penning-traps.
Penning.jl comes with many builtin features like a variety of excitation fields, including dipolar fields, plane waves and cavity modes, support for different damping mechanisms, noise injection and more. The integrated circuit simulator can be used to model the coupling of particles to a user-defined external circuit, most commonly an RLC tank circuit.


The interface was designed to make Penning.jl as friendly and intuitive to use as possible. An in-built collection of diagnostics and file-writers enables post-processing directly in Julia or 3rd party applications.
