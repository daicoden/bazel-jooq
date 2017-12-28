
def sqldatabase_repositories(omit_mysql=False):
  if not omit_mysql:
    mysql_repository()


def mysql_repository():
  native.maven_jar(name="mysql_mysql_connector_java", artifact="mysql:mysql-connector-java:6.0.6")
