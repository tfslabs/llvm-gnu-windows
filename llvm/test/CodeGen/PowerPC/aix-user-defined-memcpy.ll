; RUN: llc -verify-machineinstrs -mtriple powerpc-ibm-aix-xcoff -mcpu=pwr4 \
; RUN:   -mattr=-altivec -filetype=obj -xcoff-traceback-table=false -o %t.o < %s

; RUN: llvm-readobj --syms %t.o | FileCheck -D#NFA=2 --check-prefix=32-SYM %s

; RUN: llvm-readobj --relocs --expand-relocs %t.o | FileCheck -D#NFA=2 \
; RUN:   --check-prefix=32-REL %s

; RUN: llvm-objdump -D %t.o | FileCheck -D#NFA=2 --check-prefix=32-DIS %s

; RUN: llc -verify-machineinstrs -mtriple powerpc-ibm-aix-xcoff \
; RUN:   -mcpu=pwr4 -mattr=-altivec < %s | FileCheck %s

;; FIXME: currently only fileHeader and sectionHeaders are supported in XCOFF64.

; Test verifies:
; If there exists a user-defined function whose name is the same as the
; "memcpy" ExternalSymbol's, we pick up the user-defined version, even if this
; may lead to some undefined behavior.

define dso_local signext i32 @memcpy(ptr %destination, i32 signext %num) {
entry:
  ret i32 3
}

define void @call_memcpy(ptr %p, ptr %q, i32 %n) {
entry:
  call void @llvm.memcpy.p0.p0.i32(ptr %p, ptr %q, i32 %n, i1 false)
  ret void
}

declare void @llvm.memcpy.p0.p0.i32(ptr nocapture writeonly, ptr nocapture readonly, i32, i1)

; This test check
; 1. The symbol table for .o file to verify .memcpy is a defined external label.
; 2. There is no relocation associated with the call, since callee is defined.
; 3. Branch instruction in raw data is branching back to the right callee location.

; CHECK-NOT: .extern .memcpy

