# nvrtc.torch
Torch7 bindings for CUDA NVRTC (runtime compilation) library

Requires CUDA 7 installation.

Example of usage:
```lua
require 'nvrtc'
ptx = nvrtc.compileReturnPTX(kernel)
```
where kernel is a lua string with CUDA kernel code. Return PTX can be loaded and ran with CUDA Driver API. More examples coming.
