#!/bin/bash

# Check that every module in solar_router/ has corresponding English documentation
echo "Checking documentation coverage for solar_router modules..."
MISSING_DOCS=0

for yaml_file in solar_router/*.yaml; do
    # Extract base name without extension
    base_name=$(basename "$yaml_file" .yaml)
    # Check if corresponding .md file exists in docs/en/
    doc_file="docs/en/${base_name}.md"
    if [ ! -f "$doc_file" ]; then
        echo "❌ Missing documentation: $doc_file"
        MISSING_DOCS=$((MISSING_DOCS + 1))
    fi
done

if [ $MISSING_DOCS -gt 0 ]; then
    echo "❌ Found $MISSING_DOCS modules without English documentation"
    exit 1
else
    echo "✅ All modules have English documentation"
fi