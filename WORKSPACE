# Will eventually allow me to put workspaces in sqldatabase with proper name.
# Rules internal to sqldatabase should use @sqldatabase instead of //sqldatabase/
new_local_repository(name = "sqldatabase", path = "./sqldatabase", build_file="//sqldatabase:BUILD")
load("@sqldatabase//:defs.bzl", "sqldatabase_repositories")
sqldatabase_repositories()

# Will eventually allow me to put workspaces in flyway with proper name.
# Rules internal to flyway should use @flyway instead of //flyway/
new_local_repository(name = "flyway", path = "./flyway", build_file="//flyway:BUILD")
load("@flyway//:defs.bzl", "flyway_repositories")
flyway_repositories()

