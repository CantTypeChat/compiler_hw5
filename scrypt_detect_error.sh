#!/bin/bash

for file in src/*.c; do
    echo "Processing: $file"
    
    ./test < "$file" 2>&1 | while IFS= read -r line; do
        if [[ "$line" == *"syntax error"* ]]; then
            echo "$file: $line"
        fi
    done
done

