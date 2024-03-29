; RUN: llc < %s -mtriple=x86_64-apple-darwin -mcpu=corei7     | FileCheck --check-prefixes=ALL %s
; RUN: llc < %s -mtriple=x86_64-apple-darwin -mcpu=corei7-avx | FileCheck --check-prefixes=ALL,AVX %s

; Don't need to preserve registers before using them.
define preserve_nonecc double @preserve_nonecc1() nounwind {
entry:
;ALL-LABEL:   preserve_nonecc1
;ALL-NOT:     movq %rax
;ALL-NOT:     movq %rbx
;ALL-NOT:     movq %rcx
;ALL-NOT:     movq %rdx
;ALL-NOT:     movq %rsi
;ALL-NOT:     movq %rdi
;ALL-NOT:     movq %r8
;ALL-NOT:     movq %r9
;ALL-NOT:     movq %r10
;ALL-NOT:     movq %r11
;ALL-NOT:     movq %r12
;ALL-NOT:     movq %r13
;ALL-NOT:     movq %r14
;ALL-NOT:     movq %r15
;ALL-NOT:     movaps %xmm1
;ALL-NOT:     movaps %xmm0
;AVX-NOT:     vmovups %ymm1
;AVX-NOT:     vmovups %ymm0
;ALL-NOT:     movq {{.*}}, %rax
;ALL-NOT:     movq {{.*}}, %rbx
;ALL-NOT:     movq {{.*}}, %rcx
;ALL-NOT:     movq {{.*}}, %rdx
;ALL-NOT:     movq {{.*}}, %rsi
;ALL-NOT:     movq {{.*}}, %rdi
;ALL-NOT:     movq {{.*}}, %r8
;ALL-NOT:     movq {{.*}}, %r9
;ALL-NOT:     movq {{.*}}, %r10
;ALL-NOT:     movq {{.*}}, %r11
;ALL-NOT:     movq {{.*}}, %r12
;ALL-NOT:     movq {{.*}}, %r13
;ALL-NOT:     movq {{.*}}, %r14
;ALL-NOT:     movq {{.*}}, %r15
;ALL-NOT:     movaps {{.*}} %xmm0
;ALL-NOT:     movaps {{.*}} %xmm1
;AVX-NOT:     vmovups {{.*}} %ymm0
;AVX-NOT:     vmovups {{.*}} %ymm1
  call void asm sideeffect "", "~{rax},~{rbx},~{rcx},~{rdx},~{rsi},~{rdi},~{r8},~{r9},~{r10},~{r11},~{r12},~{r13},~{r14},~{r15},~{rbp},~{xmm0},~{xmm1},~{xmm2},~{xmm3},~{xmm4},~{xmm5},~{xmm6},~{xmm7},~{xmm8},~{xmm9},~{xmm10},~{xmm11},~{xmm12},~{xmm13},~{xmm14},~{xmm15}"()
  ret double 0.
}

