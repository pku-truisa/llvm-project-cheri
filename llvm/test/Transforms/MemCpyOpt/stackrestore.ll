; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: opt -S -memcpyopt < %s -verify-memoryssa | FileCheck %s

; PR40118: BasicAA didn't realize that stackrestore ends the lifetime of
; unescaped dynamic allocas, such as those that might come from inalloca.

source_filename = "t.cpp"
target datalayout = "e-m:x-p:32:32-i64:64-f80:32-n8:16:32-a:0:32-S32"
target triple = "i686-unknown-windows-msvc19.14.26433"

@str = internal constant [9 x i8] c"abcdxxxxx"


; Test that we can propagate memcpy through an unescaped dynamic alloca across
; a call to @external.

define i32 @test_norestore(i32 %n) {
; CHECK-LABEL: @test_norestore(
; CHECK-NEXT:    [[TMPMEM:%.*]] = alloca [10 x i8], align 4
; CHECK-NEXT:    [[TMP:%.*]] = getelementptr inbounds [10 x i8], [10 x i8]* [[TMPMEM]], i32 0, i32 0
; CHECK-NEXT:    [[P:%.*]] = alloca i8, i32 [[N:%.*]], align 4
; CHECK-NEXT:    call void @llvm.memcpy.p0i8.p0i8.i32(i8* [[P]], i8* align 1 getelementptr inbounds ([9 x i8], [9 x i8]* @str, i32 0, i32 0), i32 9, i1 false)
; CHECK-NEXT:    [[P10:%.*]] = getelementptr inbounds i8, i8* [[P]], i32 9
; CHECK-NEXT:    store i8 0, i8* [[P10]], align 1
; CHECK-NEXT:    call void @llvm.memcpy.p0i8.p0i8.i32(i8* [[TMP]], i8* [[P]], i32 10, i1 false)
; CHECK-NEXT:    call void @external()
; CHECK-NEXT:    [[HEAP:%.*]] = call i8* @malloc(i32 9)
; CHECK-NEXT:    call void @llvm.memcpy.p0i8.p0i8.i32(i8* [[HEAP]], i8* align 1 getelementptr inbounds ([9 x i8], [9 x i8]* @str, i32 0, i32 0), i32 9, i1 false)
; CHECK-NEXT:    call void @useit(i8* [[HEAP]])
; CHECK-NEXT:    ret i32 0
;
  %tmpmem = alloca [10 x i8], align 4
  %tmp = getelementptr inbounds [10 x i8], [10 x i8]* %tmpmem, i32 0, i32 0

  ; Make a dynamic alloca, initialize it.
  %p = alloca i8, i32 %n, align 4
  call void @llvm.memcpy.p0i8.p0i8.i32(i8* %p, i8* align 1 getelementptr inbounds ([9 x i8], [9 x i8]* @str, i32 0, i32 0), i32 9, i1 false)

  ; This extra byte exists to prevent memcpyopt from propagating @str.
  %p10 = getelementptr inbounds i8, i8* %p, i32 9
  store i8 0, i8* %p10

  call void @llvm.memcpy.p0i8.p0i8.i32(i8* %tmp, i8* %p, i32 10, i1 false)
  call void @external()
  %heap = call i8* @malloc(i32 9)
  call void @llvm.memcpy.p0i8.p0i8.i32(i8* %heap, i8* %tmp, i32 9, i1 false)
  call void @useit(i8* %heap)
  ret i32 0
}

; Do not propagate memcpy from %p across the stackrestore.

define i32 @test_stackrestore() {
; CHECK-LABEL: @test_stackrestore(
; CHECK-NEXT:    [[TMPMEM:%.*]] = alloca [10 x i8], align 4
; CHECK-NEXT:    [[TMP:%.*]] = getelementptr inbounds [10 x i8], [10 x i8]* [[TMPMEM]], i32 0, i32 0
; CHECK-NEXT:    [[INALLOCA_SAVE:%.*]] = tail call i8* @llvm.stacksave.p0i8()
; CHECK-NEXT:    [[ARGMEM:%.*]] = alloca inalloca [10 x i8], align 4
; CHECK-NEXT:    [[P:%.*]] = getelementptr inbounds [10 x i8], [10 x i8]* [[ARGMEM]], i32 0, i32 0
; CHECK-NEXT:    call void @llvm.memcpy.p0i8.p0i8.i32(i8* [[P]], i8* align 1 getelementptr inbounds ([9 x i8], [9 x i8]* @str, i32 0, i32 0), i32 9, i1 false)
; CHECK-NEXT:    [[P10:%.*]] = getelementptr inbounds [10 x i8], [10 x i8]* [[ARGMEM]], i32 0, i32 9
; CHECK-NEXT:    store i8 0, i8* [[P10]], align 1
; CHECK-NEXT:    call void @llvm.memcpy.p0i8.p0i8.i32(i8* [[TMP]], i8* [[P]], i32 10, i1 false)
; CHECK-NEXT:    call void @llvm.stackrestore.p0i8(i8* [[INALLOCA_SAVE]])
; CHECK-NEXT:    [[HEAP:%.*]] = call i8* @malloc(i32 9)
; CHECK-NEXT:    call void @llvm.memcpy.p0i8.p0i8.i32(i8* [[HEAP]], i8* [[TMP]], i32 9, i1 false)
; CHECK-NEXT:    call void @useit(i8* [[HEAP]])
; CHECK-NEXT:    ret i32 0
;
  %tmpmem = alloca [10 x i8], align 4
  %tmp = getelementptr inbounds [10 x i8], [10 x i8]* %tmpmem, i32 0, i32 0
  %inalloca.save = tail call i8* @llvm.stacksave()
  %argmem = alloca inalloca [10 x i8], align 4
  %p = getelementptr inbounds [10 x i8], [10 x i8]* %argmem, i32 0, i32 0
  call void @llvm.memcpy.p0i8.p0i8.i32(i8* %p, i8* align 1 getelementptr inbounds ([9 x i8], [9 x i8]* @str, i32 0, i32 0), i32 9, i1 false)

  ; This extra byte exists to prevent memcpyopt from propagating @str.
  %p10 = getelementptr inbounds [10 x i8], [10 x i8]* %argmem, i32 0, i32 9
  store i8 0, i8* %p10

  call void @llvm.memcpy.p0i8.p0i8.i32(i8* %tmp, i8* %p, i32 10, i1 false)
  call void @llvm.stackrestore(i8* %inalloca.save)
  %heap = call i8* @malloc(i32 9)
  call void @llvm.memcpy.p0i8.p0i8.i32(i8* %heap, i8* %tmp, i32 9, i1 false)
  call void @useit(i8* %heap)
  ret i32 0
}

declare void @llvm.memcpy.p0i8.p0i8.i32(i8* nocapture writeonly, i8* nocapture readonly, i32, i1)
declare i8* @llvm.stacksave()
declare void @llvm.stackrestore(i8*)
declare i8* @malloc(i32)
declare void @useit(i8*)
declare void @external()
