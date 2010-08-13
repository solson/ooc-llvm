use llvm
import llvm/Core

Target: cover from LLVMTargetDataRef {
    initializeAllInfos: extern(LLVMInitializeAllTargetInfos) static func

    initializeAll: extern(LLVMInitializeAllTargets) static func

    initializeNative: extern(LLVMInitializeNativeTarget) static func

    new: extern(LLVMCreateTargetData) static func (String) -> This

//    addToPassManager: extern(LLVMAddTargetData) static func (PassManager)

    toString: extern(LLVMCopyStringRepOfTargetData) func -> String

    byteOrder: extern(LLVMByteOrder) func -> ByteOrdering

    pointerSize: extern(LLVMPointerSize) func -> UInt

    intPointerType: extern(LLVMIntPtrType) func -> Type

    sizeOfTypeInBits: extern(LLVMSizeOfTypeInBits) func (Type) -> ULLong

    storeSizeOfType: extern(LLVMStoreSizeOfType) func (Type) -> ULLong

    abiSizeOfType: extern(LLVMABISizeOfType) func (Type) -> ULLong

    abiAlignmentOfType: extern(LLVMABIAlignmentOfType) func (Type) -> UInt

    callFrameAlignmentOfType: extern(LLVMCallFrameAlignmentOfType) func (Type) -> UInt

    preferredAlignmentOfType: extern(LLVMPreferredAlignmentOfType) func (Type) -> UInt

    preferredAlignmentOfGlobal: extern(LLVMPreferredAlignmentOfGlobal) func (Value) -> UInt

    elementAtOffset: extern(LLVMElementAtOffset) func (Type, ULLong) -> UInt

    offsetOfElement: extern(LLVMOffsetOfElement) func (Type, UInt) -> ULLong

    invalidateStructLayout: extern(LLVMInvalidateStructLayout) func (Type)

    dispose: extern(LLVMDisposeTargetData) func
}

ByteOrdering: enum { /* extern(enum LLVMByteOrdering) */
    bigEndian: extern(LLVMBigEndian)
    littleEndian: extern(LLVMLittleEndian)
}
