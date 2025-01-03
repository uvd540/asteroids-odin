![image](https://github.com/user-attachments/assets/0ed449ff-ae6f-4336-aa26-02df5928f263)

Live example: https://zylinski.se/odin-raylib-web/

Make games using Odin + Raylib that works in browser and on desktop.

## Requirements

- Emscripten. Download and install somewhere on your computer. https://emscripten.org/
- Recent Odin compiler: This uses Raylib binding changes that were done on January 1, 2025.

## Getting started

1. Change `EMSCRIPTEN_SDK_DIR` in `build_web.bat/sh` to point to your emscripten setup.
2. Run `build_web.bat/sh`.
3. Web game is in the `build/web` folder.

> [!NOTE]
> `build_web.bat` is for windows, `build_web.sh` is for Linux / macOS.

> [!WARNING]
> You may not be able to start `build/web/index.html` directly, because you'll get "CORS policy" javascript errors. You can get around that by starting a local web server using python:
>
> `python -m http.server`
>
> Go to `localhost:8000` to play your game.
>
>
> _Is there a better way? I want to avoid running a local web server and avoid involving a dependency such as python._

You can also build a desktop executable using `build_desktop.bat/sh`. It will end up in the `build/desktop` folder.


## What works

- raylib, raygui, rlgl using the default `vendor:raylib` bindings.
- Allocator that works with maps and SIMD.
- Temp allocator.
- Logger.
- There's a wrapper for `read_entire_file` and `write_entire_file` from `core:os` that works on web as well. See `game/os` package (used in `game.odin` to load a file).
- You can load any file in the `assets` directory. That folder is merged into the wasm data file when the emscripten compiler runs. The folder is also copied to `build/desktop` when you make desktop builds.

## What won't work

- Anything from `core:os` that isn't in the `game/os` package.
- `fmt.print` and similar procs. Instead, use `log.info` and `log.infof`. Note: `fmt.tprintf` (temp string formatting) still works!

## Debugging

I recommend debugging the desktop build when you can (add `-debug` inside `build_desktop.bat/sh` and use for example [RAD Debugger](https://github.com/EpicGamesExt/raddebugger)). But if you get web-only bugs then you can add `-g` to the the `emcc` line in the build script. This will give you crash stack traces with useful information. It works in Chrome, but I didn't get it to work in Firefox.

## TODO:
- Alternatives for running program that works in Chrome (annoying to have to use server...)

## Acknowledgements
[Caedo's repository](https://github.com/Caedo/raylib_wasm_odin) and [Aronicu's repository](https://github.com/Aronicu/Raylib-WASM) helped me with:
- The initial emscripten setup
- The logger setup
- The idea of using python to host a server
