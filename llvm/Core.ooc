use llvm
import structs/ArrayList

Module: cover from LLVMModuleRef {
    new: extern(LLVMModuleCreateWithName) static func (String) -> This

    addFunction: func (functionType: Type, name: String) -> Function {
        Function new(this, name, functionType)
    }

    dump: extern(LLVMDumpModule) func
}


Type: cover from LLVMTypeRef {
    // Integer types
    int1:  extern(LLVMInt1Type)  static func -> This
    int8:  extern(LLVMInt8Type)  static func -> This
    int16: extern(LLVMInt16Type) static func -> This
    int32: extern(LLVMInt32Type) static func -> This
    int64: extern(LLVMInt64Type) static func -> This
    int:   extern(LLVMIntType)   static func (numBits: UInt) -> This
    getIntTypeWidth: extern(LLVMGetIntTypeWidth) func -> UInt

    // Real types
//LLVMTypeRef LLVMFloatTypeInContext(LLVMContextRef C);
//LLVMTypeRef LLVMDoubleTypeInContext(LLVMContextRef C);
//LLVMTypeRef LLVMX86FP80TypeInContext(LLVMContextRef C);
//LLVMTypeRef LLVMFP128TypeInContext(LLVMContextRef C);
//LLVMTypeRef LLVMPPCFP128TypeInContext(LLVMContextRef C);

    float:     extern(LLVMFloatType)    static func -> This
    double:    extern(LLVMDoubleType)   static func -> This
    x86_fp80:  extern(LLVMX86FP80Type)  static func -> This
    fp128:     extern(LLVMFP128Type)    static func -> This
    ppc_fp128: extern(LLVMPPCFP128Type) static func -> This

    // Function types
    function: extern(LLVMFunctionType) static func (returnType: Type, paramTypes: Type*, paramCount: UInt, isVarArg: Int) -> Type

    function: static func ~withArrayList (returnType: This, paramTypes: ArrayList<This>) -> This {
        function(returnType, paramTypes toArray(), paramTypes size(), false)
    }

    isFunctionVarArg: extern(LLVMIsFunctionVarArg) func -> Int
    getReturnType: extern(LLVMGetReturnType) func -> This
    countParamTypes: extern(LLVMCountParamTypes) func -> UInt
    getParamTypes: extern(LLVMGetParamTypes) func (dest: This*)

    // Struct types
//LLVMTypeRef LLVMStructTypeInContext(LLVMContextRef C, LLVMTypeRef *ElementTypes,
//                                    unsigned ElementCount, int Packed);
    structType: extern(LLVMStructType) static func (elementTypes: This*, elementCount: UInt, isPacked: Int) -> This
    countStructElementTypes: extern(LLVMCountStructElementTypes) func -> UInt
    getStructElementTypes: extern(LLVMGetStructElementTypes) func (dest: This*)
    isPackedStruct: extern(LLVMIsPackedStruct) func -> Int

    // Array, pointer, and vector rtpes (sequence types)
    array:   extern(LLVMArrayType)   static func (elementType: This, elementCount: UInt) -> This
    pointer: extern(LLVMPointerType) static func (elementType: This, addressSpace: UInt) -> This
    vector:  extern(LLVMVectorType)  static func (elementType: This, elementCount: UInt) -> This

    getElementType: extern(LLVMGetElementType) func -> This
    getArrayLength: extern(LLVMGetArrayLength) func -> UInt
    getPointerAddressSpace: extern(LLVMGetPointerAddressSpace) func -> UInt
    getVectorSize: extern(LLVMGetVectorSize) func -> UInt

    // Other types
//LLVMTypeRef LLVMVoidTypeInContext(LLVMContextRef C);
//LLVMTypeRef LLVMLabelTypeInContext(LLVMContextRef C);
//LLVMTypeRef LLVMOpaqueTypeInContext(LLVMContextRef C);

    void:   extern(LLVMVoidType)   static func -> This
    label:  extern(LLVMLabelType)  static func -> This
    opaque: extern(LLVMOpaqueType) static func -> This
}


Value: cover from LLVMValueRef {
    name: extern(LLVMGetValueName) func -> String
    setName: extern(LLVMSetValueName) func (String)
}


Function: cover from LLVMValueRef extends Value {
    new: extern(LLVMAddFunction) static func (module: Module, name: String, functionType: Type) -> This

    appendBasicBlock: extern(LLVMAppendBasicBlock) func (String) -> BasicBlock

    args: func -> ArrayList<Value> {
        argsList := ArrayList<Value> new()
        param := LLVMGetFirstParam(this)

        while (param) {
            argsList add(param)
            param = LLVMGetNextParam(param)
        }

        return argsList
    }
}


BasicBlock: cover from LLVMBasicBlockRef


Builder: cover from LLVMBuilderRef {
    new: extern(LLVMCreateBuilder) static func -> This

    new: static func ~atEnd (basicBlock: BasicBlock) -> This {
        builder := This new()
        builder positionAtEnd(basicBlock)
        return builder
    }

    positionAtEnd: extern(LLVMPositionBuilderAtEnd) func (BasicBlock)

    // terminator instructions
    ret: extern(LLVMBuildRet) func (Value)

    // arithmethic, bitwise and logical
    add: extern(LLVMBuildAdd) func (lhs, rhs: Value, name: String) -> Value
}


LLVMGetFirstParam: extern func (Function) -> Value
LLVMGetNextParam: extern func (Value) -> Value
