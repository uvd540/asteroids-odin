package game

import "core:c"
import "core:fmt"
import "core:log"
import rl "vendor:raylib"

run: bool

inputs: Inputs
ship: Ship
projectiles: [dynamic]Projectile

DEBUG_MODE :: false

Inputs :: struct {
	accelerate: bool,
	turn_left:  bool,
	turn_right: bool,
	fire:       bool,
}

inputs_update :: proc(inputs: ^Inputs) {
	inputs^ = Inputs{}
	inputs.accelerate = rl.IsKeyDown(.UP)
	inputs.turn_left = rl.IsKeyDown(.LEFT)
	inputs.turn_right = rl.IsKeyDown(.RIGHT)
	inputs.fire = rl.IsKeyDown(.SPACE)
}

Ship :: struct {
	position:     [2]f32,
	velocity:     [2]f32,
	heading:      f32,
	max_speed:    f32,
	acceleration: f32,
	deceleration: f32,
	size:         f32,
	turn_speed:   f32,
}

ship_init :: proc(ship: ^Ship) {
	ship.position = {400, 400}
	ship.size = 15
	ship.acceleration = 500
	ship.deceleration = 100
	ship.turn_speed = 2 * rl.PI
	ship.max_speed = 500
}

ship_update :: proc(ship: ^Ship, inputs: Inputs, dt: f32) {
	if inputs.turn_left {
		ship.heading -= ship.turn_speed * dt
	}
	if inputs.turn_right {
		ship.heading += ship.turn_speed * dt
	}
	if inputs.accelerate {
		ship.velocity += rl.Vector2Rotate({ship.acceleration * dt, 0}, ship.heading)
	}
	ship.velocity = rl.Vector2MoveTowards(ship.velocity, {0, 0}, ship.deceleration * dt)
	ship.velocity = rl.Vector2ClampValue(ship.velocity, 0, ship.max_speed)
	ship.position += ship.velocity * dt
	wrap(&ship.position, {0, 0}, {800, 800})
}

ship_draw :: proc(ship: Ship) {
	pt0 := rl.Vector2Rotate({ship.size, 0}, ship.heading)
	pt1 := rl.Vector2Rotate(pt0, 2 * rl.PI / 3)
	pt2 := rl.Vector2Rotate(pt1, 2 * rl.PI / 3)
	rl.DrawLineEx(pt0 + ship.position, pt1 + ship.position, 2, rl.WHITE)
	rl.DrawLineEx(pt0 + ship.position, pt2 + ship.position, 2, rl.WHITE)
	rl.DrawLineEx((pt1 * 0.5) + ship.position, (pt2 * 0.5) + ship.position, 2, rl.WHITE)
	if (DEBUG_MODE) {
		rl.DrawCircleLinesV(ship.position, ship.size, rl.RED)
	}
}

projectile_speed :: 500
Projectile :: struct {
	position:     [2]f32,
	velocity:     [2]f32,
	time_to_live: f32,
}

projectile_spawn :: proc(projectiles: ^[dynamic]Projectile, position: [2]f32, heading: f32) {
	p := Projectile {
		position     = position,
		velocity     = rl.Vector2Rotate({projectile_speed, 0}, heading),
		time_to_live = 1,
	}
	append(projectiles, p)
}

projectiles_update :: proc(projectiles: ^[dynamic]Projectile, dt: f32) {
	for i := 0; i < len(projectiles); i += 1 {
		projectiles[i].time_to_live -= dt
		if projectiles[i].time_to_live <= 0 {
			unordered_remove(projectiles, i)
			i -= 1
		}
	}
}

projectiles_draw :: proc(projectiles: []Projectile) {
	for projectile in projectiles {
		rl.DrawCircleV(projectile.position, 4, rl.WHITE)
	}
}

init :: proc() {
	run = true
	rl.SetConfigFlags({.WINDOW_RESIZABLE, .VSYNC_HINT})
	rl.InitWindow(800, 800, "asteroids")
	ship_init(&ship)
}

update :: proc() {
	dt := rl.GetFrameTime()
	inputs_update(&inputs)
	ship_update(&ship, inputs, dt)
	if inputs.fire {
		projectile_spawn(&projectiles, ship.position, ship.heading)
	}
	projectiles_update(&projectiles, dt)
	rl.BeginDrawing()
	rl.ClearBackground(rl.BLACK)
	ship_draw(ship)
	projectiles_draw(projectiles[:])
	rl.EndDrawing()

	// Anything allocated using temp allocator is invalid after this.
	free_all(context.temp_allocator)
}

// In a web build, this is called when browser changes size. Remove the
// `rl.SetWindowSize` call if you don't want a resizable game.
parent_window_size_changed :: proc(w, h: int) {
	rl.SetWindowSize(c.int(w), c.int(h))
}

shutdown :: proc() {
	rl.CloseWindow()
}

should_run :: proc() -> bool {
	when ODIN_OS != .JS {
		// Never run this proc in browser. It contains a 16 ms sleep on web!
		if rl.WindowShouldClose() {
			run = false
		}
	}

	return run
}

wrap :: proc(position: ^[2]f32, min: [2]f32, max: [2]f32) {
	if position.x < min.x {
		position.x = max.x
	}
	if position.x > max.x {
		position.x = min.x
	}
	if position.y < min.y {
		position.y = max.y
	}
	if position.y > max.y {
		position.y = min.y
	}
}

