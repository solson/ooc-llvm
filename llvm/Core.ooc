use llvm
import structs/ArrayList

// Modules
Context: cover from LLVMContextRef {
    new: extern(LLVMContextCreate) static func -> This

    getGlobal: extern(LLVMGetGlobalContext) static func -> This

    dispose: extern(LLVMContextDispose) func

    // Types
    float_:     extern(LLVMFloatTypeInContext)   func -> Value
    double_:    extern(LLVMDoubleTypeInContext)  func -> Value
    xf86_fp80: extern(LLVMX86FP80TypeInContext)  func -> Value
    fp128:     extern(LLVMFP128TypeInContext)    func -> Value
    ppc_fp128: extern(LLVMPPCFP128TypeInContext) func -> Value

    struct_: extern(LLVMStructTypeInContext) func (elementTypes: Type*, elementCount: UInt, isPacked: Int) -> Value

    void_:   extern(LLVMVoidTypeInContext)  func -> Value
    label:  extern(LLVMLabelTypeInContext)  func -> Value
    opaque: extern(LLVMOpaqueTypeInContext) func -> Value
}

Module: cover from LLVMModuleRef {
    new: extern(LLVMModuleCreateWithName)          static func (String) -> This
    new: extern(LLVMModuleCreateWithNameInContext) static func ~inContext (String, Context) -> This

    dispose: extern(LLVMDisposeModule) func

    getDataLayout: extern(LLVMGetDataLayout) func -> String
    setDataLayout: extern(LLVMSetDataLayout) func (triple: String)

    getTarget: extern(LLVMGetTarget) func -> String
    setTarget: extern(LLVMSetTarget) func (triple: String)

    addTypeName:    extern(LLVMAddTypeName)    func (name: String, Type) -> Int
    deleteTypename: extern(LLVMDeleteTypeName) func (name: String)
    getTypeByName:  extern(LLVMGetTypeByName)  func (name: String) -> Type

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
    int_:  extern(LLVMIntType)   static func (numBits: UInt) -> This
    getIntTypeWidth: extern(LLVMGetIntTypeWidth) func -> UInt

    // Real types
    float_:    extern(LLVMFloatType)    static func -> This
    double_:   extern(LLVMDoubleType)   static func -> This
    x86_fp80:  extern(LLVMX86FP80Type)  static func -> This
    fp128:     extern(LLVMFP128Type)    static func -> This
    ppc_fp128: extern(LLVMPPCFP128Type) static func -> This

    // Function types
    function: extern(LLVMFunctionType) static func (returnType: Type,
        paramTypes: Type*, paramCount: UInt, varArg?: Int) -> Type

    function: static func ~withArrayList (returnType: This, paramTypes: ArrayList<This>) -> This {
        function(returnType, paramTypes toArray() as This*, paramTypes size(), false as Int)
    }

    isFunctionVarArg: extern(LLVMIsFunctionVarArg) func -> Int
    getReturnType:    extern(LLVMGetReturnType)    func -> This
    countParamTypes:  extern(LLVMCountParamTypes)  func -> UInt
    getParamTypes:    extern(LLVMGetParamTypes)    func (dest: This*)

    // Struct types
    structType: extern(LLVMStructType) static func (elementTypes: This*, elementCount: UInt, isPacked: Int) -> This
    countStructElementTypes: extern(LLVMCountStructElementTypes) func -> UInt
    getStructElementTypes:   extern(LLVMGetStructElementTypes)   func (dest: This*)
    isPackedStruct:          extern(LLVMIsPackedStruct)          func -> Int

    // Array, pointer, and vector rtpes (sequence types)
    array:   extern(LLVMArrayType)   static func (elementType: This, elementCount: UInt) -> This
    pointer: extern(LLVMPointerType) static func (elementType: This, addressSpace: UInt) -> This
    vector:  extern(LLVMVectorType)  static func (elementType: This, elementCount: UInt) -> This

    getElementType:         extern(LLVMGetElementType)         func -> This
    getArrayLength:         extern(LLVMGetArrayLength)         func -> UInt
    getPointerAddressSpace: extern(LLVMGetPointerAddressSpace) func -> UInt
    getVectorSize:          extern(LLVMGetVectorSize)          func -> UInt

    // Other types
    void_:  extern(LLVMVoidType)  static func -> This
    label:  extern(LLVMLabelType)  static func -> This
    opaque: extern(LLVMOpaqueType) static func -> This
}

