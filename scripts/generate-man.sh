#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
OUT_DIR="$ROOT_DIR/man"

mkdir -p "$OUT_DIR"

cargo run --quiet -- manpage --dir "$OUT_DIR"

echo "Generated man page in $OUT_DIR"
