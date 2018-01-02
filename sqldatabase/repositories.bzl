
def sqldatabase_repositories(omit_mysql=False, omit_sqlite=False):
  if not omit_mysql:
    mysql_repository()
  if not omit_sqlite:
    sqlite_repository()


def mysql_repository():
  native.maven_jar(name="mysql_mysql_connector_java", artifact="mysql:mysql-connector-java:6.0.6")

def sqlite_repository():
  native.maven_jar(name="org_xerial_sqlite_jdbc", artifact="org.xerial:sqlite-jdbc:3.20.0")
