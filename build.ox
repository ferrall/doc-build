#import "doc-build"

main() {
    decl opt = arglist();
    if (sizeof(opt)>1)
        document::build(opt[1],opt[2]);
    else
        document::build("","");
    }
