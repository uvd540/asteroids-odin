package main_desktop

import rl "vendor:raylib"
import "core:log"
import "../game"

main :: proc() {
	context.logger = log.create_console_logger()
	
	game.init()

	for !rl.WindowShouldClose() {
		game.update()
	}

	game.shutdown()
}