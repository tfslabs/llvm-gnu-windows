// RUN: %clang_cc1 %s -ast-print -fms-extensions | FileCheck %s

// CHECK: int x __attribute__((aligned(4)));
int x __attribute__((aligned(4)));

// CHECK: __declspec(align(4)) int y;
__declspec(align(4)) int y;

// CHECK: int foo() __attribute__((const));
int foo() __attribute__((const));

// CHECK: int bar() __attribute__((__const));
int bar() __attribute__((__const));

// FIXME: Print this with correct format.
// CHECK: int foo1() __attribute__((noinline)) __attribute__((pure));
int foo1() __attribute__((noinline, pure));

// CHECK: typedef int Small1 __attribute__((mode(byte)));
typedef int Small1 __attribute__((mode(byte)));

// CHECK: int small __attribute__((mode(byte)));
int small __attribute__((mode(byte)));

// CHECK: int v __attribute__((visibility("hidden")));
int v __attribute__((visibility("hidden")));

// CHECK: char *PR24565() __attribute__((malloc))
char *PR24565() __attribute__((__malloc__));

// CHECK: class __attribute__((consumable("unknown"))) AttrTester1
class __attribute__((consumable(unknown))) AttrTester1 {
  // CHECK: void callableWhen() __attribute__((callable_when("unconsumed", "consumed")));
  void callableWhen()  __attribute__((callable_when("unconsumed", "consumed")));
};

// CHECK: class __single_inheritance SingleInheritance;
class __single_inheritance SingleInheritance;

// CHECK: class __multiple_inheritance MultipleInheritance;
class __multiple_inheritance MultipleInheritance;

// CHECK: class __virtual_inheritance VirtualInheritance;
class __virtual_inheritance VirtualInheritance;

// CHECK: typedef double *aligned_double __attribute__((align_value(64)));
typedef double * __attribute__((align_value(64))) aligned_double;
