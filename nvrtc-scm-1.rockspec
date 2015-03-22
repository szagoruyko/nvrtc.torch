package = "nvrtc"
version = "scm-1"

source = {
   url = "git://github.com/szagoruyko/nvrtc.torch.git",
}

description = {
   summary = "Torch7 FFI bindings for NVIDIA NVRTC library",
   detailed = [[
   ]],
   homepage = "https://github.com/szagoruyko/nvrtc.torch",
   license = "BSD"
}

dependencies = {
   "torch >= 7.0",
   "cutorch",
}

build = {
   type = "command",
   build_command = [[
cmake -E make_directory build && cd build && cmake .. -DCMAKE_BUILD_TYPE=Release -DCMAKE_PREFIX_PATH="$(LUA_BINDIR)/.." -DCMAKE_INSTALL_PREFIX="$(PREFIX)" && $(MAKE)
]],
   install_command = "cd build && $(MAKE) install"
}
