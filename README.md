![image](https://github.com/user-attachments/assets/0ed449ff-ae6f-4336-aa26-02df5928f263)

Live example: https://zylinski.se/odin-raylib-web/

Make games using Odin + Raylib that work in browser and on desktop.

## Requirements

- Emscripten. Download and install somewhere on your computer. https://emscripten.org/
- Recent Odin compiler: This uses Raylib binding changes that were done on January 1, 2025.

## Usage

1. Change `set EMSCRIPTEN_SDK_DIR=c:\emsdk` in `build_web.bat` to point to your emscripten setup.
2. Run `build_web.bat`
3. Web game is in `game_web` folder

You can also build a desktop executable using `build_desktop.bat`

## Limitations

You can't use:
- `core:os`
- Procedures in `core:fmt` that print to console. There's a pre-setup loger instead `core:log`, I suggest you use that. Also, you can still use `fmt.tprint` to format strings.

## Acknowledgements
This repository helped me with the initial emscripten and logger setup: https://github.com/Aronicu/Raylib-WASM