Value: cover from LLVMValueRef {
    type:    extern(LLVMTypeOf)       func -> Type
    getName: extern(LLVMGetValueName) func -> String
    setName: extern(LLVMSetValueName) func (String)
    dump:    extern(LLVMDumpValue)    func
}

Function: cover from Value {
    new: extern(LLVMAddFunction) static func (module: Module, name: String, functionType: Type) -> This

    appendBasicBlock: extern(LLVMAppendBasicBlock) func (String) -> BasicBlock

    args: func -> ArrayList<Value> {
        argsList := ArrayList<Value> new()
        param := LLVMGetFirstParam(this)

        while(param != null) {
            argsList add(param)
            param = LLVMGetNextParam(param)
        }

        argsList
    }
}

BasicBlock: cover from LLVMBasicBlockRef

Builder: cover from LLVMBuilderRef {
    new: extern(LLVMCreateBuilder)          static func -> This
    new: extern(LLVMCreateBuilderInContext) static func ~inContext (Context) -> This

    new: static func ~atEnd (basicBlock: BasicBlock) -> This {
        builder := This new()
        builder positionAtEnd(basicBlock)
        builder
    }

    position:               extern(LLVMPositionBuilder)           func (BasicBlock, Value)
    positionBefore:         extern(LLVMPositionBuilderBefore)     func (Value)
    positionAtEnd:          extern(LLVMPositionBuilderAtEnd)      func (BasicBlock)
    getInsertBlock:         extern(LLVMGetInsertBlock)            func -> BasicBlock
    clearInsertionPosition: extern(LLVMClearInsertionPosition)    func
    insert:                 extern(LLVMInsertIntoBuilder)         func (Value)
    insert:                 extern(LLVMInsertIntoBuilderWithName) func ~withName (Value, String)

    dispose: extern(LLVMDisposeBuilder) func

    // Terminator instructions
    retVoid:      extern(LLVMBuildRetVoid)      func -> Value
    ret:          extern(LLVMBuildRet)          func (Value) -> Value
    aggregateRet: extern(LLVMBuildAggregateRet) func (Value*, UInt) -> Value
    br:           extern(LLVMBuildBr)           func (dest: BasicBlock) -> Value

    condBr: extern(LLVMBuildCondBr) func (condition: Value, thenBlock: BasicBlock, elseBlock: BasicBlock) -> Value
    switch: extern(LLVMBuildSwitch) func (val: Value, elseBlock: BasicBlock, numCases: UInt) -> Value
    invoke: extern(LLVMBuildInvoke) func (fn: Value, args: Value*, numArgs: UInt, thenBlock: BasicBlock, catchBlock: BasicBlock, name: String) -> Value

    unwind:      extern(LLVMBuildUnwind)      func -> Value
    unreachable: extern(LLVMBuildUnreachable) func -> Value

    // Add a case to the switch instruction
    addCase: extern(LLVMAddCase) static func (switchInstr: Value, onVal: Value, dest: BasicBlock)

    // Arithmetic instructions
    add:       extern(LLVMBuildAdd)       func (lhs, rhs: Value, name: String) -> Value
    addNSW:    extern(LLVMBuildNSWAdd)    func (lhs, rhs: Value, name: String) -> Value
    fadd:      extern(LLVMBuildFAdd)      func (lhs, rhs: Value, name: String) -> Value
    sub:       extern(LLVMBuildSub)       func (lhs, rhs: Value, name: String) -> Value
    fsub:      extern(LLVMBuildFSub)      func (lhs, rhs: Value, name: String) -> Value
    mul:       extern(LLVMBuildMul)       func (lhs, rhs: Value, name: String) -> Value
    fmul:      extern(LLVMBuildFMul)      func (lhs, rhs: Value, name: String) -> Value
    udiv:      extern(LLVMBuildUDiv)      func (lhs, rhs: Value, name: String) -> Value
    sdiv:      extern(LLVMBuildSDiv)      func (lhs, rhs: Value, name: String) -> Value
    sdivExact: extern(LLVMBuildExactSDiv) func (lhs, rhs: Value, name: String) -> Value
    fdiv:      extern(LLVMBuildFDiv)      func (lhs, rhs: Value, name: String) -> Value
    urem:      extern(LLVMBuildURem)      func (lhs, rhs: Value, name: String) -> Value
    srem:      extern(LLVMBuildSRem)      func (lhs, rhs: Value, name: String) -> Value
    frem:      extern(LLVMBuildFRem)      func (lhs, rhs: Value, name: String) -> Value
    shl:       extern(LLVMBuildShl)       func (lhs, rhs: Value, name: String) -> Value
    lshl:      extern(LLVMBuildLShr)      func (lhs, rhs: Value, name: String) -> Value
    ashr:      extern(LLVMBuildAShr)      func (lhs, rhs: Value, name: String) -> Value
    and:       extern(LLVMBuildAnd)       func (lhs, rhs: Value, name: String) -> Value
    or:        extern(LLVMBuildOr)        func (lhs, rhs: Value, name: String) -> Value
    xor:       extern(LLVMBuildXor)       func (lhs, rhs: Value, name: String) -> Value
    neg:       extern(LLVMBuildNeg)       func (val: Value, name: String) -> Value
    not:       extern(LLVMBuildNot)       func (val: Value, name: String) -> Value

    // Memory instructions
    malloc:      extern(LLVMBuildMalloc)      func (Type, name: String) -> Value
    alloca:      extern(LLVMBuildAlloca)      func (Type, name: String) -> Value
    arrayMalloc: extern(LLVMBuildArrayMalloc) func (Type, Value, name: String) -> Value
    arrayAlloca: extern(LLVMBuildArrayMalloc) func (Type, Value, name: String) -> Value

    free:  extern(LLVMBuildFree)  func (pointer: Value) -> Value
    load:  extern(LLVMBuildLoad)  func (pointer: Value, name: String) -> Value
    store: extern(LLVMBuildStore) func (val: Value, ptr: Value) -> Value

    gep:         extern(LLVMBuildGEP)         func (ptr: Value, indices: Value*, numIndicies: UInt, name: String) -> Value
    gepInbounds: extern(LLVMBuildInBoundsGEP) func (ptr: Value, indices: Value*, numIndicies: UInt, name: String) -> Value
    gepStruct:   extern(LLVMBuildStructGEP)   func (ptr: Value, idx: UInt, name: String) -> Value

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
    phi:            extern(LLVMBuildPhi)            func (Type, name: String) -> Value
    call:           extern(LLVMBuildCall)           func (fn: Value, args: Value*, numArgs: UInt, name: String) -> Value
    select:         extern(LLVMBuildSelect)         func (ifVal, thenVal, elseVal: Value, name: String) -> Value
    vaArg:          extern(LLVMBuildVAArg)          func (list: Value, Type, name: String) -> Value
    extractElement: extern(LLVMBuildExtractElement) func (vector, index: Value, name: String) -> Value
    insertElement:  extern(LLVMBuildInsertElement)  func (vector, val, index: Value, name: String) -> Value
    shuffleVector:  extern(LLVMBuildShuffleVector)  func (v1, v2, mask: Value, name: String) -> Value
    extractValue:   extern(LLVMBuildExtractValue)   func (agg: Value, index: UInt, name: String) -> Value
    insertValue:    extern(LLVMBuildInsertValue)    func (agg, val: Value, index: UInt, name: String) -> Value

    isNull:    extern(LLVMBuildIsNull)    func (val: Value, name: String) -> Value
    isNotNull: extern(LLVMBuildIsNotNull) func (val: Value, name: String) -> Value
    ptrDiff:   extern(LLVMBuildPtrDiff)   func (lhs, rhs: Value, name: String) -> Value
}


