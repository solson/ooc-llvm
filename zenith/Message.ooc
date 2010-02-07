//import structs/ArrayList

//Message: class {
//    prev: This
//    next: This
//    name: String
//    arguments: ArrayList<This>


//}

zen_onMessage: unmangled func (name: String) {
    printf("Message\n")
    printf(name)
}

zen_parse: extern proto func

main: func {
    zen_parse()
}
