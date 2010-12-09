use llvm
import structs/ArrayList

// Modules
Context: cover from LLVMContextRef {
    new: extern(LLVMContextCreate) static func -> This

    getGlobal: extern(LLVMGetGlobalContext) static func -> This

    dispose: extern(LLVMContextDispose) func

    // Types
    float_:    extern(LLVMFloatTypeInContext)   func -> Value
    double_:   extern(LLVMDoubleTypeInContext)  func -> Value
    xf86_fp80: extern(LLVMX86FP80TypeInContext)  func -> Value
    fp128:     extern(LLVMFP128TypeInContext)    func -> Value
    ppc_fp128: extern(LLVMPPCFP128TypeInContext) func -> Value

    struct_: extern(LLVMStructTypeInContext) func (elementTypes: Type*, elementCount: UInt, isPacked: Int) -> Value

    void_:  extern(LLVMVoidTypeInContext)  func -> Value
    label:  extern(LLVMLabelTypeInContext)  func -> Value
    opaque: extern(LLVMOpaqueTypeInContext) func -> Value
}

Module: cover from LLVMModuleRef {
    new: extern(LLVMModuleCreateWithName)          static func (CString) -> This
    new: extern(LLVMModuleCreateWithNameInContext) static func ~inContext (CString, Context) -> This

    dispose: extern(LLVMDisposeModule) func

    getDataLayout: extern(LLVMGetDataLayout) func -> CString
    setDataLayout: extern(LLVMSetDataLayout) func (triple: CString)

    getTarget: extern(LLVMGetTarget) func -> CString
    setTarget: extern(LLVMSetTarget) func (triple: CString)

    addTypeName:    extern(LLVMAddTypeName)    func (name: CString, Type)
    deleteTypeName: extern(LLVMDeleteTypeName) func (name: CString)
    getTypeByName:  extern(LLVMGetTypeByName)  func (name: CString) -> Type

    dump: extern(LLVMDumpModule) func

    addFunction: func (name: String, functionType: Type) -> Function {
        Function new(this, name, functionType)
    }

    addFunction: func ~withRetAndArgs (name: String, ret: Type, arguments: Type[]) -> Function {
        Function new(this, name, Type function(ret, arguments))
    }

    addFunction: func ~withRetAndArgsWithName (name: String, ret: Type,
             arguments: Type[], argNames: String[]) -> Function {
        fn := Function new(this, name, Type function(ret, arguments))
        fnArgs := fn args
        for(i in 0..argNames length) {
            fnArgs[i] setName(argNames[i])
        }
        fn
    }

    writeBitcode: extern(LLVMWriteBitcodeToFile)       func ~toFile (path: CString) -> Int
    writeBitcode: extern(LLVMWriteBitcodeToFD)         func ~toFD (fd, shouldClose, unbuffered: Int) -> Int
    writeBitcode: extern(LLVMWriteBitcodeToFileHandle) func ~toFileHandle (handle: Int) -> Int
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
    function: extern(LLVMFunctionType) static func (returnType: This,
        paramTypes: This*, paramCount: UInt, varArg?: Int) -> This

    function: static func ~withArray (returnType: This, paramTypes: This[], varArg? := false) -> This {
        function(returnType, paramTypes data, paramTypes length, varArg? as Int)
    }

    function: static func ~withArrayList (returnType: This, paramTypes: ArrayList<This>, varArg? := false) -> This {
        function(returnType, paramTypes toArray() as This*, paramTypes size as UInt, varArg? as Int)
    }

    isFunctionVarArg: extern(LLVMIsFunctionVarArg) func -> Int
    getReturnType:    extern(LLVMGetReturnType)    func -> This
    countParamTypes:  extern(LLVMCountParamTypes)  func -> UInt
    getParamTypes:    extern(LLVMGetParamTypes)    func (dest: This*)

    // Struct types
    struct_: extern(LLVMStructType) static func (elementTypes: This*, elementCount: UInt, packed?: Int) -> This
    struct_: static func ~withArray (elementTypes: This[], packed?: Bool) -> This {
        struct_(elementTypes data, elementTypes length, packed? as Int)
    }
    struct_: static func ~withArrayUnpacked (elementTypes: This[]) -> This {
        struct_(elementTypes, false)
    }
    countStructElementTypes: extern(LLVMCountStructElementTypes) func -> UInt
    getStructElementTypes:   extern(LLVMGetStructElementTypes)   func (dest: This*)
    isPackedStruct:          extern(LLVMIsPackedStruct)          func -> Int

    // Array, pointer, and vector types (sequence types)
    array:   extern(LLVMArrayType)   static func (elementType: This, elementCount: UInt) -> This
    pointer: extern(LLVMPointerType) static func (elementType: This, addressSpace: UInt) -> This
    pointer: static func ~withoutAddressSpace (elementType: This) -> This {
        pointer(elementType, 0)
    }
    vector:  extern(LLVMVectorType)  static func (elementType: This, elementCount: UInt) -> This

    getElementType:         extern(LLVMGetElementType)         func -> This
    getArrayLength:         extern(LLVMGetArrayLength)         func -> UInt
    getPointerAddressSpace: extern(LLVMGetPointerAddressSpace) func -> UInt
    getVectorSize:          extern(LLVMGetVectorSize)          func -> UInt

    // Other types
    void_:  extern(LLVMVoidType)   static func -> This
    label:  extern(LLVMLabelType)  static func -> This
    opaque: extern(LLVMOpaqueType) static func -> This

    // Constants
    constNull:        extern(LLVMConstNull)        func -> Value
    constAllOnes:     extern(LLVMConstAllOnes)     func -> Value
    getUndef:         extern(LLVMGetUndef)         func -> Value
//    constant?:        extern(LLVMIsConstant)       func -> Bool
//    null?:            extern(LLVMIsNull)           func -> Bool
//    undef?:           extern(LLVMIsUndef)          func -> Bool
    constPointerNull: extern(LLVMConstPointerNull) func -> Value

    // Scalar constants
    
}

