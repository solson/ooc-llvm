use llvm

import structs/ArrayList

LLVMModule: cover from LLVMModuleRef {
  new: extern(LLVMModuleCreateWithName) static func (String) -> This

  addFunction: func (functionType: LLVMType, name: String) -> LLVMFunction {
    LLVMFunction new(this, name, functionType)
  }

  dump: extern(LLVMDumpModule) func
}

LLVMType: cover from LLVMTypeRef {
  int32: extern(LLVMInt32Type) static func -> This

  function: static func (returnType: This, paramTypes: ArrayList<This>) -> This {
    LLVMFunctionType(returnType, paramTypes toArray(), paramTypes size(), false)
  }
}

LLVMValue: cover from LLVMValueRef {
  name: extern(LLVMGetValueName) func -> String
  setName: extern(LLVMSetValueName) func (String)
}

LLVMFunction: cover from LLVMValueRef extends LLVMValue {
  new: extern(LLVMAddFunction) static func (module: LLVMModule, name: String, functionType: LLVMType) -> This

  appendBasicBlock: extern(LLVMAppendBasicBlock) func (String) -> LLVMBasicBlock

  args: func -> ArrayList<LLVMValue> {
    argsList := ArrayList<LLVMValue> new()
    param := LLVMGetFirstParam(this)

    while (param) {
      argsList add(param)
      param = LLVMGetNextParam(param)
    }

    return argsList
  }
}

LLVMBasicBlock: cover from LLVMBasicBlockRef

LLVMBuilder: cover from LLVMBuilderRef {
  new: extern(LLVMCreateBuilder) static func -> This

  new: static func ~atEnd (basicBlock: LLVMBasicBlock) -> This {
    builder := This new()
    builder positionAtEnd(basicBlock)
    return builder
  }

  positionAtEnd: extern(LLVMPositionBuilderAtEnd) func (LLVMBasicBlock)

  // terminator instructions
  ret: extern(LLVMBuildRet) func (LLVMValue)

  // arithmethic, bitwise and logical
  add: extern(LLVMBuildAdd) func (lhs, rhs: LLVMValue, name: String) -> LLVMValue
}

LLVMFunctionType: extern func (returnType: LLVMType, paramTypes: LLVMType*, paramCount: UInt, varArg: Int) -> LLVMType

LLVMGetFirstParam: extern func (fn: LLVMFunction) -> LLVMValue
LLVMGetNextParam: extern func (arg: LLVMValue) -> LLVMValue

