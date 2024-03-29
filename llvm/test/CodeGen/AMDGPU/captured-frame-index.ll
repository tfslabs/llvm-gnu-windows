; RUN: llc -mtriple=amdgcn-- -mcpu=tahiti -mattr=-promote-alloca -verify-machineinstrs < %s | FileCheck -check-prefix=GCN %s

; GCN-LABEL: {{^}}store_fi_lifetime:
; GCN: v_mov_b32_e32 [[FI:v[0-9]+]], 0{{$}}
; GCN: buffer_store_dword [[FI]]
define amdgpu_kernel void @store_fi_lifetime(ptr addrspace(1) %out, i32 %in) #0 {
entry:
  %b = alloca i8, addrspace(5)
  call void @llvm.lifetime.start.p5(i64 1, ptr addrspace(5) %b)
  store volatile ptr addrspace(5) %b, ptr addrspace(1) undef
  call void @llvm.lifetime.end.p5(i64 1, ptr addrspace(5) %b)
  ret void
}

; GCN-LABEL: {{^}}stored_fi_to_lds:
; GCN: s_load_dword [[LDSPTR:s[0-9]+]]
; GCN: v_mov_b32_e32 [[ZERO0:v[0-9]+]], 0{{$}}
; GCN: buffer_store_dword v{{[0-9]+}}, off,
; GCN: v_mov_b32_e32 [[VLDSPTR:v[0-9]+]], [[LDSPTR]]
; GCN: ds_write_b32  [[VLDSPTR]], [[ZERO0]]
define amdgpu_kernel void @stored_fi_to_lds(ptr addrspace(3) %ptr) #0 {
  %tmp = alloca float, addrspace(5)
  store float 4.0, ptr  addrspace(5) %tmp
  store ptr addrspace(5) %tmp, ptr addrspace(3) %ptr
  ret void
}

; Offset is applied
; GCN-LABEL: {{^}}stored_fi_to_lds_2_small_objects:
; GCN-DAG: v_mov_b32_e32 [[ZERO:v[0-9]+]], 0{{$}}
; GCN-DAG: buffer_store_dword v{{[0-9]+}}, off, s{{\[[0-9]+:[0-9]+\]}}, 0{{$}}
; GCN-DAG: buffer_store_dword v{{[0-9]+}}, off, s{{\[[0-9]+:[0-9]+\]}}, 0 offset:4{{$}}

; GCN-DAG: s_load_dword [[LDSPTR:s[0-9]+]]

; GCN-DAG: v_mov_b32_e32 [[VLDSPTR:v[0-9]+]], [[LDSPTR]]
; GCN: ds_write_b32  [[VLDSPTR]], [[ZERO]]

; GCN-DAG: v_mov_b32_e32 [[FI1:v[0-9]+]], 4{{$}}
; GCN: ds_write_b32  [[VLDSPTR]], [[FI1]]
define amdgpu_kernel void @stored_fi_to_lds_2_small_objects(ptr addrspace(3) %ptr) #0 {
  %tmp0 = alloca float, addrspace(5)
  %tmp1 = alloca float, addrspace(5)
  store float 4.0, ptr addrspace(5) %tmp0
  store float 4.0, ptr addrspace(5) %tmp1
  store volatile ptr addrspace(5) %tmp0, ptr addrspace(3) %ptr
  store volatile ptr addrspace(5) %tmp1, ptr addrspace(3) %ptr
  ret void
}

; Same frame index is used multiple times in the store
; GCN-LABEL: {{^}}stored_fi_to_self:
; GCN-DAG: v_mov_b32_e32 [[K:v[0-9]+]], 0x4d2{{$}}
; GCN: buffer_store_dword [[K]], off, s{{\[[0-9]+:[0-9]+\]}}, 0{{$}}
; GCN-DAG: v_mov_b32_e32 [[ZERO:v[0-9]+]], 0{{$}}
; GCN: buffer_store_dword [[ZERO]], off, s{{\[[0-9]+:[0-9]+\]}}, 0{{$}}
define amdgpu_kernel void @stored_fi_to_self() #0 {
  %tmp = alloca ptr addrspace(5), addrspace(5)

  ; Avoid optimizing everything out
  store volatile ptr addrspace(5) inttoptr (i32 1234 to ptr addrspace(5)), ptr addrspace(5) %tmp
  store volatile ptr addrspace(5) %tmp, ptr addrspace(5) %tmp
  ret void
}

; GCN-LABEL: {{^}}stored_fi_to_self_offset:
; GCN-DAG: v_mov_b32_e32 [[K0:v[0-9]+]], 32{{$}}
; GCN: buffer_store_dword [[K0]], off, s{{\[[0-9]+:[0-9]+\]}}, 0{{$}}

