# LLVM Extension for GNU Windows

LLVM is a set of compiler and toolchain technologies that can be used to develop a frontend for any programming language and a backend for any instruction set architecture.

You're not required to install this with your compiler, but it can be useful if you want to use the DLLs provided.

## Build this library

To build this library, you will need:

* [GNU Windows](https://github.com/tfslabs/gnu-windows)
* [CMake](https://www.cmake.org/) version 3 or newer installed on your machine. You can download it from the official website and follow their installation instructions.
* [Python 3.9+](https://python.org)

> :warning:
>
> Make sure you can run `make`, `gcc`  and `g++` from the command line without any issues.

Just run the  following commands in a terminal window to get started:

```cmd
build.cmd
```

Once it's done, you can see your bootstrap of LLVM in `.bin/bootstrap`. You can then paste it into your GNU Windows installation folder.
