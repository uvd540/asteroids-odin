package raylib_wasm

import rl "vendor:raylib"
import "core:log"

TEXTURE_DATA :: #load("round_cat.png")
texture: rl.Texture

game_init :: proc() {
	rl.SetConfigFlags({.WINDOW_RESIZABLE, .VSYNC_HINT})
	rl.InitWindow(1280, 720, "Raylib Web Example")

	// Set up sample texture
	img := rl.LoadImageFromMemory(".png", raw_data(TEXTURE_DATA), i32(len(TEXTURE_DATA)))
	texture = rl.LoadTextureFromImage(img)
	rl.UnloadImage(img)
}

game_update :: proc() {
	rl.BeginDrawing()
	rl.ClearBackground({0, 120, 153, 255})
	rl.DrawTextureEx(texture, rl.GetMousePosition(), 0, 5, rl.WHITE)
	rl.DrawRectangleRec({0, 0, 250, 100}, rl.BLACK)
	rl.GuiLabel({10, 10, 200, 20}, "raygui works!")

	if rl.GuiButton({10, 30, 200, 20}, "Print to log (see console)") {
		log.info("Logging works!")
	}

	if rl.GuiButton({10, 60, 200, 20}, "Source code (opens GitHub)") {
		rl.OpenURL("https://github.com/karl-zylinski/odin-raylib-wasm")
	}

	rl.EndDrawing()

	// Anything on temp allocator is invalid after end-of-frame
	free_all(context.temp_allocator)
}

game_shutdown :: proc() {
	log.info("shutting down")
	rl.CloseWindow()
}