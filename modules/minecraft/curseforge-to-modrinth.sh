#!/usr/bin/env bash

modsFolder="$1"

for file in "$modsFolder"/*.jar; do
    mod="$(basename "$file")"
    name="$(echo "$mod" | sed -nr 's/(\w+).*/\1/p')"
    version="$(echo "$mod" | sed -nr 's/.*-(.*)\.jar/\1/p')"  # Removed extra )
    echo "name: $name, version: $version"
    # curl -X GET "api.modrinth.com/projects/"
done
