
# Helpers for compiling.
https://blog.bazel.build/2017/03/07/java-sandwich.html
https://docs.bazel.build/versions/2.0.0/skylark/lib/java_common.html

# Does pretty much what I want from jooq's perspective

Ok so not exactly what I want, but you can make the File a directory, and I think that will work for jooq.
https://stackoverflow.com/questions/59804073/how-do-i-generate-declared-files-and-directories-using-java-common-compile-annot


Actually - try declaring directory, setting the jooq target directory as such, return that directory as the output, then use straight java_libarry rule to create the jar... maybe?
