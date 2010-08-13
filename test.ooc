use llvm
import llvm/[Core, ExecutionEngine, Target]
import structs/ArrayList

LLVMLinkInJIT: extern func

main: func {
    LLVMLinkInJIT()
    Target initializeNative()
    
    // Create an (empty) module.
    myModule := Module new("my_module")

    // Get the i32 type
    int_t := Type int32()

    // We need to represent the class of functions that accept three integers
    // and return an integer. This is represented by an object of the
    // function type
    func_t := Type function(int_t, [int_t, int_t, int_t] as ArrayList<Type>)

    // Now we need a function named 'sum' using this type. Functions are not
    // free-standing; thye need to be contained in a module.
    sum := myModule addFunction(func_t, "sum")

    // Let's name the function arguments 'a', 'b', and 'c'.
    sum args[0] setName("a")
    sum args[1] setName("b")
    sum args[2] setName("c")

    // Our function needs a "basic block" -- a set of instructions that
    // end with a terminator (like return, branch etc.). By convention
    // the first block is called "entry".
    bb := sum appendBasicBlock("entry")

    // Let's add instructions into the block. For this, we need an
    // instruction builder:
    builder := Builder new(bb)

    // OK, now for the instructions themselves. We'll create an add
    // instruction that returns the sum as a value, which we'll use
    // a ret instruction to return.
    tmp := builder add(sum args[0], sum args[1], "tmp")
    tmp2 := builder add(tmp, sum args[2], "tmp2")
    builder ret(tmp2)

    // We've completed the definition now! Let's see the LLVM assembly
    // language representation of what we've created:
    myModule dump()

    // Now, to try to run the function!
    provider := ModuleProvider new(myModule)
    engine := ExecutionEngine new(provider)

    arg1 := GenericValue new(int_t, 10 as ULLong, 0)
    arg2 := GenericValue new(int_t, 5  as ULLong, 0)
    arg3 := GenericValue new(int_t, 2  as ULLong, 0)

    result := engine runFunction(sum, 3, [arg1, arg2, arg3] as GenericValue*)
    result toInt(0) toString() println()
}
