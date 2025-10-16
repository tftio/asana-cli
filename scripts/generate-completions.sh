#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
OUT_DIR="$ROOT_DIR/completions"

mkdir -p "$OUT_DIR"

cargo run --quiet -- completions bash > "$OUT_DIR/asana-cli.bash"
cargo run --quiet -- completions zsh > "$OUT_DIR/_asana-cli"
cargo run --quiet -- completions fish > "$OUT_DIR/asana-cli.fish"
cargo run --quiet -- completions powershell > "$OUT_DIR/asana-cli.ps1"

echo "Generated shell completions in $OUT_DIR"