; Save/restore live registers across preserve_none function call.
declare preserve_nonecc double @bar_double(i64, i64)
define void @preserve_nonecc2() nounwind {
entry:
;ALL-LABEL: preserve_nonecc2
;ALL:       movq %rax
;ALL:       movq %rcx
;ALL:       movq %rdx
;ALL:       movq %r8
;ALL:       movq %r9
;ALL:       movq %r10
;ALL:       movq %r11
;ALL:       movaps %xmm0
;ALL:       movaps %xmm1
;ALL:       movaps %xmm2
;ALL:       movaps %xmm3
;ALL:       movaps %xmm4
;ALL:       movaps %xmm5
;ALL:       movaps %xmm6
;ALL:       movaps %xmm7
;ALL:       movaps %xmm8
;ALL:       movaps %xmm9
;ALL:       movaps %xmm10
;ALL:       movaps %xmm11
;ALL:       movaps %xmm12
;ALL:       movaps %xmm13
;ALL:       movaps %xmm14
;ALL:       movaps %xmm15
;ALL:       movq {{.*}}, %rax
;ALL:       movq {{.*}}, %rcx
;ALL:       movq {{.*}}, %rdx
;ALL:       movq {{.*}}, %r8
;ALL:       movq {{.*}}, %r9
;ALL:       movq {{.*}}, %r10
;ALL:       movq {{.*}}, %r11
;ALL:       movaps {{.*}} %xmm0
;ALL:       movaps {{.*}} %xmm1
;ALL:       movaps {{.*}} %xmm2
;ALL:       movaps {{.*}} %xmm3
;ALL:       movaps {{.*}} %xmm4
;ALL:       movaps {{.*}} %xmm5
;ALL:       movaps {{.*}} %xmm6
;ALL:       movaps {{.*}} %xmm7
;ALL:       movaps {{.*}} %xmm8
;ALL:       movaps {{.*}} %xmm9
;ALL:       movaps {{.*}} %xmm10
;ALL:       movaps {{.*}} %xmm11
;ALL:       movaps {{.*}} %xmm12
;ALL:       movaps {{.*}} %xmm13
;ALL:       movaps {{.*}} %xmm14
;ALL:       movaps {{.*}} %xmm15
  %a0 = call i64 asm sideeffect "", "={rax}"() nounwind
  %a1 = call i64 asm sideeffect "", "={rcx}"() nounwind
  %a2 = call i64 asm sideeffect "", "={rdx}"() nounwind
  %a3 = call i64 asm sideeffect "", "={r8}"() nounwind
  %a4 = call i64 asm sideeffect "", "={r9}"() nounwind
  %a5 = call i64 asm sideeffect "", "={r10}"() nounwind
  %a6 = call i64 asm sideeffect "", "={r11}"() nounwind
  %a10 = call <2 x double> asm sideeffect "", "={xmm0}"() nounwind
  %a11 = call <2 x double> asm sideeffect "", "={xmm1}"() nounwind
  %a12 = call <2 x double> asm sideeffect "", "={xmm2}"() nounwind
  %a13 = call <2 x double> asm sideeffect "", "={xmm3}"() nounwind
  %a14 = call <2 x double> asm sideeffect "", "={xmm4}"() nounwind
  %a15 = call <2 x double> asm sideeffect "", "={xmm5}"() nounwind
  %a16 = call <2 x double> asm sideeffect "", "={xmm6}"() nounwind
  %a17 = call <2 x double> asm sideeffect "", "={xmm7}"() nounwind
  %a18 = call <2 x double> asm sideeffect "", "={xmm8}"() nounwind
  %a19 = call <2 x double> asm sideeffect "", "={xmm9}"() nounwind
  %a20 = call <2 x double> asm sideeffect "", "={xmm10}"() nounwind
  %a21 = call <2 x double> asm sideeffect "", "={xmm11}"() nounwind
  %a22 = call <2 x double> asm sideeffect "", "={xmm12}"() nounwind
  %a23 = call <2 x double> asm sideeffect "", "={xmm13}"() nounwind
  %a24 = call <2 x double> asm sideeffect "", "={xmm14}"() nounwind
  %a25 = call <2 x double> asm sideeffect "", "={xmm15}"() nounwind
  call preserve_nonecc double @bar_double(i64 1, i64 2)
  call void asm sideeffect "", "{rax},{rcx},{rdx},{r8},{r9},{r10},{r11},{xmm0},{xmm1},{xmm2},{xmm3},{xmm4},{xmm5},{xmm6},{xmm7},{xmm8},{xmm9},{xmm10},{xmm11},{xmm12},{xmm13},{xmm14},{xmm15}"(i64 %a0, i64 %a1, i64 %a2, i64 %a3, i64 %a4, i64 %a5, i64 %a6, <2 x double> %a10, <2 x double> %a11, <2 x double> %a12, <2 x double> %a13, <2 x double> %a14, <2 x double> %a15, <2 x double> %a16, <2 x double> %a17, <2 x double> %a18, <2 x double> %a19, <2 x double> %a20, <2 x double> %a21, <2 x double> %a22, <2 x double> %a23, <2 x double> %a24, <2 x double> %a25)
  ret void
}
