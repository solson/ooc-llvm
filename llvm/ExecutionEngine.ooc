use llvm
import Core

// Generic values
GenericValue: cover from LLVMGenericValueRef {
//    new: extern(LLVMCreateGenericValueOfInt) static func ~int (Type, ULLong, isSigned: Int) -> This
//    new: extern(LLVMCreateGenericValueOfPointer) static func ~pointer (Pointer) -> This
//    new: extern(LLVMCreateGenericValueOfFloat) static func ~float (Type, Double) -> This

    new: extern(LLVMCreateGenericValueOfInt) static func (Type, ULLong, Int) -> This

    intWidth: extern(LLVMGenericValueIntWidth) func -> UInt
    toInt: extern(LLVMGenericValueToInt) func (isSigned: Int) -> ULLong
    toPointer: extern(LLVMGenericValueToPointer) func -> Pointer
    toFloat: func (ty: Type) -> Double {
        LLVMGenericValueToFloat(ty, this)
    }
}

LLVMGenericValueToFloat: extern func (Type, GenericValue) -> Double

// Execution engines
ExecutionEngine: cover from LLVMExecutionEngineRef {
    new: static func (mp: ModuleProvider) -> This {
        e: This = null
        error := null as String
        LLVMCreateJITCompiler(e&, mp, 0, error&)
        if(error != null) {
            Exception new(error) throw()
        }
        return e
    }

    dispose: extern(LLVMDisposeExecutionEngine) func

    runFunction: extern(LLVMRunFunction) func (fn: Value, numArgs: UInt, args: GenericValue*) -> GenericValue
}

LLVMCreateJITCompiler: extern func (ExecutionEngine*, ModuleProvider, UInt, String*) -> Int
