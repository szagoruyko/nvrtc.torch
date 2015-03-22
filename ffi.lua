local ffi = require 'ffi'

ffi.cdef[[
typedef enum {
  NVRTC_SUCCESS = 0,
  NVRTC_ERROR_OUT_OF_MEMORY = 1,
  NVRTC_ERROR_PROGRAM_CREATION_FAILURE = 2,
  NVRTC_ERROR_INVALID_INPUT = 3,
  NVRTC_ERROR_INVALID_PROGRAM = 4,
  NVRTC_ERROR_INVALID_OPTION = 5,
  NVRTC_ERROR_COMPILATION = 6,
  NVRTC_ERROR_BUILTIN_OPERATION_FAILURE = 7
} nvrtcResult;
const char *nvrtcGetErrorString(nvrtcResult result);
nvrtcResult nvrtcVersion(int *major, int *minor);
typedef struct _nvrtcProgram *nvrtcProgram;
nvrtcResult nvrtcCreateProgram(nvrtcProgram *prog,
                               const char *src,
                               const char *name,
                               int numHeaders,
                               const char **headers,
                               const char **includeNames);
nvrtcResult nvrtcDestroyProgram(nvrtcProgram *prog);
nvrtcResult nvrtcCompileProgram(nvrtcProgram prog,
                                int numOptions, const char **options);
nvrtcResult nvrtcGetPTXSize(nvrtcProgram prog, size_t *ptxSizeRet);
nvrtcResult nvrtcGetPTX(nvrtcProgram prog, char *ptx);
nvrtcResult nvrtcGetProgramLogSize(nvrtcProgram prog, size_t *logSizeRet);
nvrtcResult nvrtcGetProgramLog(nvrtcProgram prog, char *log);
]]

local ok,err = pcall(function() nvrtc.C = ffi.load('libnvrtc') end)
if not ok then
   print(err)
   error([['libnvrtc.so not found in library path.
Please install CUDA version 7 or higher.
Then make sure all the files named as libnvrtc.so* are placed in your library load path (for example /usr/local/lib , or manually add a path to LD_LIBRARY_PATH)
]])
end
