use llvm
import structs/ArrayList


// Modules
Context: cover from LLVMContextRef {
    new: extern(LLVMContextCreate) static func -> This

    getGlobal: extern(LLVMGetGlobalContext) static func -> This

    dispose: extern(LLVMContextDispose) func

    // Types
    float:     extern(LLVMFloatTypeInContext)    func -> Value
    double:    extern(LLVMDoubleTypeInContext)   func -> Value
    xf86_fp80: extern(LLVMX86FP80TypeInContext)  func -> Value
    fp128:     extern(LLVMFP128TypeInContext)    func -> Value
    ppc_fp128: extern(LLVMPPCFP128TypeInContext) func -> Value

    struct: extern(LLVMStructTypeInContext) func (elementTypes: Type*, elementCount: UInt, isPacked: Int) -> Value

    void:   extern(LLVMVoidTypeInContext)   func -> Value
    label:  extern(LLVMLabelTypeInContext)  func -> Value
    opaque: extern(LLVMOpaqueTypeInContext) func -> Value
}

Module: cover from LLVMModuleRef {
    new: extern(LLVMModuleCreateWithName) static func (String) -> This
    new: extern(LLVMModuleCreateWithNameInContext) static func ~inContext (String, Context) -> This

    dispose: extern(LLVMDisposeModule) func

    getDataLayout: extern(LLVMGetDataLayout) func -> String
    setDataLayout: extern(LLVMSetDataLayout) func (triple: String)

    getTarget: extern(LLVMGetTarget) func -> String
    setTarget: extern(LLVMSetTarget) func (triple: String)

    addTypeName: extern(LLVMAddTypeName) func (name: String, Type) -> Int
    deleteTypename: extern(LLVMDeleteTypeName) func (name: String)
    getTypeByName: extern(LLVMGetTypeByName) func (name: String) -> Type

    dump: extern(LLVMDumpModule) func

    addFunction: func (functionType: Type, name: String) -> Function {
        Function new(this, name, functionType)
    }
}


// Types
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
    float:     extern(LLVMFloatType)    static func -> This
    double:    extern(LLVMDoubleType)   static func -> This
    x86_fp80:  extern(LLVMX86FP80Type)  static func -> This
    fp128:     extern(LLVMFP128Type)    static func -> This
    ppc_fp128: extern(LLVMPPCFP128Type) static func -> This

    // Function types
    function: extern(LLVMFunctionType) static func (returnType: Type,
        paramTypes: Type*, paramCount: UInt, isVarArg: Int) -> Type

    function: static func ~withArrayList (returnType: This, paramTypes: ArrayList<This>) -> This {
        function(returnType, paramTypes toArray() as This*, paramTypes size(), false as Int)
    }

    isFunctionVarArg: extern(LLVMIsFunctionVarArg) func -> Int
    getReturnType: extern(LLVMGetReturnType) func -> This
    countParamTypes: extern(LLVMCountParamTypes) func -> UInt
    getParamTypes: extern(LLVMGetParamTypes) func (dest: This*)

    // Struct types
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
    void:   extern(LLVMVoidType)   static func -> This
    label:  extern(LLVMLabelType)  static func -> This
    opaque: extern(LLVMOpaqueType) static func -> This
}


Value: cover from LLVMValueRef {
    type: extern(LLVMTypeOf) func -> Type
    getName: extern(LLVMGetValueName) func -> String
    setName: extern(LLVMSetValueName) func (String)
    dump: extern(LLVMDumpValue) func
}


