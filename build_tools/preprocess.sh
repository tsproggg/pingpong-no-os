#!/bin/bash

PARTS_DIR="./src/kernel_parts"
OUTPUT="./src/kernel.asm"
MAIN="start.asm"

# Clear previous output
echo -n "" > "$OUTPUT"

# Ensure main file exists
if [ ! -f "$PARTS_DIR/$MAIN" ]; then
    echo "Error: $PARTS_DIR/$MAIN not found."
    exit 1
fi

echo "; ===== BEGIN: $MAIN =====" >> "$OUTPUT"
cat "$PARTS_DIR/$MAIN" >> "$OUTPUT"
echo "" >> "$OUTPUT"

# Append all other .asm files except start.asm
for f in $(ls "$PARTS_DIR"/*.asm | sort); do
    base=$(basename "$f")
    if [ "$base" != "$MAIN" ]; then
        cat "$f" >> "$OUTPUT"
        echo "" >> "$OUTPUT"
    fi
done

echo "Created $OUTPUT"
