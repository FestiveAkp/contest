#!/usr/bin/env bash
set -e
cd "$(dirname "$0")/.."
find src -name '*.odin' -exec odinfmt -w {} \;
