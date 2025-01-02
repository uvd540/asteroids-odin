![image](https://github.com/user-attachments/assets/69f9568c-8eee-45ba-bb83-9845d323e9a1)

Live example: https://zylinski.se/odin-raylib-wasm/

Make games using Odin + Raylib that work in browser and on desktop.

## Requirements

- Emscripten. Download and install somewhere on your computer. https://emscripten.org/ 

## Usage

1. Change `set EMSCRIPTEN_SDK_DIR=c:\emsdk` in `build.bat` to point to your emscripten setup.
2. Run `build_web.bat`
3. Web game is in `game_web` folder

You can also build a desktop executable using `build_desktop.bat`

## Limitations

You can't use:
- `core:os`
- Procedures in `core:fmt` that print to console (you can use `fmt.tprint` etc).

## Acknowledgements
This repository helped me with the initial emscripten and logger setup: https://github.com/Aronicu/Raylib-WASM
