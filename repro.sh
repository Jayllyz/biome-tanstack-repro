#!/usr/bin/env bash
# Counts how many times Biome's scanner opens each node_modules type file during one lint run.
set -eu
cd "$(dirname "$0")"
rm -f tracing.json
./node_modules/.bin/biome lint --log-level=tracing --log-kind=json --log-file=tracing.json . >/dev/null 2>&1 || true

opens() { jq -r 'select(.span.name=="open_file_internal") | .span.path' tracing.json | grep node_modules; }

echo "Total node_modules opens: $(opens | wc -l | tr -d ' ')"
echo "Unique node_modules files: $(opens | sort -u | wc -l | tr -d ' ')"
echo
echo "Most-opened files:"
opens | sed 's#.*/node_modules/.pnpm/##' | sort | uniq -c | sort -rn | head -10
