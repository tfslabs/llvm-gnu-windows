@echo off
cd /d "%~dp0"

md .bin && cd .bin
md bootstrap
md makefiles && cd makefiles

set /a BUILDCPU=%NUMBER_OF_PROCESSORS%/2

::llvm
md llvm && cd llvm
cmake -G "Unix Makefiles" -DLLVM_ENABLE_PROJECTS="bolt;clang;clang-tools-extra;compiler-rt;cross-project-tests;libc;libclc;lld;lldb;mlir;openmp;polly;pstl;flang" -DCMAKE_BUILD_TYPE=MinSizeRel -DCMAKE_PREFIX_PATH=../../bootstrap ../../../llvm
make -j4
make install
