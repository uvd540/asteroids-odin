package game

import rl "vendor:raylib"
import "core:log"

texture: rl.Texture

init :: proc() {
	rl.SetConfigFlags({.WINDOW_RESIZABLE, .VSYNC_HINT})
	rl.InitWindow(1280, 720, "Odin + Raylib on the web")

	// Anything in `assets` folder is available to load.
	texture = rl.LoadTexture("assets/round_cat.png")
}

update :: proc() {
	rl.BeginDrawing()
	rl.ClearBackground({0, 120, 153, 255})
	rl.DrawTextureEx(texture, rl.GetMousePosition(), 0, 5, rl.WHITE)
	rl.DrawRectangleRec({0, 0, 250, 100}, rl.BLACK)
	rl.GuiLabel({10, 10, 200, 20}, "raygui works!")

	if rl.GuiButton({10, 30, 200, 20}, "Print to log (see console)") {
		log.info("Logging works!")
	}

	if rl.GuiButton({10, 60, 200, 20}, "Source code (opens GitHub)") {
		rl.OpenURL("https://github.com/karl-zylinski/odin-raylib-web")
	}

	rl.EndDrawing()

	// Anything allocated using temp allocator is invalid after this.
	free_all(context.temp_allocator)
}

shutdown :: proc() {
	rl.CloseWindow()
}