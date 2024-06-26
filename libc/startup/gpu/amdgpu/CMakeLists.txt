add_startup_object(
  crt1
  NO_GPU_BUNDLE # Compile this file directly without special GPU handling.
  SRC
    start.cpp
  DEPENDS
    libc.src.__support.RPC.rpc_client
    libc.src.__support.GPU.utils
    libc.src.stdlib.exit
    libc.src.stdlib.atexit
  COMPILE_OPTIONS
    -ffreestanding # To avoid compiler warnings about calling the main function.
    -fno-builtin
    -mcode-object-version=${LIBC_GPU_CODE_OBJECT_VERSION} # Manually set the ABI.
)
get_fq_target_name(crt1 fq_name)

# Ensure that clang uses the correct linker for this object type.
target_link_libraries(
  ${fq_name}
  PUBLIC
  "-mcpu=${LIBC_GPU_TARGET_ARCHITECTURE}"
  "--target=${LIBC_GPU_TARGET_TRIPLE}"
  "-flto"
  "-Wl,-mllvm,-amdgpu-lower-global-ctor-dtor=0"
  "-Wl,-mllvm,-amdhsa-code-object-version=${LIBC_GPU_CODE_OBJECT_VERSION}"
)
