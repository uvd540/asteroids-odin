#!/bin/bash

OUT_DIR="build/desktop"

mkdir -p $OUT_DIR

odin build main_desktop -out:$OUT_DIR/game_desktop.bin
cp -R ./assets/ ./$OUT_DIR/assets/
