#!/bin/sh
draw() {
  path="$(readlink -f -- "$1" | sed 's/\\/\\\\/g;s/"/\\"/g')"

  # Check if ueberzug is available
  if [ -p "$FIFO_UEBERZUG" ]; then
    printf '{"action":"add","identifier":"preview","x":%d,"y":%d,"width":%d,"height":%d,"scaler":"contain","scaling_position_x":0.5,"scaling_position_y":0.5,"path":"%s"}\n' \
      "$x" "$y" "$width" "$height" "$path" >"$FIFO_UEBERZUG"
    exit 1
  else
    # Fallback to chafa when ueberzug is not available
    chafa --fit-width "$width" "$path"
    exit 1
  fi
}

hash() {
  cache="$HOME/.cache/lf/$(stat --printf '%n\0%i\0%F\0%s\0%W\0%Y' -- "$(readlink -f -- "$1")" | sha256sum | cut -d' ' -f1).jpg"
}

cache() {
  if ! [ -f "$cache" ]; then
    dir="$(dirname -- "$cache")"
    [ -d "$dir" ] || mkdir -p -- "$dir"
    "$@"
  fi

  # Use draw function which now handles ueberzug fallback
  draw "$cache"
}

file="$1"
width="$2"
height="$3"
x="$4"
y="$5"

case "$(file -Lb --mime-type -- "$file")" in
  image/*)
    orientation="$(magick identify -format '%[orientation]\n' -- "$file[0]" 2>/dev/null)"
    if [ -n "$orientation" ] \
        && [ "$orientation" != Undefined ] \
        && [ "$orientation" != TopLeft ]; then
      hash "$file"
      cache magick -- "$file[0]" -auto-orient "$cache"
    else
      draw "$file"
    fi
    ;;
  video/*)
    hash "$file"
    cache ffmpegthumbnailer -i "$file" -o "$cache" -s 0
    ;;
  text/*)
    exec cat "$file"
    ;;
esac

# Fallback for unsupported types or when preview fails
file -Lb -- "$file" | fold -s -w "$width"
exit 0