Function: cover from Value {
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
    new: extern(LLVMCreateBuilderInContext) static func ~inContext (Context) -> This

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

    condBr: extern(LLVMBuildCondBr) func (condition: Value, thenBlock: BasicBlock, elseBlock: BasicBlock) -> Value
    switch: extern(LLVMBuildSwitch) func (val: Value, elseBlock: BasicBlock, numCases: UInt) -> Value
    invoke: extern(LLVMBuildInvoke) func (fn: Value, args: Value*, numArgs: UInt, thenBlock: BasicBlock, catchBlock: BasicBlock, name: String) -> Value

    unwind: extern(LLVMBuildUnwind) func -> Value
    unreachable: extern(LLVMBuildUnreachable) func -> Value

    // Add a case to the switch instruction
    addCase: extern(LLVMAddCase) static func (switchInstr: Value, onVal: Value, dest: BasicBlock)

    // Arithmetic instructions
    add:  extern(LLVMBuildAdd)  func (lhs, rhs: Value, name: String) -> Value
    add_nsw: extern(LLVMBuildNSWAdd) func (lhs, rhs: Value, name: String) -> Value
    fadd: extern(LLVMBuildFAdd) func (lhs, rhs: Value, name: String) -> Value
    sub:  extern(LLVMBuildSub)  func (lhs, rhs: Value, name: String) -> Value
    fsub: extern(LLVMBuildFSub) func (lhs, rhs: Value, name: String) -> Value
    mul:  extern(LLVMBuildMul)  func (lhs, rhs: Value, name: String) -> Value
    fmul: extern(LLVMBuildFMul) func (lhs, rhs: Value, name: String) -> Value
    udiv: extern(LLVMBuildUDiv) func (lhs, rhs: Value, name: String) -> Value
    sdiv: extern(LLVMBuildSDiv) func (lhs, rhs: Value, name: String) -> Value
    sdiv_exact: extern(LLVMBuildExactSDiv) func (lhs, rhs: Value, name: String) -> Value
    fdiv: extern(LLVMBuildFDiv) func (lhs, rhs: Value, name: String) -> Value
    urem: extern(LLVMBuildURem) func (lhs, rhs: Value, name: String) -> Value
    srem: extern(LLVMBuildSRem) func (lhs, rhs: Value, name: String) -> Value
    frem: extern(LLVMBuildFRem) func (lhs, rhs: Value, name: String) -> Value
    shl:  extern(LLVMBuildShl)  func (lhs, rhs: Value, name: String) -> Value
    lshl: extern(LLVMBuildLShr) func (lhs, rhs: Value, name: String) -> Value
    ashr: extern(LLVMBuildAShr) func (lhs, rhs: Value, name: String) -> Value
    and:  extern(LLVMBuildAnd)  func (lhs, rhs: Value, name: String) -> Value
    or:   extern(LLVMBuildOr)   func (lhs, rhs: Value, name: String) -> Value
    xor:  extern(LLVMBuildXor)  func (lhs, rhs: Value, name: String) -> Value
    neg:  extern(LLVMBuildNeg)  func (val: Value, name: String) -> Value
    not:  extern(LLVMBuildNot)  func (val: Value, name: String) -> Value

    // Memory instructions
    malloc: extern(LLVMBuildMalloc) func (Type, name: String) -> Value
    alloca: extern(LLVMBuildAlloca) func (Type, name: String) -> Value
    arrayMalloc: extern(LLVMBuildArrayMalloc) func (Type, Value, name: String) -> Value
    arrayAlloca: extern(LLVMBuildArrayMalloc) func (Type, Value, name: String) -> Value

    free:  extern(LLVMBuildFree)  func (pointer: Value) -> Value
    load:  extern(LLVMBuildLoad)  func (pointer: Value, name: String) -> Value
    store: extern(LLVMBuildStore) func (val: Value, ptr: Value) -> Value

    gep: extern(LLVMBuildGEP) func (ptr: Value, indices: Value*, numIndicies: UInt, name: String) -> Value
    gep_inbounds: extern(LLVMBuildInBoundsGEP) func (ptr: Value, indices: Value*, numIndicies: UInt, name: String) -> Value
    gep_struct: extern(LLVMBuildStructGEP) func (ptr: Value, idx: UInt, name: String) -> Value

    globalString:    extern(LLVMBuildGlobalString)    func (str: String, name: String) -> Value
    globalStringPtr: extern(LLVMBuildGlobalStringPtr) func (str: String, name: String) -> Value

    // Cast instructions
    trunc:          extern(LLVMBuildTrunc)          func (Value, Type, name: String) -> Value
    zext:           extern(LLVMBuildZExt)           func (Value, Type, name: String) -> Value
    sext:           extern(LLVMBuildSExt)           func (Value, Type, name: String) -> Value
    fptoui:         extern(LLVMBuildFPToUI)         func (Value, Type, name: String) -> Value
    fptosi:         extern(LLVMBuildFPToSI)         func (Value, Type, name: String) -> Value
    uitofp:         extern(LLVMBuildUIToFP)         func (Value, Type, name: String) -> Value
    sitofp:         extern(LLVMBuildSIToFP)         func (Value, Type, name: String) -> Value
    fptrunc:        extern(LLVMBuildFPTrunc)        func (Value, Type, name: String) -> Value
    fpext:          extern(LLVMBuildFPExt)          func (Value, Type, name: String) -> Value
    ptrtoint:       extern(LLVMBuildPtrToInt)       func (Value, Type, name: String) -> Value
    inttoptr:       extern(LLVMBuildIntToPtr)       func (Value, Type, name: String) -> Value
    bitcast:        extern(LLVMBuildBitCast)        func (Value, Type, name: String) -> Value
    zextOrBitcast:  extern(LLVMBuildZExtOrBitCast)  func (Value, Type, name: String) -> Value
    sextOrBitcast:  extern(LLVMBuildSExtOrBitCast)  func (Value, Type, name: String) -> Value
    truncOrBitcast: extern(LLVMBuildTruncOrBitCast) func (Value, Type, name: String) -> Value
    pointerCast:    extern(LLVMBuildPointerCast)    func (Value, Type, name: String) -> Value
    intCast:        extern(LLVMBuildIntCast)        func (Value, Type, name: String) -> Value
    fpCast:         extern(LLVMBuildFPCast)         func (Value, Type, name: String) -> Value

    // Comparison instructions
    icmp: extern(LLVMBuildICmp) func (IntPredicate,  lhs, rhs: Value, name: String) -> Value
    fcmp: extern(LLVMBuildICmp) func (RealPredicate, lhs, rhs: Value, name: String) -> Value

    // Miscellaneous instructions
    phi: extern(LLVMBuildPhi) func (Type, name: String) -> Value
    call: extern(LLVMBuildCall) func (fn: Value, args: Value*, numArgs: UInt, name: String) -> Value
    select: extern(LLVMBuildSelect) func (ifVal, thenVal, elseVal: Value, name: String) -> Value
    va_arg: extern(LLVMBuildVAArg) func (list: Value, Type, name: String) -> Value
    extractElement: extern(LLVMBuildExtractElement) func (vector, index: Value, name: String) -> Value
    insertElement: extern(LLVMBuildInsertElement) func (vector, val, index: Value, name: String) -> Value
    shuffleVector: extern(LLVMBuildShuffleVector) func (v1, v2, mask: Value, name: String) -> Value
    extractValue: extern(LLVMBuildExtractValue) func (agg: Value, index: UInt, name: String) -> Value
    insertValue: extern(LLVMBuildInsertValue) func (agg, val: Value, index: UInt, name: String) -> Value

    isNull:    extern(LLVMBuildIsNull)    func (Value, name: String) -> Value
    isNotNull: extern(LLVMBuildIsNotNull) func (Value, name: String) -> Value
    ptrDiff:   extern(LLVMBuildPtrDiff)   func (lhs, rhs: Value, name: String) -> Value
}