// Module providers
ModuleProvider: cover from LLVMModuleProviderRef {
    new: extern(LLVMCreateModuleProviderForExistingModule) static func (Module) -> This

    dispose: extern(LLVMDisposeModuleProvider) func
}

LLVMGetFirstParam: extern func (Function) -> Value
LLVMGetNextParam:  extern func (Value) -> Value

// Enums
Attribute: extern(LLVMAttribute) enum {
    zext:            extern(LLVMZExtAttribute)
    sext:            extern(LLVMSExtAttribute)
    noReturn:        extern(LLVMNoReturnAttribute)
    inReg:           extern(LLVMInRegAttribute)
    structRet:       extern(LLVMStructRetAttribute)
    noUnwind:        extern(LLVMNoUnwindAttribute)
    noAlias:         extern(LLVMNoAliasAttribute)
    byVal:           extern(LLVMByValAttribute)
    nest:            extern(LLVMNestAttribute)
    readNone:        extern(LLVMReadNoneAttribute)
    readOnly:        extern(LLVMReadOnlyAttribute)
    noInline:        extern(LLVMNoInlineAttribute)
    alwaysInline:    extern(LLVMAlwaysInlineAttribute)
    optimizeForSize: extern(LLVMOptimizeForSizeAttribute)
    stackProtect:    extern(LLVMStackProtectAttribute)
    stackProtectReq: extern(LLVMStackProtectReqAttribute)
    noCapture:       extern(LLVMNoCaptureAttribute)
    noRedZone:       extern(LLVMNoRedZoneAttribute)
    noImplicitFloat: extern(LLVMNoImplicitFloatAttribute)
    naked:           extern(LLVMNakedAttribute)
}

