; RUN: llc -mtriple=aarch64-- -mattr=+sve < %s

; This regression test is defending against using the wrong interface for TypeSize.
; This issue appeared in DAGCombiner::visitLIFETIME_END when visiting a LIFETIME_END
; node linked to a scalable store.

declare void @llvm.lifetime.start.p0(i64, ptr nocapture)
declare void @llvm.lifetime.end.p0(i64, ptr nocapture)

define void @foo(ptr nocapture dereferenceable(16) %ptr) {
entry:
  %tmp = alloca <vscale x 4 x i32>, align 8
  %tmp_ptr = bitcast ptr %tmp to ptr
  call void @llvm.lifetime.start.p0(i64 32, ptr %tmp_ptr)
  store <vscale x 4 x i32> undef, ptr %ptr
  call void @llvm.lifetime.end.p0(i64 32, ptr %tmp_ptr)
  ret void
}