LLVMGetFirstParam: extern func (Function) -> Value
LLVMGetNextParam: extern func (Value) -> Value


// Enums
Attribute: cover from LLVMAttribute {
    zext:            extern(LLVMZExtAttribute)            static This
    sext:            extern(LLVMSExtAttribute)            static This
    noReturn:        extern(LLVMNoReturnAttribute)        static This
    inReg:           extern(LLVMInRegAttribute)           static This
    structRet:       extern(LLVMStructRetAttribute)       static This
    noUnwind:        extern(LLVMNoUnwindAttribute)        static This
    noAlias:         extern(LLVMNoAliasAttribute)         static This
    byVal:           extern(LLVMByValAttribute)           static This
    nest:            extern(LLVMNestAttribute)            static This
    readNone:        extern(LLVMReadNoneAttribute)        static This
    readOnly:        extern(LLVMReadOnlyAttribute)        static This
    noInline:        extern(LLVMNoInlineAttribute)        static This
    alwaysInline:    extern(LLVMAlwaysInlineAttribute)    static This
    optimizeForSize: extern(LLVMOptimizeForSizeAttribute) static This
    stackProtect:    extern(LLVMStackProtectAttribute)    static This
    stackProtectReq: extern(LLVMStackProtectReqAttribute) static This
    noCapture:       extern(LLVMNoCaptureAttribute)       static This
    noRedZone:       extern(LLVMNoRedZoneAttribute)       static This
    noImplicitFloat: extern(LLVMNoImplicitFloatAttribute) static This
    naked:           extern(LLVMNakedAttribute)           static This
}

