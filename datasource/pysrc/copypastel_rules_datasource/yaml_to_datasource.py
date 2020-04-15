import textwrap

import click
import yaml


@click.command()
@click.argument('yaml_contents')
def create_build_file(yaml_contents):
    datasources = yaml.load(yaml_contents)

    build_contents = '\nload("@gpk_rules_datasource//datasource:defs.bzl", "datasource_configuration")'

    for datasource in datasources:
        build_contents += textwrap.dedent("""
        
        datasource_configuration(
            name = "%s",
            host = "%s",
            port = %s,
            username = "%s",
            password = "%s",
        )""" % (datasource,
                datasources[datasource]["host"],
                datasources[datasource]["port"],
                datasources[datasource]["username"],
                datasources[datasource]["password"]))

    print(build_contents)


if __name__ == "__main__":
    create_build_file()