; GCN-DAG: v_mov_b32_e32 [[K1:v[0-9]+]], 0x4d2{{$}}
; GCN: buffer_store_dword [[K1]], off, s{{\[[0-9]+:[0-9]+\]}}, 0 offset:2048{{$}}

; GCN: v_mov_b32_e32 [[OFFSETK:v[0-9]+]], 0x800{{$}}
; GCN: buffer_store_dword [[OFFSETK]], off, s{{\[[0-9]+:[0-9]+\]}}, 0 offset:2048{{$}}
define amdgpu_kernel void @stored_fi_to_self_offset() #0 {
  %tmp0 = alloca [512 x i32], addrspace(5)
  %tmp1 = alloca ptr addrspace(5), addrspace(5)

  ; Avoid optimizing everything out
  store volatile i32 32, ptr addrspace(5) %tmp0

  store volatile ptr addrspace(5) inttoptr (i32 1234 to ptr addrspace(5)), ptr addrspace(5) %tmp1

  store volatile ptr addrspace(5) %tmp1, ptr addrspace(5) %tmp1
  ret void
}

; GCN-LABEL: {{^}}stored_fi_to_fi:
; GCN: buffer_store_dword v{{[0-9]+}}, off, s{{\[[0-9]+:[0-9]+\]}}, 0{{$}}
; GCN: buffer_store_dword v{{[0-9]+}}, off, s{{\[[0-9]+:[0-9]+\]}}, 0 offset:4{{$}}
; GCN: buffer_store_dword v{{[0-9]+}}, off, s{{\[[0-9]+:[0-9]+\]}}, 0 offset:8{{$}}

; GCN: v_mov_b32_e32 [[FI1:v[0-9]+]], 4{{$}}
; GCN: buffer_store_dword [[FI1]], off, s{{\[[0-9]+:[0-9]+\]}}, 0 offset:8{{$}}

; GCN: v_mov_b32_e32 [[FI2:v[0-9]+]], 8{{$}}
; GCN: buffer_store_dword [[FI2]], off, s{{\[[0-9]+:[0-9]+\]}}, 0 offset:4{{$}}
define amdgpu_kernel void @stored_fi_to_fi() #0 {
  %tmp0 = alloca ptr addrspace(5), addrspace(5)
  %tmp1 = alloca ptr addrspace(5), addrspace(5)
  %tmp2 = alloca ptr addrspace(5), addrspace(5)
  store volatile ptr addrspace(5) inttoptr (i32 1234 to ptr addrspace(5)), ptr addrspace(5) %tmp0
  store volatile ptr addrspace(5) inttoptr (i32 5678 to ptr addrspace(5)), ptr addrspace(5) %tmp1
  store volatile ptr addrspace(5) inttoptr (i32 9999 to ptr addrspace(5)), ptr addrspace(5) %tmp2


  store volatile ptr addrspace(5) %tmp1, ptr addrspace(5) %tmp2 ; store offset 0 at offset 4
  store volatile ptr addrspace(5) %tmp2, ptr addrspace(5) %tmp1 ; store offset 4 at offset 0
  ret void
}

; GCN-LABEL: {{^}}stored_fi_to_global:
; GCN: buffer_store_dword v{{[0-9]+}}, off, s{{\[[0-9]+:[0-9]+\]}}, 0{{$}}
; GCN: v_mov_b32_e32 [[FI:v[0-9]+]], 0{{$}}
; GCN: buffer_store_dword [[FI]]
define amdgpu_kernel void @stored_fi_to_global(ptr addrspace(1) %ptr) #0 {
  %tmp = alloca float, addrspace(5)
  store float 0.0, ptr  addrspace(5) %tmp
  store ptr addrspace(5) %tmp, ptr addrspace(1) %ptr
  ret void
}

; Offset is applied
; GCN-LABEL: {{^}}stored_fi_to_global_2_small_objects:
; GCN: buffer_store_dword v{{[0-9]+}}, off, s{{\[[0-9]+:[0-9]+\]}}, 0{{$}}
; GCN: buffer_store_dword v{{[0-9]+}}, off, s{{\[[0-9]+:[0-9]+\]}}, 0 offset:4{{$}}
; GCN: buffer_store_dword v{{[0-9]+}}, off, s{{\[[0-9]+:[0-9]+\]}}, 0 offset:8{{$}}

; GCN: v_mov_b32_e32 [[FI1:v[0-9]+]], 4{{$}}
; GCN: buffer_store_dword [[FI1]], off, s{{\[[0-9]+:[0-9]+\]}}, 0{{$}}

