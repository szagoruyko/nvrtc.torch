require 'cutorch'
nvrtc = {}
include 'ffi.lua'
local ffi = require 'ffi'

nvrtc.errcheck = function(f, ...)
   local status = nvrtc.C[f](...)
   if status ~= 'NVRTC_SUCCESS' then
      local str = ffi.string(nvrtc.C.nvrtcGetErrorString(status))
      error('Error in NVRTC: ' .. str)
   end
end

nvrtc.createProgram = function(kernel, includes, includeNames)
  assert(torch.type(kernel) == 'string')
  local includes_p = ffi.new('const char*[1]', nil)
  local includeNames_p = ffi.new('const char*[1]', nil)
  local includes_n = 0
  if includes or includeNames then
    assert(torch.type(includes) == 'table', 'arg #2 has to be a table of include sources')
    assert(torch.type(includeNames) == 'table', 'arg #3 has to be a table of include names') 
    includes_n = #includes
    includes_p = ffi.new('const char*[?]', includes_n)
    includeNames_p = ffi.new('const char*[?]', includes_n)
    for i=0,#includes_n-1 do
      includes_p[i] = ffi.new('const char[1]', includes[i+1])
      includeNames_p[i] = ffi.new('const char[1]', includeNames[i+1])
    end
  end
  local program = ffi.new'nvrtcProgram[1]'
  nvrtc.errcheck('nvrtcCreateProgram', program, kernel, nil, includes_n, includes_p, includeNames_p)
  ffi.gc(program, function(p) nvrtc.errcheck('nvrtcDestroyProgram', p) end)
  return program
end

nvrtc.getLog = function(program)
  local log_size = ffi.new'size_t[1]'
  nvrtc.errcheck('nvrtcGetProgramLogSize', program[0], log_size)
  local log = ffi.new('char[?]', tonumber(log_size[0]))
  nvrtc.errcheck('nvrtcGetProgramLog', program[0], log)
  return ffi.string(log)
end

nvrtc.compileProgram = function(program, args)
  local args_p = ffi.new('const char*[1]', nil)
  local args_n = 0
  if args then
    assert(torch.type(args) == 'table')
    args_n = #args
    args_p = ffi.new('const char*[?]', args_n)
    for i=0,args_n-1 do
      args_p[i] = ffi.new('const char[1]', args[i+1])
    end
  end
  local err = nvrtc.C.nvrtcCompileProgram(program[0], args_n, args_p)
  if err == 'NVRTC_ERROR_COMPILATION' then
    error(nvrtc.getLog(program))
  elseif err ~= 'NVRTC_SUCCESS' then
    local str = ffi.string(nvrtc.C.nvrtcGetErrorString(err))
    error('Error in NVRTC: ' .. str)
  end
end

nvrtc.getPTX = function(program)
  local ptx_size = ffi.new'size_t[1]'
  nvrtc.errcheck('nvrtcGetPTXSize', program[0], ptx_size)
  local ptx = ffi.new('char[?]', tonumber(ptx_size[0]))
  nvrtc.errcheck('nvrtcGetPTX', program[0], ptx)
  return ptx
end

nvrtc.compileReturnPTX = function(kernel, args, includes, includeNames)
  local program = nvrtc.createProgram(kernel, includes, includeNames)
  nvrtc.compileProgram(program, args)
  return nvrtc.getPTX(program)
end
