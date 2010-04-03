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
    type: extern(LLVMTypeOf) func -> Type
    name: extern(LLVMGetValueName) func -> String
    setName: extern(LLVMSetValueName) func (String)
    dump: extern(LLVMDumpValue) func
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
//LLVMBuilderRef LLVMCreateBuilderInContext(LLVMContextRef C);

    new: extern(LLVMCreateBuilder) static func -> This

    new: static func ~atEnd (basicBlock: BasicBlock) -> This {
        builder := This new()
        builder positionAtEnd(basicBlock)
        return builder
    }

    position: extern(LLVMPositionBuilder) func (BasicBlock, Value)
    positionBefore: extern (LLVMPositionBuilderBefore) func (Value)
    positionAtEnd: extern(LLVMPositionBuilderAtEnd) func (BasicBlock)
    getInsertBlock: extern(LLVMGetInsertBlock) func -> BasicBlock
    clearInsertionPosition: extern(LLVMClearInsertionPosition) func
    insert: extern(LLVMInsertIntoBuilder) func (Value)
    insert: extern(LLVMInsertIntoBuilderWithName) func ~withName (Value, String)

    dispose: extern(LLVMDisposeBuilder) func

    // Terminator instructions
    retVoid: extern(LLVMBuildRetVoid) func -> Value
    ret: extern(LLVMBuildRet) func (Value) -> Value
    aggregateRet: extern(LLVMBuildAggregateRet) func (Value*, UInt) -> Value
    br: extern(LLVMBuildBr) func (dest: BasicBlock) -> Value
    condBr: extern(LLVMBuildCondBr) func (condition: Value,
                                          thenBlock: BasicBlock,
                                          elseBlock: BasicBlock
                                         ) -> Value
    switch: extern(LLVMBuildSwitch) func (val: Value,
                                          elseBlock: BasicBlock,
                                          numCases: UInt
                                         ) -> Value
    invoke: extern(LLVMBuildInvoke) func (fn: Value,
                                          args: Value*,
                                          numArgs: UInt,
                                          thenBlock: BasicBlock,
                                          catchBlock: BasicBlock,
                                          name: String
                                         ) -> Value
    unwind: extern(LLVMBuildUnwind) func -> Value
    unreachable: extern(LLVMBuildUnreachable) func -> Value

///* Add a case to the switch instruction */
//void LLVMAddCase(LLVMValueRef Switch, LLVMValueRef OnVal,
//                 LLVMBasicBlockRef Dest);

    // Arithmetic instructions
    add: extern(LLVMBuildAdd)   func (lhs, rhs: Value, name: String) -> Value
    add_nsw: extern(LLVMBuildNSWAdd) func (lhs, rhs: Value, name: String) -> Value
    fadd: extern(LLVMBuildFAdd) func (lhs, rhs: Value, name: String) -> Value
    sub: extern(LLVMBuildSub)   func (lhs, rhs: Value, name: String) -> Value
    fsub: extern(LLVMBuildFSub) func (lhs, rhs: Value, name: String) -> Value
    mul: extern(LLVMBuildMul)   func (lhs, rhs: Value, name: String) -> Value
    fmul: extern(LLVMBuildFMul) func (lhs, rhs: Value, name: String) -> Value
    udiv: extern(LLVMBuildUDiv) func (lhs, rhs: Value, name: String) -> Value
    sdiv: extern(LLVMBuildSDiv) func (lhs, rhs: Value, name: String) -> Value
    sdiv_exact: extern(LLVMBuildExactSDiv) func (lhs, rhs: Value, name: String) -> Value
    fdiv: extern(LLVMBuildFDiv) func (lhs, rhs: Value, name: String) -> Value
    urem: extern(LLVMBuildURem) func (lhs, rhs: Value, name: String) -> Value
    srem: extern(LLVMBuildSRem) func (lhs, rhs: Value, name: String) -> Value
    frem: extern(LLVMBuildFRem) func (lhs, rhs: Value, name: String) -> Value
    shl: extern(LLVMBuildShl)   func (lhs, rhs: Value, name: String) -> Value
    lshl: extern(LLVMBuildLShr) func (lhs, rhs: Value, name: String) -> Value
    ashr: extern(LLVMBuildAShr) func (lhs, rhs: Value, name: String) -> Value
    and: extern(LLVMBuildAnd)   func (lhs, rhs: Value, name: String) -> Value
    or: extern(LLVMBuildOr)     func (lhs, rhs: Value, name: String) -> Value
    xor: extern(LLVMBuildXor)   func (lhs, rhs: Value, name: String) -> Value
    neg: extern(LLVMBuildNeg) func (val: Value, name: String) -> Value
    not: extern(LLVMBuildNot) func (val: Value, name: String) -> Value

    // Memory instructions
//    malloc: extern(LLVMBuildMalloc) func ()
}


LLVMGetFirstParam: extern func (Function) -> Value
LLVMGetNextParam: extern func (Value) -> Value
