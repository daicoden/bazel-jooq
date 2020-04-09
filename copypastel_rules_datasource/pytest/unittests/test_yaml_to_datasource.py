import textwrap

from click.testing import CliRunner

from copypastel_rules_datasource.yaml_to_datasource import create_build_file


def test_create_build_file(database_config):
    runner = CliRunner()
    result = runner.invoke(create_build_file, [database_config])

    assert result.exit_code == 0
    assert result.output == textwrap.dedent("""
    load("@copypastel_rules_datasource//:defs.bzl", "datasource_configuration")
        
    datasource_configuration(
        name = "datasource_name",
        host = "localhost",
        port = 3306,
        username = "root",
        password = "",
    )
    """)
