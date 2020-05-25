
# Helpers for compiling.
https://blog.bazel.build/2017/03/07/java-sandwich.html
https://docs.bazel.build/versions/2.0.0/skylark/lib/java_common.html

# Does pretty much what I want from jooq's perspective

Ok so not exactly what I want, but you can make the File a directory, and I think that will work for jooq.
https://stackoverflow.com/questions/59804073/how-do-i-generate-declared-files-and-directories-using-java-common-compile-annot


Actually - try declaring directory, setting the jooq target directory as such, return that directory as the output, then use straight java_libarry rule to create the jar... maybe?


from bazel java_library

List of labels; optional

The list of source files that are processed to create the target. This attribute is almost always required; see exceptions below.
Source files of type .java are compiled. In case of generated .java files it is generally advisable to put the generating rule's name here instead of the name of the file itself. This not only improves readability but makes the rule more resilient to future changes: if the generating rule generates different files in the future, you only need to fix one place: the outs of the generating rule. You should not list the generating rule in deps because it is a no-op.

Source files of type .srcjar are unpacked and compiled. (This is useful if you need to generate a set of .java files with a genrule.)

Rules: if the rule (typically genrule or filegroup) generates any of the files listed above, they will be used the same way as described for source files.

This argument is almost always required, except if a main_class attribute specifies a class on the runtime classpath or you specify the runtime_deps argument.
