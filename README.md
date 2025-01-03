![image](https://github.com/user-attachments/assets/0ed449ff-ae6f-4336-aa26-02df5928f263)

Live example: https://zylinski.se/odin-raylib-web/

Make games using Odin + Raylib that works in browser and on desktop.

## Requirements

- Emscripten. Download and install somewhere on your computer. https://emscripten.org/
- Recent Odin compiler: This uses Raylib binding changes that were done on January 1, 2025.

## Getting started

1. Change `set EMSCRIPTEN_SDK_DIR=c:\emsdk` in `build_web.bat` to point to your emscripten setup.
2. Run `build_web.bat`
3. Web game is in the `build/web` folder

You can also build a desktop executable using `build_desktop.bat`. It will end up in the `build/desktop` folder.

In some web browsers you can't test the game locally due to "CORS policy". In that case you can run a local web server using python. Go to `build/web` in a terminal and run this:
```
python -m http.server
```
Go to `localhost:8000` in your browser to start the game.

> TODO: Is there a better way to avoid running a local web server?

## What works

- raylib, raygui, rlgl using the default `vendor:raylib` bindings.
- Allocator that works with maps and SIMD.
- Temp allocator.
- Logger.
- Most of `core` that doesn't do OS-specific things.

## What won't work

- `core:os`.
- `fmt.print` and similar procs. Instead, use `log.info` and `log.infof`. Note: `fmt.tprintf` (temp string formatting) still works!

## Debugging

I recommend debugging native build when you can. But if you get web-only bugs then you can add `-g` to the the `emcc` line in the build script. This will give you crash stack traces with useful information. It works in Chrome, but I didn't get it to work in Firefox.

## TODO:
- Alternatives for running program that works in chrome (annoying to have to use server...)
- Add build scripts for mac / linux
- Load files API that works for everything

## Acknowledgements
[Caedo's repository](https://github.com/Caedo/raylib_wasm_odin) and [Aronicu's repository](https://github.com/Aronicu/Raylib-WASM) helped me with:
- The initial emscripten setup
- The logger setup
- The idea of using python to host a server
