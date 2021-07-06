#!/usr/bin/env bash

set -e


root_dir=$(dirname "${BASH_SOURCE[0]}")
sw_root=$(readlink -f $root_dir)


mk_mod () {
cat > $root_dir/modulefiles/Elemental_jll/$1 <<EOF
#%Module1.0
##

## Required internal variables

set    name       Elemental_jll
set    version    $1
set    root       [file normalize $2/\$env(CRAY_CPU_TARGET)/intel]

## List conflicting modules here

conflict \$name

## List prerequisite modules here

prereq craype-\$env(CRAY_CPU_TARGET)
prereq metis-64
prereq PrgEnv-intel

## Required for SVN hook to generate SWDB entry

set    fullname       Elemental
set    externalurl    https://github.com/LLNL/Elemental
set    nerscurl       https://docs.nersc.gov/development/languages/julia/
set    maincategory   applications
set    subcategory    ""
set    description    "A compile version of libEl (and dependencies) plus thin Julia Wrappers"

## Required for "module help ..."

proc ModulesHelp { } {
  global description nerscurl externalurl
  puts stderr "Description - \$description"
  puts stderr "NERSC Docs  - \$nerscurl"
  puts stderr "Other Docs  - \$externalurl"
}

## Required for "module display ..." and SWDB

module-whatis    "\$description"

## Software-specific settings exported to user environment
prepend-path    LD_LIBRARY_PATH     \$root/lib
prepend-path    LD_LIBRARY_PATH     \$env(METIS_LIB)
setenv          JLL_LIBRARY_PATH    \$root/lib:\$env(METIS_LIB)

## MODS reporting
if [ module-info mode load ] {
    catch { exec /bin/sh /global/common/shared/das/mods2/bin/modster.sh $name $version }
}
EOF

}

mk_mod 1.0.0 $sw_root

