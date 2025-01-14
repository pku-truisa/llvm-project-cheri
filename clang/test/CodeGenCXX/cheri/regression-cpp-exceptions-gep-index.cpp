// NOTE: Assertions have been autogenerated by utils/update_cc_test_checks.py UTC_ARGS: --function-signature
// RUN: %cheri_purecap_cc1 -fcxx-exceptions -fexceptions -o - -emit-llvm %s | FileCheck %s
// This code previously triggered a verification error due to a mismerge (missing call to @llvm.cheri.cap.address.get.i64):
// GEP indexes must be integers
//   %add.ptr = getelementptr inbounds i8, i8 addrspace(200)* %2, %vbase.offset
class a {
public:
  void b();
};
class c : virtual public a {};
// CHECK-LABEL: define {{[^@]+}}@_Z1dv
// CHECK-SAME: () addrspace(200) #[[ATTR0:[0-9]+]] {
// CHECK-NEXT:  entry:
// CHECK-NEXT:    [[E:%.*]] = alloca [[CLASS_C:%.*]], align 16, addrspace(200)
// CHECK-NEXT:    call void @_ZN1cC1Ev(ptr addrspace(200) noundef nonnull align 16 dereferenceable(16) [[E]]) #[[ATTR4:[0-9]+]]
// CHECK-NEXT:    [[VTABLE:%.*]] = load ptr addrspace(200), ptr addrspace(200) [[E]], align 16
// CHECK-NEXT:    [[VBASE_OFFSET_PTR:%.*]] = getelementptr i8, ptr addrspace(200) [[VTABLE]], i64 -48
// CHECK-NEXT:    [[VBASE_OFFSET:%.*]] = load ptr addrspace(200), ptr addrspace(200) [[VBASE_OFFSET_PTR]], align 16
// CHECK-NEXT:    [[TMP0:%.*]] = call i64 @llvm.cheri.cap.address.get.i64(ptr addrspace(200) [[VBASE_OFFSET]])
// CHECK-NEXT:    [[ADD_PTR:%.*]] = getelementptr inbounds i8, ptr addrspace(200) [[E]], i64 [[TMP0]]
// CHECK-NEXT:    call void @_ZN1a1bEv(ptr addrspace(200) noundef nonnull align 1 dereferenceable(1) [[ADD_PTR]])
// CHECK-NEXT:    ret void
//
void d() {
  c e;
  e.b();
}
