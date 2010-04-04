use llvm
import llvm/Core
import structs/ArrayList

main: func {
    // Create an (empty) module.
    my_module := Module new("my_module")

    // Get the i32 type
    int_t := Type int32()

    // We need to represent the class of functions that accept three integers
    // and return an integer. This is represented by an object of the
    // function type
    func_t := Type function(int_t, [int_t, int_t, int_t] as ArrayList<Type>)

    // Now we need a function named 'sum' using this type. Functions are not
    // free-standing; thye need to be contained in a module.
    sum := my_module addFunction(func_t, "sum")

    // Let's name the function arguments 'a', 'b', and 'c'.
    sum args()[0] setName("a")
    sum args()[1] setName("b")
    sum args()[2] setName("c")

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
    tmp := builder add(sum args()[0], sum args()[1], "tmp")
    tmp2 := builder add(tmp, sum args()[2], "tmp2")
    builder ret(tmp2)

    // We've completed the definition now! Let's see the LLVM assembly
    // language representation of what we've created:
    my_module dump()

    // A simple test for the enum covers. Currently broken in rock.
    foo := Attribute naked
    if(foo == Attribute noReturn) { "Wtf?" println() } else { "Yep." println() }
    if(foo == Attribute naked) { "Yep." println() } else { "Wtf?" println() }
}
