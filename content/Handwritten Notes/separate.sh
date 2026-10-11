#!/bin/sh
set -eu

if [ "$#" -lt 1 ] || [ "$#" -gt 2 ]; then
    echo "Usage: $0 INPUT.pdf [OUTPUT_DIR]" >&2
    exit 2
fi

input=$1
outdir=${2:-./}
index=${2:-"$outdir/index.md"}

if [ ! -f "$input" ]; then
    echo "Error: input file not found: $input" >&2
    exit 1
fi

if ! command -v pdfseparate >/dev/null 2>&1; then
    echo "Error: pdfseparate is not available on this system." >&2
    exit 127
fi

mkdir -p "$outdir"
rm page-0* || echo "Nothing to remove"

# Refuse to overwrite matching output files.
for file in "$outdir"/page-*.pdf; do
    if [ -f "$file" ]; then
        echo "Error: $outdir already contains page-*.pdf files." >&2
        exit 1
    fi
done

pdfseparate "$input" "$outdir/page-%03d.pdf"
echo "Split pages into: $outdir"

rm "$index" || echo "Nothing to remove"

find ./ -maxdepth 1 -type f ! -path ./index.md | sort | sed 's#\./##g; s#^#- [[#; s#$#]]#' > "$index"

printf 'Wrote %s\n' "$index"