; 32-SYM:      Symbol {{[{][[:space:]] *}}Index: [[#Index:]]{{[[:space:]] *}}Name: .___memmove
; 32-SYM-NEXT:    Value (RelocatableAddress): 0x0
; 32-SYM-NEXT:    Section: N_UNDEF
; 32-SYM-NEXT:    Type: 0x0
; 32-SYM-NEXT:    StorageClass: C_EXT (0x2)
; 32-SYM-NEXT:    NumberOfAuxEntries: 1
; 32-SYM-NEXT:    CSECT Auxiliary Entry {
; 32-SYM-NEXT:      Index: [[#NFA+2]]
; 32-SYM-NEXT:      SectionLen: 0
; 32-SYM-NEXT:      ParameterHashIndex: 0x0
; 32-SYM-NEXT:      TypeChkSectNum: 0x0
; 32-SYM-NEXT:      SymbolAlignmentLog2: 0
; 32-SYM-NEXT:      SymbolType: XTY_ER (0x0)
; 32-SYM-NEXT:      StorageMappingClass: XMC_PR (0x0)
; 32-SYM-NEXT:      StabInfoIndex: 0x0
; 32-SYM-NEXT:      StabSectNum: 0x0
; 32-SYM-NEXT:    }
; 32-SYM-NEXT:  }

; 32-SYM:      Symbol {{[{][[:space:]] *}}Index: [[#Index:]]{{[[:space:]] *}}Name: .memcpy 
; 32-SYM-NEXT:    Value (RelocatableAddress): 0x0
; 32-SYM-NEXT:    Section: .text
; 32-SYM-NEXT:    Type: 0x0
; 32-SYM-NEXT:    StorageClass: C_EXT (0x2)
; 32-SYM-NEXT:    NumberOfAuxEntries: 1
; 32-SYM-NEXT:    CSECT Auxiliary Entry {
; 32-SYM-NEXT:      Index: [[#NFA+6]]
; 32-SYM-NEXT:      ContainingCsectSymbolIndex: [[#NFA+3]]
; 32-SYM-NEXT:      ParameterHashIndex: 0x0
; 32-SYM-NEXT:      TypeChkSectNum: 0x0
; 32-SYM-NEXT:      SymbolAlignmentLog2: 0
; 32-SYM-NEXT:      SymbolType: XTY_LD (0x2)
; 32-SYM-NEXT:      StorageMappingClass: XMC_PR (0x0)
; 32-SYM-NEXT:      StabInfoIndex: 0x0
; 32-SYM-NEXT:      StabSectNum: 0x0
; 32-SYM-NEXT:    }
; 32-SYM-NEXT:  }

; 32-SYM-NOT: .memcpy

; 32-REL:      Relocations [
; 32-REL-NEXT:  Section (index: 1) .text {
; 32-REL-NEXT:  Relocation {
; 32-REL-NEXT:    Virtual Address: 0x1C
; 32-REL-NEXT:    Symbol: .___memmove ([[#NFA+1]])
; 32-REL-NEXT:    IsSigned: Yes
; 32-REL-NEXT:    FixupBitValue: 0
; 32-REL-NEXT:    Length: 26
; 32-REL-NEXT:    Type: R_RBR (0x1A)
; 32-REL-NEXT:  }
; 32-REL-NEXT:}
; 32-REL-NEXT:  Section (index: 2) .data {
; 32-REL-NEXT:  Relocation {
; 32-REL-NEXT:    Virtual Address: 0x34
; 32-REL-NEXT:    Symbol: .memcpy ([[#NFA+5]])
; 32-REL-NEXT:    IsSigned: No
; 32-REL-NEXT:    FixupBitValue: 0
; 32-REL-NEXT:    Length: 32
; 32-REL-NEXT:    Type: R_POS (0x0)
; 32-REL-NEXT:  }
; 32-REL-NEXT:  Relocation {
; 32-REL-NEXT:    Virtual Address: 0x38
; 32-REL-NEXT:    Symbol: TOC ([[#NFA+13]])
; 32-REL-NEXT:    IsSigned: No
; 32-REL-NEXT:    FixupBitValue: 0
; 32-REL-NEXT:    Length: 32
; 32-REL-NEXT:    Type: R_POS (0x0)
; 32-REL-NEXT:  }
; 32-REL-NEXT:  Relocation {
; 32-REL-NEXT:    Virtual Address: 0x40
; 32-REL-NEXT:    Symbol: .call_memcpy ([[#NFA+7]])
; 32-REL-NEXT:    IsSigned: No
; 32-REL-NEXT:    FixupBitValue: 0
; 32-REL-NEXT:    Length: 32
; 32-REL-NEXT:    Type: R_POS (0x0)
; 32-REL-NEXT:  }
; 32-REL-NEXT:  Relocation {
; 32-REL-NEXT:    Virtual Address: 0x44
; 32-REL-NEXT:    Symbol: TOC ([[#NFA+13]])
; 32-REL-NEXT:    IsSigned: No
; 32-REL-NEXT:    FixupBitValue: 0
; 32-REL-NEXT:    Length: 32
; 32-REL-NEXT:    Type: R_POS (0x0)
; 32-REL-NEXT:  }
; 32-REL-NEXT:  }
; 32-REL-NEXT: ]

; 32-REL-NOT:  Type: R_RBR (0x1A)

; 32-DIS:      Disassembly of section .text:
; 32-DIS:      00000000 <.memcpy>:
; 32-DIS-NEXT:        0: 38 60 00 03                   li 3, 3
; 32-DIS-NEXT:        4: 4e 80 00 20                   blr
; 32-DIS-NEXT:        8: 60 00 00 00                   nop
; 32-DIS-NEXT:        c: 60 00 00 00                   nop
; 32-DIS:      00000010 <.call_memcpy>:
; 32-DIS-NEXT:       10: 7c 08 02 a6                   mflr 0
; 32-DIS-NEXT:       14: 94 21 ff c0                   stwu 1, -64(1)
; 32-DIS-NEXT:       18: 90 01 00 48                   stw 0, 72(1)
; 32-DIS-NEXT:       1c: 4b ff ff e5                   bl 0x0
; 32-DIS-NEXT:       20: 60 00 00 00                   nop
; 32-DIS-NEXT:       24: 38 21 00 40                   addi 1, 1, 64
; 32-DIS-NEXT:       28: 80 01 00 08                   lwz 0, 8(1)
; 32-DIS-NEXT:       2c: 7c 08 03 a6                   mtlr 0
; 32-DIS-NEXT:       30: 4e 80 00 20                   blr
