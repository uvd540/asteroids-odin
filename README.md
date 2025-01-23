# Odin + Raylib on the web

![image](https://github.com/user-attachments/assets/35251bc2-dfdf-4564-b2ac-9a2716e0eee7)

Make games using Odin + Raylib that works in browser and on desktop.

Live example: https://zylinski.se/odin-raylib-web/

## Requirements

- Emscripten. Follow instructions here: https://emscripten.org/docs/getting_started/downloads.html (the stuff under "Installation instructions using the emsdk (recommended)").
- Recent Odin compiler: This uses Raylib binding changes that were done on January 1, 2025.

## Getting started

1. Change `EMSCRIPTEN_SDK_DIR` in `build_web.bat/sh` to point to your emscripten setup.
2. Run `build_web.bat/sh`.
3. Web game is in the `build/web` folder.

> [!NOTE]
> `build_web.bat` is for windows, `build_web.sh` is for Linux / macOS.

> [!WARNING]
> You may not be able to start `build/web/index.html` directly, because you'll get "CORS policy" javascript errors. You can get around that by starting a local web server using python. Go into `build/web` and run:
> 
> `python -m http.server`
>
> Open `localhost:8000` in your browser to play the game.
>
> _If you don't have python, then emscripten actually comes with it. Look in the `python` folder of where you installed emscripten._

You can also build a desktop executable using `build_desktop.bat/sh`. It will end up in the `build/desktop` folder.

Put any assets (textures, sounds etc) you want into the `assets` folder. It will be merged into the web build when the emscripten compiler runs. It is also copied to the `build/desktop` folder when you make a desktop build.

## What works

- Use raylib, raygui, rlgl using the default `vendor:raylib` bindings.
- Allocator that works with maps and SIMD (uses emcripten's `malloc`).
- Temp allocator.
- Logger.
- fmt.println etc
- There's a wrapper for `read_entire_file` and `write_entire_file` from `core:os` that can files from `assets` directory, even on web. See `souce/utils.odin`

> [!NOTE]
> The files written using `write_entire_file` don't really exist outside the browser. They don't survive closing the tab. But you can write a file and load it within the same session. You can use it to make your old desktop code run, even though it won't be possible to _really_ save anything.

## Debugging

I recommend debugging the desktop build when you can (add `-debug` inside `build_desktop.bat/sh` and use for example [RAD Debugger](https://github.com/EpicGamesExt/raddebugger)). But if you get web-only bugs then you can add `-g` to the the `emcc` line in the build script. This will give you crash stack traces with useful information. It works in Chrome, but I didn't get it to work in Firefox.

## Sublime Text

There is a Sublime project file: `project.sublime-project`. It has a build system pre-setup that lets you run the build scripts for both web and desktop.

## How it works

The contents of the `main_web` folder is built in `js_wasm32` build mode. That package also imports the `game` package. So it's the whole game. `js` is a special target that uses `<odin>/core/sys/wasm/js/odin.js` to talk to the browser. `wasm32` means that the code itself is possible to run in a web browser.

When `main_web` has been compiled into an object file called `game.wasm.o`, then the emscripten compiler `emcc` is run. It is fed both the `game.wasm.o` file and also compiles the `main_web/main_web.c` file. That C file says what will happen when our game is run in a web browser: It'll call our Odin code! We also feed `emcc` the prebuilt raylib and raygui wasm libs.

The default WASM allocator doesn't play nicely with emscripten, so I've added an `emscripten_allocator`. That allocator uses the libc procedures `malloc`, `calloc`, `free` and `realloc` that emscripten exposes. It is set up in `web_init` of `source/main_web/main_web_entry.odin`

## Web build in my Hot Reload template

I have updated my Odin + Raylib + Hot Reload template with similar capabilities: https://github.com/karl-zylinski/odin-raylib-hot-reload-game-template -- Note that it's just for making a _release web build_, no hot reloading is supported with the web version!

## Questions?

Ask questions in my gamedev Discord: https://discord.gg/4FsHgtBmFK

## Acknowledgements
[Caedo's repository](https://github.com/Caedo/raylib_wasm_odin) and [Aronicu's repository](https://github.com/Aronicu/Raylib-WASM) helped me with:
- The initial emscripten setup
- The logger setup
- The idea of using python to host a server
