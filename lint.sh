#!/usr/bin/env bash

# These lint tests need to be run manually to get access to bazel.

bazel $* run //lint:buildifier

res=$?

if [ $res -ne 0 ]; then
  echo "Build files need formatting. Run \`bazel run buildifier\` to fix."
  exit $res
fi