TypeKind: cover from LLVMTypeKind {
    void:      extern(LLVMVoidTypeKind)      static This
    float:     extern(LLVMFloatTypeKind)     static This
    double:    extern(LLVMDoubleTypeKind)    static This
    x86_fp80:  extern(LLVMX86_FP80TypeKind)  static This
    fp128:     extern(LLVMFP128TypeKind)     static This
    ppc_fp128: extern(LLVMPPC_FP128TypeKind) static This
    label:     extern(LLVMLabelTypeKind)     static This
    integer:   extern(LLVMIntegerTypeKind)   static This
    function:  extern(LLVMFunctionTypeKind)  static This
    struct:    extern(LLVMStructTypeKind)    static This
    array:     extern(LLVMArrayTypeKind)     static This
    pointer:   extern(LLVMPointerTypeKind)   static This
    opaque:    extern(LLVMOpaqueTypeKind)    static This
    vector:    extern(LLVMVectorTypeKind)    static This
    metadata:  extern(LLVMMetadataTypeKind)  static This
}

Linkage: cover from LLVMLinkage {
    external:            extern(LLVMExternalLinkage)            static This
    availableExternally: extern(LLVMAvailableExternallyLinkage) static This
    linkOnceAny:         extern(LLVMLinkOnceAnyLinkage)         static This
    linkOnceODR:         extern(LLVMLinkOnceODRLinkage)         static This
    weakAny:             extern(LLVMWeakAnyLinkage)             static This
    weakODR:             extern(LLVMWeakODRLinkage)             static This
    appending:           extern(LLVMAppendingLinkage)           static This
    internal:            extern(LLVMInternalLinkage)            static This
    private:             extern(LLVMPrivateLinkage)             static This
    dllImport:           extern(LLVMDLLImportLinkage)           static This
    dllExport:           extern(LLVMDLLExportLinkage)           static This
    externalWeak:        extern(LLVMExternalWeakLinkage)        static This
    ghost:               extern(LLVMGhostLinkage)               static This
    common:              extern(LLVMCommonLinkage)              static This
    linkerPrivate:       extern(LLVMLinkerPrivateLinkage)       static This
}

Visibility: cover from LLVMVisibility {
    default:   extern(LLVMDefaultVisibility)   static This
    hidden:    extern(LLVMHiddenVisibility)    static This
    protected: extern(LLVMProtectedVisibility) static This
}

CallConv: cover from LLVMCallConv {
    ccall:       extern(LLVMCCallConv)           static This
    fast:        extern(LLVMFastCallConv)        static This
    cold:        extern(LLVMColdCallConv)        static This
    x86stdcall:  extern(LLVMX86StdcallCallConv)  static This
    x86fastcall: extern(LLVMX86FastcallCallConv) static This
}

IntPredicate: cover from LLVMIntPredicate {
    eq:  extern(LLVMIntEQ)  static This
    ne:  extern(LLVMIntNE)  static This
    ugt: extern(LLVMIntUGT) static This
    uge: extern(LLVMIntUGE) static This
    ult: extern(LLVMIntULT) static This
    ule: extern(LLVMIntULE) static This
    sgt: extern(LLVMIntSGT) static This
    sge: extern(LLVMIntSGE) static This
    slt: extern(LLVMIntSLT) static This
    sle: extern(LLVMIntSLE) static This
}

RealPredicate: cover from LLVMRealPredicate {
    truePred:  extern(LLVMRealPredicateTrue)  static This
    falsePred: extern(LLVMRealPredicateFalse) static This
    oeq: extern(LLVMRealOEQ) static This
    ogt: extern(LLVMRealOGT) static This
    oge: extern(LLVMRealOGE) static This
    olt: extern(LLVMRealOLT) static This
    ole: extern(LLVMRealOLE) static This
    one: extern(LLVMRealONE) static This
    ord: extern(LLVMRealORD) static This
    uno: extern(LLVMRealUNO) static This
    ueq: extern(LLVMRealUEQ) static This
    ugt: extern(LLVMRealUGT) static This
    uge: extern(LLVMRealUGE) static This
    ult: extern(LLVMRealULT) static This
    ule: extern(LLVMRealULE) static This
    une: extern(LLVMRealUNE) static This
}
