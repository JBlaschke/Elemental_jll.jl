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
    if ! ensure_jll_path()
        error("JLL_LIBRARY_PATH not in LD_LIBRARY_PATH, make sure you run `module load Elemental_jll` before starting Julia")
    end

    global libEl_path   = find_path(libEl)
    global libEl_handle = jll_open(libEl_path)

    global libElSuiteSparse_path   = find_path(libElSuiteSparse)
    global libElSuiteSparse_handle = jll_open(libElSuiteSparse_path)

    global libpmrrr_path   = find_path(libpmrrr)
    global libpmrrr_handle = jll_open(libpmrrr_path)
end

end # module
