#+build !wasm32
#+build !wasm64p32

package raylib_wasm

import rl "vendor:raylib"
import "core:log"

main :: proc() {
	context.logger = log.create_console_logger()
	
	game_init()

	for !rl.WindowShouldClose() {
		game_update()
	}

	game_shutdown()
}