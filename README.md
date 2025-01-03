![image](https://github.com/user-attachments/assets/0ed449ff-ae6f-4336-aa26-02df5928f263)

Live example: https://zylinski.se/odin-raylib-web/

Make games using Odin + Raylib that work in browser and on desktop.

## Requirements

- Emscripten. Download and install somewhere on your computer. https://emscripten.org/
- Recent Odin compiler: This uses Raylib binding changes that were done on January 1, 2025.

## Usage

1. Change `set EMSCRIPTEN_SDK_DIR=c:\emsdk` in `build_web.bat` to point to your emscripten setup.
2. Run `build_web.bat`
3. Web game is in the `build/web` folder

You can also build a desktop executable using `build_desktop.bat`. It will end up in the `build/desktop` folder.

In some web browsers your game won't work due to "CORS policy", in that case you can run a local web server using python. Within `game_web`, run this:
```
python -m http.server
```
Go to `localhost:8000` in your browser to start the game.

> TODO: Is there a better way to avoid running a local webserver?

## Limitations

You can't use:
- `core:os`
- Procedures in `core:fmt` that print to console. There's a pre-setup loger instead `core:log`, I suggest you use that, for example `log.info("message")` and `log.infof("formatted message: %v", some_string)`. Note: You can still use `fmt.tprint` to format strings.

## Debugging
I recommend debugging native build when you can. But if you get web-only bugs then you can add `-g` to  the the `emcc` line in the build script to generate debug information. This will give you callstacks with useful information. It works in Chrome, but I didn't get it to work in Firefox.

## TODO:
- Add assets loading (you can also use #load, as game.odin shows)
- Alternatives for running program that works in chrome (annoying to have to use server...)
- Organize main_web and main_desktop into directories (I think)
- Add build scripts for mac / linux
- Make sure zero_memory true / false on allocator actually works

## Acknowledgements
[This repository](https://github.com/Aronicu/Raylib-WASM) helped me with:
- The initial emscripten setup
- The logger setup
- The idea of using python to host a server
