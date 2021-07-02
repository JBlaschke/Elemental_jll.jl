#!/usr/bin/env bash

set -e


git_repo="https://github.com/elemental/Elemental.git"
git_rev="477e503a7a840cc1a75173552711b980505a0b06"


tolower () { echo $1 | awk '{ print tolower($1) }'; }


get_source () {
    git clone $1
    pushd $2
    git checkout $3
    popd
}


install () {

    root_prefix=$(readlink -f $(dirname ${BASH_SOURCE[0]}))

    arch=$1
    craype=$2
    sourcedir=${root_prefix}/$3
    prefix=${root_prefix}/${arch}/${craype}
    builddir=${root_prefix}/${arch}/${craype}/build

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
      -DMATH_LIBS="${CRAY_LIBSCI_PREFIX_DIR}/lib" \
      -DBLAS_LIBRARIES="${CRAY_LIBSCI_PREFIX_DIR}/lib" \
      -DLAPACK_LIBRARIES="${CRAY_LIBSCI_PREFIX_DIR}/lib" \
      -DEL_BLAS_SUFFIX="${CRAY_LIBSCI_PREFIX_DIR}/lib" \
      -DEL_LAPACK_SUFFIX="${CRAY_LIBSCI_PREFIX_DIR}/lib" \
      ${sourcedir}

    make "-j$nproc"
    make install

    popd
}


install_haswell () {

    __target=${CRAY_CPU_TARGET}
    module swap craype-${__target} craype-haswell
    module load cmake git metis-64 cray-libsci

    __pe=$(tolower $PE_ENV)
    # PrgEnv-cray and PrgEnv-gnu not supported because METIS is only built for
    # PrgEnv-intel -- TODO: switch to parmetis libray for these
    # pes=(cray gnu intel)
    pes=(intel)
    last_pe=$__pe

    for pe in ${pes[@]}
    do
        module swap PrgEnv-$last_pe PrgEnv-$pe
        install haswell $pe $1
    done

    module swap PrgEnv-$last_pe PrgEnv-$__pe
    module swap craype-haswell craype-${__target}
}



get_source $git_repo Elemental $git_rev
install_haswell Elemental
