#!/usr/bin/env bash
set -e
mkdir -p build
odin build src -out:build/contest -debug
