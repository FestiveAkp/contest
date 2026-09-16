#!/usr/bin/env bash
set -e
cd "$(dirname "$0")/.."
odin test src -out:build/tests
