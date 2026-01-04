#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 1 ]]; then
  echo "Usage: scripts/import_skill_icons.sh /path/to/icons"
  exit 1
fi

SRC_DIR="$1"
DEST_DIR="IRL-RPG/Assets.xcassets/SkillIcons"

if [[ ! -d "$SRC_DIR" ]]; then
  echo "Source directory not found: $SRC_DIR"
  exit 1
fi

mkdir -p "$DEST_DIR"

for file in "$SRC_DIR"/*; do
  [[ -f "$file" ]] || continue
  ext="${file##*.}"
  base="$(basename "$file")"
  name="${base%.*}"

  case "$ext" in
    png|PNG|pdf|PDF) ;;
    *) continue ;;
  esac

  image_set="${DEST_DIR}/${name}.imageset"
  mkdir -p "$image_set"
  cp -f "$file" "$image_set/"

  filename="$(basename "$file")"

  ext_lc="$(echo "$ext" | tr '[:upper:]' '[:lower:]')"
  if [[ "$ext_lc" == "pdf" ]]; then
    cat > "${image_set}/Contents.json" <<EOF
{
  "images" : [
    {
      "filename" : "${filename}",
      "idiom" : "universal",
      "scale" : "1x"
    }
  ],
  "info" : {
    "author" : "xcode",
    "version" : 1
  },
  "properties" : {
    "preserves-vector-representation" : true
  }
}
EOF
  else
    cat > "${image_set}/Contents.json" <<EOF
{
  "images" : [
    {
      "filename" : "${filename}",
      "idiom" : "universal"
    }
  ],
  "info" : {
    "author" : "xcode",
    "version" : 1
  }
}
EOF
  fi
done

echo "Imported icons into ${DEST_DIR}"
