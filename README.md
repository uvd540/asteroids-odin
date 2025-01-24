# Odin + Raylib on the web

![image](https://github.com/user-attachments/assets/35251bc2-dfdf-4564-b2ac-9a2716e0eee7)

Make games using Odin + Raylib that works in browser and on desktop.

Live example: https://zylinski.se/odin-raylib-web/

## Requirements

- **Emscripten**. Follow instructions here: https://emscripten.org/docs/getting_started/downloads.html (the stuff under "Installation instructions using the emsdk (recommended)").
- **Recent Odin compiler**: This uses Raylib binding changes that were done on January 1, 2025.

## Getting started

1. Point `EMSCRIPTEN_SDK_DIR` in `build_web.bat/sh` to where you installed emscripten.
2. Run `build_web.bat/sh`.
3. Web game is in the `build/web` folder.

> [!NOTE]
> `build_web.bat` is for windows, `build_web.sh` is for Linux / macOS.

> [!WARNING]
> You can't run `build/web/index.html` directly due to "CORS policy" javascript errors. You can work around that by running a small python web server:
> - Go to `build/web` in a console.
> - Run `python -m http.server`
> - Go to `localhost:8000` in your browser.
>
> _For those who don't have python: Emscripten comes with it. See the `python` folder in your emscripten installation directory._

Build a desktop executable using `build_desktop.bat/sh`. It will end up in the `build/desktop` folder.

Put any assets (textures, sounds etc) into the `assets` folder. Emscripten will merge those into the web build. For desktop builds, the `assets` folder is copied to the `build/desktop` folder.

## What works

- Use raylib, raygui, rlgl using the default `vendor:raylib` bindings.
- Allocator that works with maps and SIMD (uses emcripten's `malloc`).
- Temp allocator.
- Logger.
- `fmt.println` etc
- There's a wrapper for `read_entire_file` and `write_entire_file` from `core:os` that can files from `assets` directory, even on web. See `source/utils.odin`

> [!NOTE]
> Files written using `write_entire_file` don't exist outside the browser. They don't survive closing the tab. But you can write a file and load it within the same session. You can use it to make your old desktop code run, even though it won't be possible to _really_ save anything.

## Debugging

I recommend debugging the desktop build when you can (add `-debug` inside `build_desktop.bat/sh` and use for example [RAD Debugger](https://github.com/EpicGamesExt/raddebugger)). For web-only bugs, you can add `-g` to the the `emcc` line in the build script. This gives you better crash callstacks. It works in Chrome, not so much in Firefox.

## Sublime Text

There is a Sublime project file: `project.sublime-project`. It has a build system that lets you run the web and desktop build scripts.

## How the web build works

The contents of the `source/main_web` folder is built using the `js_wasm32` target. That package also imports the `source` package (which contains the actually game code). `js` is a special target that uses `<odin>/core/sys/wasm/js/odin.js` to talk to the browser. `wasm32` means 32 bit Web Assembly, it makes the compilation result runnable in a web browser.

`main_web` is compiled into an object file called `game.wasm.o`. The emscripten compiler `emcc` is run and fed the `game.wasm.o` file. It also compiles the `main_web/main_web.c` file. That C file mostly hands control over to our Odin code. It calls the procedures in `source/main_web/main_web_entry.odin`. `main_web.c` also tells emscripten to run `web_update` each "frame". We also feed `emcc` the raylib and raygui WASM libs.

Odin comes with a WASM allocator. But it doesn't play nicely with emscripten, so I've added an `emscripten_allocator`. That allocator uses the libc procedures `malloc`, `calloc`, `free` and `realloc` that emscripten exposes. It is set up in `web_init` of `source/main_web/main_web_entry.odin`

## Web build in my Hot Reload template

My Odin + Raylib + Hot Reload template has been updated with similar capabilities: https://github.com/karl-zylinski/odin-raylib-hot-reload-game-template -- Note: It's just for making a _release web build_, no web hot reloading is supported!

## Questions?

Talk to me on my Discord server: https://discord.gg/4FsHgtBmFK

## Acknowledgements
[Caedo's repository](https://github.com/Caedo/raylib_wasm_odin) and [Aronicu's repository](https://github.com/Aronicu/Raylib-WASM) helped me with:
- The initial emscripten setup
- The logger setup
- The idea of using python to host a server
