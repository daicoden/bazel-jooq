import click

from copypastel_rules_datasource.db_tool import connect_mysql


@click.command()
@click.option('--host')
@click.option('--port')
@click.option('--username')
@click.option('--password')
@click.option('--dbname')
def drop_database(host, port, username, password, dbname):
    tools = connect_mysql(host, port, username, password)
    tools.drop_database(dbname)


if __name__ == "__main__":
    drop_database()
