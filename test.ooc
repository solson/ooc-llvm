// Import the llvm-ooc modules.
use llvm
import llvm/Core
import structs/ArrayList

main: func {
// Create an (empty) module.
my_module := LLVMModule new("my_module")

// All the types involved here are "int"s. This type is represented
// by an object of the llvm.core.Type class:
ty_int := LLVMType int32()   // by default 32 bits

// We need to represent the class of functions that accept two integers
// and return an integer. This is represented by an object of the
// function type (llvm.core.FunctionType):
ty_func := LLVMType function(ty_int, [ty_int, ty_int, ty_int] as ArrayList<LLVMType>)

// Now we need a function named 'sum' of this type. Functions are not
// free-standing (in llvm-py); it needs to be contained in a module.
f_sum := my_module addFunction(ty_func, "sum")

// Let's name the function arguments as 'a' and 'b'.
f_sum args()[0] setName("a")
f_sum args()[1] setName("b")
f_sum args()[2] setName("c")

// Our function needs a "basic block" -- a set of instructions that
// end with a terminator (like return, branch etc.). By convention
// the first block is called "entry".
bb := f_sum appendBasicBlock("entry")

// Let's add instructions into the block. For this, we need an
// instruction builder:
builder := LLVMBuilder new(bb)

// OK, now for the instructions themselves. We'll create an add
// instruction that returns the sum as a value, which we'll use
// a ret instruction to return.
tmp := builder add(f_sum args()[0], f_sum args()[1], "tmp")
tmp2 := builder add(tmp, f_sum args()[2], "tmp2")
builder ret(tmp2)

// We've completed the definition now! Let's see the LLVM assembly
// language representation of what we've created:
my_module dump()
}

