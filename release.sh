#!/usr/bin/env sh

set -ue

root_file="${1:-cv-english.tex}"
working_directory="${2:-$PWD}"
compiler="${3:-latexmk}"
args="${4:--pdf -latexoption=-file-line-error -latexoption=-interaction=nonstopmode}"
extra_system_packages="${5:-}"

png_density=300

if [ -n "$extra_system_packages" ]; then
  apt-get update
  for pkg in $extra_system_packages; do
    echo "Install $pkg by apt"
    apt-get -y install "$pkg"
  done
fi

if [ -n "$working_directory" ]; then
  cd "$working_directory"
fi

touch .timestamp

"$compiler" $args "$root_file"

# Build pngs
for document in *.pdf
do
  name=$(basename "$document" .pdf)

  gs \
    -dSAFER \
    -dTextAlphaBits=4 \
    -dGraphicsAlphaBits=4 \
    -r"$png_density" \
    -sDEVICE=png16m \
    -o "$name.png" \
    "$document"
done
