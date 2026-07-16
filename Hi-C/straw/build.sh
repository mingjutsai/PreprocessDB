#!/usr/bin/env bash

set -euo pipefail

ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
BUILD_DIR=${BUILD_DIR:-$ROOT/build}
CXX=${CXX:-g++}

mkdir -p "$BUILD_DIR"

CURL_CFLAGS=()
if [ -n "${CURL_INCLUDE_DIR:-}" ]; then
    CURL_CFLAGS+=("-I$CURL_INCLUDE_DIR")
fi

"$CXX" -O3 -std=c++14 -pthread \
    "${CURL_CFLAGS[@]}" \
    -o "$BUILD_DIR/straw" \
    "$ROOT/main.cpp" "$ROOT/straw.cpp" \
    -lcurl -lz

echo "Built $BUILD_DIR/straw"