Value: cover from LLVMValueRef {
    type:    extern(LLVMTypeOf)       func -> Type
    getName: extern(LLVMGetValueName) func -> CString
    setName: extern(LLVMSetValueName) func (CString)
    dump:    extern(LLVMDumpValue)    func

    constPointerNull: extern(LLVMConstPointerNull) static func (Type) -> This
    constInt: extern(LLVMConstInt) static func (Type, ULLong, Bool) -> This
    constInt: static func ~signed (ty: Type, val: ULLong) -> This {
        constInt(ty, val, true)
    }
    constInt: extern(LLVMConstIntOfStringAndSize) static func ~cstring (Type, CString, UInt, UInt8) -> This
    constInt: static func ~string (ty: Type, str: String, radix: UInt8) -> This {
        constInt(ty, str toCString(), str size, radix)
    }
    constReal: extern(LLVMConstReal) static func (Type, Double) -> This
    constReal: extern(LLVMConstRealOfStringAndSize) static func ~cstring (Type, CString, UInt) -> This
    constReal: static func ~string (ty: Type, str: String) -> This {
        constReal(ty, str toCString(), str size)
    }
    constString: extern(LLVMConstString) static func (CString, UInt, Bool) -> This
    constString: static func ~string (str: String, dontNullTerminate? := false) -> This {
        constString(str toCString(), str size, dontNullTerminate?)
    }
    constArray: extern(LLVMConstArray) static func (Type, Value*, UInt) -> This
    constArray: static func ~withArray (elemTy: Type, constVals: Value[]) -> This {
        constArray(elemTy, constVals data, constVals length)
    }
    constStruct: extern(LLVMConstStruct) static func (Value*, UInt, Bool) -> This
    constStruct: static func ~withArray (constVals: Value[], packed? := false) -> This {
        constStruct(constVals data, constVals length, packed?)
    }
    constVector: extern(LLVMConstVector) static func (Value*, UInt) -> This
    constVector: static func ~withArray (scalarConstVals: Value[]) -> This {
        constVector(scalarConstVals data, scalarConstVals length)
    }
}

LLVMGetFirstParam: extern func (Function) -> Value
LLVMGetNextParam:  extern func (Value) -> Value

Function: cover from Value {
    new: extern(LLVMAddFunction) static func (module: Module, name: CString, functionType: Type) -> This

    appendBasicBlock: extern(LLVMAppendBasicBlock) func (CString) -> BasicBlock

    builder: func -> Builder {
        appendBasicBlock("entry") builder()
    }

    build: func (fn: Func (Builder, ArrayList<Value>)) {
        fn(builder(), args)
    }

    args: ArrayList<Value> {
        get {
            argsList := ArrayList<Value> new()
            param := LLVMGetFirstParam(this)

            while(param != null) {
                argsList add(param)
                param = LLVMGetNextParam(param)
            }

            argsList
        }
    }
}

