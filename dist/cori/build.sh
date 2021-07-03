#!/usr/bin/env bash

set -e


git_repo="https://github.com/elemental/Elemental.git"
git_rev="477e503a7a840cc1a75173552711b980505a0b06"


tolower () { echo $1 | awk '{ print tolower($1) }'; }


get_source () {
    if [[ -d $2 ]]
    then
        return 0
    fi

    git clone $1
    pushd $2
    git checkout $3
    popd
}


install() {

    root_prefix=$(readlink -f $(dirname ${BASH_SOURCE[0]}))

    arch=$1
    craype=$2
    sourcedir=${root_prefix}/$3
    prefix=${root_prefix}/${arch}/${craype}
    builddir=${root_prefix}/${arch}/${craype}/build
    nproc=16

    # TODO: this only works with MKL at the moment => disable non-intel PEs
    if [[ $craype != "intel" ]]
    then
        echo "libEl needs MKL (for now), please compile with PrgEnv-intel".
        return 1
    fi

    mkdir -p $prefix
    mkdir -p $builddir

    pushd $builddir

    cmake \
      -DCMAKE_INSTALL_PREFIX="$prefix" \
      -DCMAKE_BUILD_TYPE="Release" \
      -DEL_USE_64BIT_INTS="ON" \
      -DEL_USE_64BIT_BLAS_INTS="ON" \
      -DEL_DISABLE_PARMETIS="ON" \
      -DMETIS_TEST_RUNS_EXITCODE="0" \
      -DMETIS_TEST_RUNS_EXITCODE__TRYRUN_OUTPUT="" \
      -DMATH_LIBS="-mkl" \
      -DMETIS_LIBRARY="${METIS_LIB}" \
      ${sourcedir}
      # -DBLAS_LIBRARIES="/usr/lib64/" \
      # -DLAPACK_LIBRARIES="/usr/lib64/lapack/" \
      # ${sourcedir}

    make "-j$nproc"
    make install

    popd
}


install_all () {

    # module load cmake git metis-64 cray-libsci
    module load cmake git metis-64

    __target=${CRAY_CPU_TARGET}
    targets=(haswell mic-knl)
    last_target=${__target}
    for target in ${targets[@]}
    do
        module swap craype-${last_target} craype-${target}

        __pe=$(tolower $PE_ENV)
        # TODO: problems with the different environments:
        # 1. metis is only available in intel (but maybe parmetis is fine)
        # 2. intel mkl / libsci blas don't seem to work and the intel compiler
        #    doesn't seem to want to compile the -- autmatically downloaded --
        #    OpenBLAS
        # pes=(cray gnu intel)
        pes=(intel)
        last_pe=$__pe

        for pe in ${pes[@]}
        do
            module swap PrgEnv-${last_pe} PrgEnv-${pe}
            install ${target} ${pe} $1
            last_pe=${pe}
        done

        module swap PrgEnv-${last_pe} PrgEnv-${__pe}
        last_target=${target}
    done

    module swap craype-${last_target} craype-${__target}
}


if [[ $1 == "clean" ]]
then
    echo "Cleaning build path."
    if [[ -d haswell ]]; then rm -rf haswell; fi
    if [[ -d mic-knl ]]; then rm -rf mic-knl; fi
    if [[ -d Elemental ]]; then rm -rf Elemental; fi
    exit 0
fi

get_source $git_repo Elemental $git_rev
install_all Elemental
