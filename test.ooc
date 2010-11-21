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
    i32 := Type int32()

    // Now we need a function named 'sum' using this type. Functions are not
    // free-standing; thye need to be contained in a module.
    // Let's name the function arguments 'a', 'b', and 'c'.
    sum := myModule addFunction("sum", i32,
        [i32, i32, i32],
        ["a", "b", "c"])

    // Our function needs a "basic block" -- a set of instructions that
    // end with a terminator (like return, branch etc.). By convention
    // the first block is called "entry". Instead of explicitly
    // creating an "entry" basic block and then getting an instruction
    // builderyou can just call builder() on a function:
    builder := sum builder()

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

    arg1 := GenericValue new(i32, 10 as ULLong, 0)
    arg2 := GenericValue new(i32, 5  as ULLong, 0)
    arg3 := GenericValue new(i32, 2  as ULLong, 0)

    result := engine runFunction(sum, 3, [arg1, arg2, arg3] as GenericValue*)
    result toInt(0) toString() println()
}
