#!/usr/bin/env bash

# These lint tests need to be run manually to get access to bazel.

tools/bazel $* run --local_ram_resources=2048 --local_cpu_resources=2 //lint:buildifier

res=$?

if [ $res -ne 0 ]; then
  echo "Build files need formatting. Run \`bazel run buildifier\` to fix."
  exit $res
fi