; GCN-DAG: v_mov_b32_e32 [[FI2:v[0-9]+]], 8{{$}}
; GCN: buffer_store_dword [[FI2]], off, s{{\[[0-9]+:[0-9]+\]}}, 0{{$}}
define amdgpu_kernel void @stored_fi_to_global_2_small_objects(ptr addrspace(1) %ptr) #0 {
  %tmp0 = alloca float, addrspace(5)
  %tmp1 = alloca float, addrspace(5)
  %tmp2 = alloca float, addrspace(5)
  store volatile float 0.0, ptr  addrspace(5) %tmp0
  store volatile float 0.0, ptr  addrspace(5) %tmp1
  store volatile float 0.0, ptr  addrspace(5) %tmp2
  store volatile ptr addrspace(5) %tmp1, ptr addrspace(1) %ptr
  store volatile ptr addrspace(5) %tmp2, ptr addrspace(1) %ptr
  ret void
}

; GCN-LABEL: {{^}}stored_fi_to_global_huge_frame_offset:
; GCN: v_mov_b32_e32 [[BASE_0:v[0-9]+]], 0{{$}}
; GCN: buffer_store_dword [[BASE_0]], off, s{{\[[0-9]+:[0-9]+\]}}, 0 offset:4{{$}}

; FIXME: Re-initialize
; GCN: v_mov_b32_e32 [[BASE_0_1:v[0-9]+]], 4{{$}}

; GCN-DAG: v_mov_b32_e32 [[K:v[0-9]+]], 0x3e7{{$}}
; GCN-DAG: v_add_i32_e32 [[BASE_1_OFF_1:v[0-9]+]], vcc, 0x3ffc, [[BASE_0_1]]


; GCN: v_add_i32_e32 [[BASE_1_OFF_2:v[0-9]+]], vcc, 56, [[BASE_0_1]]
; GCN: buffer_store_dword [[K]], [[BASE_1_OFF_1]], s{{\[[0-9]+:[0-9]+\]}}, 0 offen{{$}}

; GCN: buffer_store_dword [[BASE_1_OFF_2]], off, s{{\[[0-9]+:[0-9]+\]}}, 0{{$}}
define amdgpu_kernel void @stored_fi_to_global_huge_frame_offset(ptr addrspace(1) %ptr) #0 {
  %tmp0 = alloca [4096 x i32], addrspace(5)
  %tmp1 = alloca [4096 x i32], addrspace(5)
  store volatile i32 0, ptr addrspace(5) %tmp0
  %gep1.tmp0 = getelementptr [4096 x i32], ptr addrspace(5) %tmp0, i32 0, i32 4095
  store volatile i32 999, ptr addrspace(5) %gep1.tmp0
  %gep0.tmp1 = getelementptr [4096 x i32], ptr addrspace(5) %tmp0, i32 0, i32 14
  store ptr addrspace(5) %gep0.tmp1, ptr addrspace(1) %ptr
  ret void
}

@g1 = external addrspace(1) global ptr addrspace(5)

; This was leaving a dead node around resulting in failing to select
; on the leftover AssertZext's ValueType operand.

; GCN-LABEL: {{^}}cannot_select_assertzext_valuetype:
; GCN: s_getpc_b64 s[[[PC_LO:[0-9]+]]:[[PC_HI:[0-9]+]]]
; GCN: s_add_u32 s{{[0-9]+}}, s[[PC_LO]], g1@gotpcrel32@lo+4
; GCN: s_addc_u32 s{{[0-9]+}}, s[[PC_HI]], g1@gotpcrel32@hi+12
; GCN: v_mov_b32_e32 [[FI:v[0-9]+]], 0{{$}}
; GCN: buffer_store_dword [[FI]]
define amdgpu_kernel void @cannot_select_assertzext_valuetype(ptr addrspace(1) %out, i32 %idx) #0 {
entry:
  %b = alloca i32, align 4, addrspace(5)
  %tmp1 = load volatile ptr addrspace(5), ptr addrspace(1) @g1, align 4
  %arrayidx = getelementptr inbounds i32, ptr addrspace(5) %tmp1, i32 %idx
  %tmp2 = load i32, ptr addrspace(5) %arrayidx, align 4
  store volatile ptr addrspace(5) %b, ptr addrspace(1) undef
  ret void
}

declare void @llvm.lifetime.start.p5(i64, ptr addrspace(5) nocapture) #1
declare void @llvm.lifetime.end.p5(i64, ptr addrspace(5) nocapture) #1

attributes #0 = { nounwind }
attributes #1 = { argmemonly nounwind }
