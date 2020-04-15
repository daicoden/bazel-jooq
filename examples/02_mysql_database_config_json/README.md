# Mysql Database With Yaml Config

In this example, a json file can be specified to generate databases rules.

```json
{
   "datasource_name": {
       "host": "localhost",
       "port": 3306,
       "username": "root",
       "password": ""
   }
}
```

```build
load("@gpk_rules_datasource/datasource:defs.bzl", "datasource_from_yaml")
# https://stackoverflow.com/questions/50368774/using-label-path-to-check-if-file-location-exists
datasource_from_yaml(name="json_database", config_location="//:BUILD", config_file="datasource.yml")
```

Results in a datasource configuration at `@json_database//:datasource_name`.

You can create a database by.

```build
load("@gpk_rules_datasource//datasource:defs.bzl", "database")
database("my_db", "@yaml_database//:datasource_name")
```