BasicBlock: cover from LLVMBasicBlockRef {
    builder: func -> Builder {
        Builder new(this)
    }
}

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
    insert:                 extern(LLVMInsertIntoBuilderWithName) func ~withName (Value, CString)

    dispose: extern(LLVMDisposeBuilder) func

    // Terminator instructions
    ret: extern(LLVMBuildRetVoid)      func ~void -> Value
    ret: extern(LLVMBuildRet)          func (Value) -> Value
    ret: extern(LLVMBuildAggregateRet) func ~aggregate (Value*, UInt) -> Value
    
    br: extern(LLVMBuildBr)     func (dest: BasicBlock) -> Value
    br: extern(LLVMBuildCondBr) func ~cond (cond: Value, iftrue: BasicBlock, iffalse: BasicBlock) -> Value
    
    switch: extern(LLVMBuildSwitch) func (val: Value, elseBlock: BasicBlock, numCases: UInt) -> Value
    invoke: extern(LLVMBuildInvoke) func (fn: Value, args: Value*, numArgs: UInt, thenBlock: BasicBlock, catchBlock: BasicBlock, name: CString) -> Value

    unwind:      extern(LLVMBuildUnwind)      func -> Value
    unreachable: extern(LLVMBuildUnreachable) func -> Value

    // Add a case to the switch instruction
    addCase: extern(LLVMAddCase) static func (switchInstr: Value, onVal: Value, dest: BasicBlock)

    // Arithmetic instructions
    add:       extern(LLVMBuildAdd)       func (lhs, rhs: Value, name: CString) -> Value
    addNSW:    extern(LLVMBuildNSWAdd)    func (lhs, rhs: Value, name: CString) -> Value
    fadd:      extern(LLVMBuildFAdd)      func (lhs, rhs: Value, name: CString) -> Value
    sub:       extern(LLVMBuildSub)       func (lhs, rhs: Value, name: CString) -> Value
    fsub:      extern(LLVMBuildFSub)      func (lhs, rhs: Value, name: CString) -> Value
    mul:       extern(LLVMBuildMul)       func (lhs, rhs: Value, name: CString) -> Value
    fmul:      extern(LLVMBuildFMul)      func (lhs, rhs: Value, name: CString) -> Value
    udiv:      extern(LLVMBuildUDiv)      func (lhs, rhs: Value, name: CString) -> Value
    sdiv:      extern(LLVMBuildSDiv)      func (lhs, rhs: Value, name: CString) -> Value
    sdivExact: extern(LLVMBuildExactSDiv) func (lhs, rhs: Value, name: CString) -> Value
    fdiv:      extern(LLVMBuildFDiv)      func (lhs, rhs: Value, name: CString) -> Value
    urem:      extern(LLVMBuildURem)      func (lhs, rhs: Value, name: CString) -> Value
    srem:      extern(LLVMBuildSRem)      func (lhs, rhs: Value, name: CString) -> Value
    frem:      extern(LLVMBuildFRem)      func (lhs, rhs: Value, name: CString) -> Value
    shl:       extern(LLVMBuildShl)       func (lhs, rhs: Value, name: CString) -> Value
    lshr:      extern(LLVMBuildLShr)      func (lhs, rhs: Value, name: CString) -> Value
    ashr:      extern(LLVMBuildAShr)      func (lhs, rhs: Value, name: CString) -> Value
    and:       extern(LLVMBuildAnd)       func (lhs, rhs: Value, name: CString) -> Value
    or:        extern(LLVMBuildOr)        func (lhs, rhs: Value, name: CString) -> Value
    xor:       extern(LLVMBuildXor)       func (lhs, rhs: Value, name: CString) -> Value
    neg:       extern(LLVMBuildNeg)       func (val: Value, name: CString) -> Value
    not:       extern(LLVMBuildNot)       func (val: Value, name: CString) -> Value

    // Memory instructions
    malloc:      extern(LLVMBuildMalloc)      func (Type, CString) -> Value
    alloca:      extern(LLVMBuildAlloca)      func (Type, CString) -> Value
    arrayMalloc: extern(LLVMBuildArrayMalloc) func (Type, Value, CString) -> Value
    arrayAlloca: extern(LLVMBuildArrayMalloc) func (Type, Value, CString) -> Value

    free:  extern(LLVMBuildFree)  func (pointer: Value) -> Value
    load:  extern(LLVMBuildLoad)  func (pointer: Value, name: CString) -> Value
    store: extern(LLVMBuildStore) func (val: Value, ptr: Value) -> Value

    gep:         extern(LLVMBuildGEP)         func (ptr: Value, indices: Value*, numIndicies: UInt, name: CString) -> Value
    gepInbounds: extern(LLVMBuildInBoundsGEP) func (ptr: Value, indices: Value*, numIndicies: UInt, name: CString) -> Value
    gepStruct:   extern(LLVMBuildStructGEP)   func (ptr: Value, idx: UInt, name: CString) -> Value

    globalString:    extern(LLVMBuildGlobalString)    func (str: CString, name: CString) -> Value
    globalStringPtr: extern(LLVMBuildGlobalStringPtr) func (str: CString, name: CString) -> Value

    // Cast instructions
    trunc:          extern(LLVMBuildTrunc)          func (Value, Type, CString) -> Value
    zext:           extern(LLVMBuildZExt)           func (Value, Type, CString) -> Value
    sext:           extern(LLVMBuildSExt)           func (Value, Type, CString) -> Value
    fptoui:         extern(LLVMBuildFPToUI)         func (Value, Type, CString) -> Value
    fptosi:         extern(LLVMBuildFPToSI)         func (Value, Type, CString) -> Value
    uitofp:         extern(LLVMBuildUIToFP)         func (Value, Type, CString) -> Value
    sitofp:         extern(LLVMBuildSIToFP)         func (Value, Type, CString) -> Value
    fptrunc:        extern(LLVMBuildFPTrunc)        func (Value, Type, CString) -> Value
    fpext:          extern(LLVMBuildFPExt)          func (Value, Type, CString) -> Value
    ptrtoint:       extern(LLVMBuildPtrToInt)       func (Value, Type, CString) -> Value
    inttoptr:       extern(LLVMBuildIntToPtr)       func (Value, Type, CString) -> Value
    bitcast:        extern(LLVMBuildBitCast)        func (Value, Type, CString) -> Value
    zextOrBitcast:  extern(LLVMBuildZExtOrBitCast)  func (Value, Type, CString) -> Value
    sextOrBitcast:  extern(LLVMBuildSExtOrBitCast)  func (Value, Type, CString) -> Value
    truncOrBitcast: extern(LLVMBuildTruncOrBitCast) func (Value, Type, CString) -> Value
    pointerCast:    extern(LLVMBuildPointerCast)    func (Value, Type, CString) -> Value
    intCast:        extern(LLVMBuildIntCast)        func (Value, Type, CString) -> Value
    fpCast:         extern(LLVMBuildFPCast)         func (Value, Type, CString) -> Value

    // Comparison instructions
    icmp: extern(LLVMBuildICmp) func (IntPredicate,  lhs, rhs: Value, name: CString) -> Value
    fcmp: extern(LLVMBuildICmp) func (RealPredicate, lhs, rhs: Value, name: CString) -> Value

    // Miscellaneous instructions
    phi:            extern(LLVMBuildPhi)            func (Type, name: CString) -> Value
    call:           extern(LLVMBuildCall)           func (fn: Function, args: Value*, numArgs: UInt, name: CString) -> Value
    call: func ~withArray (fn: Function, args: Value[], name := "") -> Value {
        call(fn, args data, args length, name)
    }
    call: func ~withArrayList (fn: Function, args: ArrayList<Value>, name := "") -> Value {
        call(fn, args toArray() as Value*, args size as UInt, name)
    }
    select:         extern(LLVMBuildSelect)         func (ifVal, thenVal, elseVal: Value, name: CString) -> Value
    vaArg:          extern(LLVMBuildVAArg)          func (list: Value, Type, name: CString) -> Value
    extractElement: extern(LLVMBuildExtractElement) func (vector, index: Value, name: CString) -> Value
    insertElement:  extern(LLVMBuildInsertElement)  func (vector, val, index: Value, name: CString) -> Value
    shuffleVector:  extern(LLVMBuildShuffleVector)  func (v1, v2, mask: Value, name: CString) -> Value
    extractValue:   extern(LLVMBuildExtractValue)   func (agg: Value, index: UInt, name: CString) -> Value
    insertValue:    extern(LLVMBuildInsertValue)    func (agg, val: Value, index: UInt, name: CString) -> Value

    isNull:    extern(LLVMBuildIsNull)    func (val: Value, name: CString) -> Value
    isNotNull: extern(LLVMBuildIsNotNull) func (val: Value, name: CString) -> Value
    ptrDiff:   extern(LLVMBuildPtrDiff)   func (lhs, rhs: Value, name: CString) -> Value
}


// Module providers
ModuleProvider: cover from LLVMModuleProviderRef {
    new: extern(LLVMCreateModuleProviderForExistingModule) static func (Module) -> This

    dispose: extern(LLVMDisposeModuleProvider) func
}

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
    void_:     extern(LLVMVoidTypeKind)
    float_:    extern(LLVMFloatTypeKind)
    double_:   extern(LLVMDoubleTypeKind)
    x86_fp80:  extern(LLVMX86_FP80TypeKind)
    fp128:     extern(LLVMFP128TypeKind)
    ppc_fp128: extern(LLVMPPC_FP128TypeKind)
    label:     extern(LLVMLabelTypeKind)
    integer:   extern(LLVMIntegerTypeKind)
    function:  extern(LLVMFunctionTypeKind)
    struct_:   extern(LLVMStructTypeKind)
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
