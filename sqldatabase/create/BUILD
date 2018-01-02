package(default_visibility = ["//visibility:public"])

java_binary(
    name = "create_mysql_database_bin",
    runtime_deps = [":create_mysql_database_lib"],
    main_class = "bazeljooq.sqldatabase.CreateDatabase",
)

java_binary(
    name = "create_sqlite_database_bin",
    runtime_deps = [":create_sqlite_database_lib"],
    main_class = "bazeljooq.sqldatabase.CreateDatabase",
)


java_library(
    name = "create_mysql_database_lib",
    srcs = ["bazeljooq/sqldatabase/CreateDatabase.java"],
    deps = ["@sqldatabase//:mysql_driver"],
 )

java_library(
    name = "create_sqlite_database_lib",
    srcs = ["bazeljooq/sqldatabase/CreateDatabase.java"],
    deps = ["@sqldatabase//:sqlite_driver"],
 )
