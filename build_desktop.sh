#!/bin/bash

OUT_DIR="build/desktop"

mkdir -p $OUT_DIR

if ! odin build main_desktop -out:$OUT_DIR/game_desktop.bin; then 
	exit 1
fi

cp -R ./assets/ ./$OUT_DIR/assets/

echo "Desktop build created in ${OUT_DIR}"