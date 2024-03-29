; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc -mtriple=riscv32 -mattr=+m -verify-machineinstrs < %s \
; RUN:   | FileCheck -check-prefixes=RV32IM %s
; RUN: llc -mtriple=riscv64 -mattr=+m -verify-machineinstrs < %s \
; RUN:   | FileCheck -check-prefixes=RV64IM %s

define i32 @testsize1(i32 %x) minsize nounwind {
; RV32IM-LABEL: testsize1:
; RV32IM:       # %bb.0: # %entry
; RV32IM-NEXT:    li a1, 32
; RV32IM-NEXT:    div a0, a0, a1
; RV32IM-NEXT:    ret
;
; RV64IM-LABEL: testsize1:
; RV64IM:       # %bb.0: # %entry
; RV64IM-NEXT:    li a1, 32
; RV64IM-NEXT:    divw a0, a0, a1
; RV64IM-NEXT:    ret
entry:
  %div = sdiv i32 %x, 32
  ret i32 %div
}

define i32 @testsize2(i32 %x) minsize nounwind {
; RV32IM-LABEL: testsize2:
; RV32IM:       # %bb.0: # %entry
; RV32IM-NEXT:    li a1, 33
; RV32IM-NEXT:    div a0, a0, a1
; RV32IM-NEXT:    ret
;
; RV64IM-LABEL: testsize2:
; RV64IM:       # %bb.0: # %entry
; RV64IM-NEXT:    li a1, 33
; RV64IM-NEXT:    divw a0, a0, a1
; RV64IM-NEXT:    ret
entry:
  %div = sdiv i32 %x, 33
  ret i32 %div
}

define i32 @testsize3(i32 %x) minsize nounwind {
; RV32IM-LABEL: testsize3:
; RV32IM:       # %bb.0: # %entry
; RV32IM-NEXT:    srli a0, a0, 5
; RV32IM-NEXT:    ret
;
; RV64IM-LABEL: testsize3:
; RV64IM:       # %bb.0: # %entry
; RV64IM-NEXT:    srliw a0, a0, 5
; RV64IM-NEXT:    ret
entry:
  %div = udiv i32 %x, 32
  ret i32 %div
}

define i32 @testsize4(i32 %x) minsize nounwind {
; RV32IM-LABEL: testsize4:
; RV32IM:       # %bb.0:
; RV32IM-NEXT:    li a1, 33
; RV32IM-NEXT:    divu a0, a0, a1
; RV32IM-NEXT:    ret
;
; RV64IM-LABEL: testsize4:
; RV64IM:       # %bb.0:
; RV64IM-NEXT:    li a1, 33
; RV64IM-NEXT:    divuw a0, a0, a1
; RV64IM-NEXT:    ret
  %div = udiv i32 %x, 33
  ret i32 %div
}
