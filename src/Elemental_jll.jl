module Elemental_jll


using ThinJLLWrapers


export libEl, libElSuiteSparse


const libEl  = "libEl.so"
libEl_handle = C_NULL
libEl_path   = ""

const libElSuiteSparse  = "libElSuiteSparse.so"
libElSuiteSparse_handle = C_NULL
libElSuiteSparse_path   = ""

const libpmrrr = "libpmrrr.so"
libpmrrr_handle = C_NULL
libpmrrr_path   = ""


function __init__()
    # Make sure that the JLL_LIBRARY_PATH entries
    ensure_jll_path()

    libEl_path   = find_path(libEl)
    libEl_handle = jll_open(libEl_path)

    libElSuiteSparse_path   = find_path(libElSuiteSparse)
    libElSuiteSparse_handle = jll_open(libElSuiteSparse_path)

    libpmrrr_path   = find_path(libpmrrr)
    libpmrrr_handle = jll_open(libpmrrr_path)
end

end # module