TypeKind: extern(LLVMTypeKind) enum {
    void_:      extern(LLVMVoidTypeKind)
    float_:     extern(LLVMFloatTypeKind)
    double_:    extern(LLVMDoubleTypeKind)
    x86_fp80:  extern(LLVMX86_FP80TypeKind)
    fp128:     extern(LLVMFP128TypeKind)
    ppc_fp128: extern(LLVMPPC_FP128TypeKind)
    label:     extern(LLVMLabelTypeKind)
    integer:   extern(LLVMIntegerTypeKind)
    function:  extern(LLVMFunctionTypeKind)
    struct_:    extern(LLVMStructTypeKind)
    array:     extern(LLVMArrayTypeKind)
    pointer:   extern(LLVMPointerTypeKind)
    opaque:    extern(LLVMOpaqueTypeKind)
    vector:    extern(LLVMVectorTypeKind)
    metadata:  extern(LLVMMetadataTypeKind)
}

Linkage: extern(LLVMLinkage) enum {
    external:            extern(LLVMExternalLinkage)
    availableExternally: extern(LLVMAvailableExternallyLinkage)
    linkOnceAny:         extern(LLVMLinkOnceAnyLinkage)
    linkOnceODR:         extern(LLVMLinkOnceODRLinkage)
    weakAny:             extern(LLVMWeakAnyLinkage)
    weakODR:             extern(LLVMWeakODRLinkage)
    appending:           extern(LLVMAppendingLinkage)
    internal:            extern(LLVMInternalLinkage)
    private:             extern(LLVMPrivateLinkage)
    dllImport:           extern(LLVMDLLImportLinkage)
    dllExport:           extern(LLVMDLLExportLinkage)
    externalWeak:        extern(LLVMExternalWeakLinkage)
    ghost:               extern(LLVMGhostLinkage)
    common:              extern(LLVMCommonLinkage)
    linkerPrivate:       extern(LLVMLinkerPrivateLinkage)
}

Visibility: extern(LLVMVisibility) enum {
    default:   extern(LLVMDefaultVisibility)
    hidden:    extern(LLVMHiddenVisibility)
    protected: extern(LLVMProtectedVisibility)
}

CallConv: extern(LLVMCallConv) enum {
    ccall:       extern(LLVMCCallConv)
    fast:        extern(LLVMFastCallConv)
    cold:        extern(LLVMColdCallConv)
    x86stdcall:  extern(LLVMX86StdcallCallConv)
    x86fastcall: extern(LLVMX86FastcallCallConv)
}

IntPredicate: extern(LLVMIntPredicate) enum {
    eq:  extern(LLVMIntEQ)
    ne:  extern(LLVMIntNE)
    ugt: extern(LLVMIntUGT)
    uge: extern(LLVMIntUGE)
    ult: extern(LLVMIntULT)
    ule: extern(LLVMIntULE)
    sgt: extern(LLVMIntSGT)
    sge: extern(LLVMIntSGE)
    slt: extern(LLVMIntSLT)
    sle: extern(LLVMIntSLE)
}

RealPredicate: extern(LLVMRealPredicate) enum {
    truePred:  extern(LLVMRealPredicateTrue)
    falsePred: extern(LLVMRealPredicateFalse)
    oeq:       extern(LLVMRealOEQ)
    ogt:       extern(LLVMRealOGT)
    oge:       extern(LLVMRealOGE)
    olt:       extern(LLVMRealOLT)
    ole:       extern(LLVMRealOLE)
    one:       extern(LLVMRealONE)
    ord:       extern(LLVMRealORD)
    uno:       extern(LLVMRealUNO)
    ueq:       extern(LLVMRealUEQ)
    ugt:       extern(LLVMRealUGT)
    uge:       extern(LLVMRealUGE)
    ult:       extern(LLVMRealULT)
    ule:       extern(LLVMRealULE)
    une:       extern(LLVMRealUNE)
}
