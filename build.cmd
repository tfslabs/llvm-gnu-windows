@echo off
cd /d "%~dp0"

md .bin
md .cmake

cd .cmake
cmake -G "Unix Makefiles" -S ../llvm -B . -DLLVM_ENABLE_PROJECTS="clang;lld" -DCMAKE_INSTALL_PREFIX="../.bin" -DCMAKE_BUILD_TYPE=MinSizeRel -DLLVM_INSTALL_UTILS=ON
cmake --build . --parallel
cmake --install .
