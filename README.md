# Thin Binary Wrappers and Modules for Elemental

What if we need `Elemental_jll.jl` to be built against the System's MPI, and
BLAS/MKL? This package has you covered. TL;DR: rather than using
`BinaryBuilder.jl`, here we build Elemental "by hand" using system libraries
and compilers.

* This project contains the build scripts for:
    1. [x] NERSC Cori in `dist/cori`
    2. [ ] NERSC Cori GPU
    3. [ ] NERSC Perlmutter

* This project generates module files (`/dist/*/mk_modulefiles.sh`) to help
  keep track of system dependencies.
