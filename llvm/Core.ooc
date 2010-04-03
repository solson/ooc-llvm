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
//LLVMTypeRef LLVMStructTypeInContext(LLVMContextRef C, LLVMTypeRef *ElementTypes,
//                                    unsigned ElementCount, int Packed);
    structType: extern(LLVMStructType) static func (elementTypes: This*,
        elementCount: UInt, isPacked: Int) -> This
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
        thenBlock: BasicBlock, elseBlock: BasicBlock) -> Value
    switch: extern(LLVMBuildSwitch) func (val: Value, elseBlock: BasicBlock,
        numCases: UInt) -> Value
    invoke: extern(LLVMBuildInvoke) func (fn: Value, args: Value*,
        numArgs: UInt, thenBlock: BasicBlock, catchBlock: BasicBlock,
        name: String) -> Value
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
    malloc: extern(LLVMBuildMalloc) func (Type, name: String) -> Value
    alloca: extern(LLVMBuildAlloca) func (Type, name: String) -> Value
    arrayMalloc: extern(LLVMBuildArrayMalloc) func (Type, Value, name: String) -> Value
    arrayAlloca: extern(LLVMBuildArrayMalloc) func (Type, Value, name: String) -> Value
    free:  extern(LLVMBuildFree) func (pointer: Value) -> Value
    load:  extern(LLVMBuildLoad) func (pointer: Value, name: String) -> Value
    store: extern(LLVMBuildStore) func (val: Value, ptr: Value) -> Value
    gep: extern(LLVMBuildGEP) func (ptr: Value, indices: Value*,
        numIndicies: UInt, name: String) -> Value
    gep_inbounds: extern(LLVMBuildInBoundsGEP) func (ptr: Value,
        indices: Value*, numIndicies: UInt, name: String) -> Value
    gep_struct: extern(LLVMBuildStructGEP) func (ptr: Value, idx: UInt,
        name: String) -> Value
    globalString:    extern(LLVMBuildGlobalString) func (str: String, name: String) -> Value
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
//    icmp: extern(LLVMBuildICmp) func ()
}


LLVMGetFirstParam: extern func (Function) -> Value
LLVMGetNextParam: extern func (Value) -> Value

Attribute: cover from Int {
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

//typedef enum {
//  LLVMVoidTypeKind,        /**< type with no size */
//  LLVMFloatTypeKind,       /**< 32 bit floating point type */
//  LLVMDoubleTypeKind,      /**< 64 bit floating point type */
//  LLVMX86_FP80TypeKind,    /**< 80 bit floating point type (X87) */
//  LLVMFP128TypeKind,       /**< 128 bit floating point type (112-bit mantissa)*/
//  LLVMPPC_FP128TypeKind,   /**< 128 bit floating point type (two 64-bits) */
//  LLVMLabelTypeKind,       /**< Labels */
//  LLVMIntegerTypeKind,     /**< Arbitrary bit width integers */
//  LLVMFunctionTypeKind,    /**< Functions */
//  LLVMStructTypeKind,      /**< Structures */
//  LLVMArrayTypeKind,       /**< Arrays */
//  LLVMPointerTypeKind,     /**< Pointers */
//  LLVMOpaqueTypeKind,      /**< Opaque: type with unknown structure */
//  LLVMVectorTypeKind,      /**< SIMD 'packed' format, or other vector type */
//  LLVMMetadataTypeKind     /**< Metadata */
//} LLVMTypeKind;

//typedef enum {
//  LLVMExternalLinkage,    /**< Externally visible function */
//  LLVMAvailableExternallyLinkage,
//  LLVMLinkOnceAnyLinkage, /**< Keep one copy of function when linking (inline)*/
//  LLVMLinkOnceODRLinkage, /**< Same, but only replaced by something
//                            equivalent. */
//  LLVMWeakAnyLinkage,     /**< Keep one copy of function when linking (weak) */
//  LLVMWeakODRLinkage,     /**< Same, but only replaced by something
//                            equivalent. */
//  LLVMAppendingLinkage,   /**< Special purpose, only applies to global arrays */
//  LLVMInternalLinkage,    /**< Rename collisions when linking (static
//                               functions) */
//  LLVMPrivateLinkage,     /**< Like Internal, but omit from symbol table */
//  LLVMDLLImportLinkage,   /**< Function to be imported from DLL */
//  LLVMDLLExportLinkage,   /**< Function to be accessible from DLL */
//  LLVMExternalWeakLinkage,/**< ExternalWeak linkage description */
//  LLVMGhostLinkage,       /**< Stand-in functions for streaming fns from
//                               bitcode */
//  LLVMCommonLinkage,      /**< Tentative definitions */
//  LLVMLinkerPrivateLinkage /**< Like Private, but linker removes. */
//} LLVMLinkage;

//typedef enum {
//  LLVMDefaultVisibility,  /**< The GV is visible */
//  LLVMHiddenVisibility,   /**< The GV is hidden */
//  LLVMProtectedVisibility /**< The GV is protected */
//} LLVMVisibility;

//typedef enum {
//  LLVMCCallConv           = 0,
//  LLVMFastCallConv        = 8,
//  LLVMColdCallConv        = 9,
//  LLVMX86StdcallCallConv  = 64,
//  LLVMX86FastcallCallConv = 65
//} LLVMCallConv;

//typedef enum {
//  LLVMIntEQ = 32, /**< equal */
//  LLVMIntNE,      /**< not equal */
//  LLVMIntUGT,     /**< unsigned greater than */
//  LLVMIntUGE,     /**< unsigned greater or equal */
//  LLVMIntULT,     /**< unsigned less than */
//  LLVMIntULE,     /**< unsigned less or equal */
//  LLVMIntSGT,     /**< signed greater than */
//  LLVMIntSGE,     /**< signed greater or equal */
//  LLVMIntSLT,     /**< signed less than */
//  LLVMIntSLE      /**< signed less or equal */
//} LLVMIntPredicate;

//typedef enum {
//  LLVMRealPredicateFalse, /**< Always false (always folded) */
//  LLVMRealOEQ,            /**< True if ordered and equal */
//  LLVMRealOGT,            /**< True if ordered and greater than */
//  LLVMRealOGE,            /**< True if ordered and greater than or equal */
//  LLVMRealOLT,            /**< True if ordered and less than */
//  LLVMRealOLE,            /**< True if ordered and less than or equal */
//  LLVMRealONE,            /**< True if ordered and operands are unequal */
//  LLVMRealORD,            /**< True if ordered (no nans) */
//  LLVMRealUNO,            /**< True if unordered: isnan(X) | isnan(Y) */
//  LLVMRealUEQ,            /**< True if unordered or equal */
//  LLVMRealUGT,            /**< True if unordered or greater than */
//  LLVMRealUGE,            /**< True if unordered, greater than, or equal */
//  LLVMRealULT,            /**< True if unordered or less than */
//  LLVMRealULE,            /**< True if unordered, less than, or equal */
//  LLVMRealUNE,            /**< True if unordered or not equal */
//  LLVMRealPredicateTrue   /**< Always true (always folded) */
//} LLVMRealPredicate;
