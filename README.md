# Bazel Jooq [![Status](https://circleci.com/gh/daicoden/bazel-jooq.svg?style=shield)](https://circleci.com/gh/daicoden/bazel-jooq)

## Quickstart

```build
load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")
load("//:repositories.bzl", "gpk_rules_datasource_dependencies")
gpk_rules_datasource_dependencies(http_archive)



```


## Datasource


Should be renamed to rules_jooq... or something. Has 3 rule repositories.

rules_datasource
rules_flyway
rules_jooq
