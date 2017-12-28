package(default_visibility = ["//visibility:public"])

java_binary(
    name = "create_mysql_database_bin",
    runtime_deps = [":create_mysql_database_lib"],
    main_class = "bazeljooq.sqldatabase.CreateMysqlDatabase",
)

java_library(
    name = "create_mysql_database_lib",
    srcs = ["bazeljooq/sqldatabase/CreateMysqlDatabase.java"],
    deps = ["@sqldatabase//:mysql_driver"],
 )
