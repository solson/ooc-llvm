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
  int32: extern(LLVMInt32Type) static func -> This

  function: static func (returnType: This, paramTypes: ArrayList<This>) -> This {
    LLVMFunctionType(returnType, paramTypes toArray(), paramTypes size(), false)
  }
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


LLVMFunctionType: extern func (returnType: Type, paramTypes: Type*, paramCount: UInt, varArg: Int) -> Type
LLVMGetFirstParam: extern func (Function) -> Value
LLVMGetNextParam: extern func (Value) -> Value
