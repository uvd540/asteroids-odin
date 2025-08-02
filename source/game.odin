package game

import "core:c"
import "core:math/rand"
import rl "vendor:raylib"

run: bool

Game :: struct {
	inputs:      Inputs,
	ship:        Ship,
	projectiles: [dynamic]Projectile,
	asteroids:   [dynamic]Asteroid,
}

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
projectile_delay: f64 : 0.1
projectile_last_fire_time: f64 = 0
Projectile :: struct {
	position:     [2]f32,
	velocity:     [2]f32,
	time_to_live: f32,
}

projectile_spawn :: proc(
	projectiles: ^[dynamic]Projectile,
	position: [2]f32,
	heading: f32,
	current_time: f64,
) {
	if current_time < projectile_last_fire_time + projectile_delay {
		return
	}
	p := Projectile {
		position     = position,
		velocity     = rl.Vector2Rotate({projectile_speed, 0}, heading),
		time_to_live = 1,
	}
	append(projectiles, p)
	projectile_last_fire_time = current_time
}

projectiles_update :: proc(projectiles: ^[dynamic]Projectile, dt: f32) {
	for i := 0; i < len(projectiles); i += 1 {
		projectiles[i].time_to_live -= dt
		if projectiles[i].time_to_live <= 0 {
			unordered_remove(projectiles, i)
			i -= 1
			continue
		}
		projectiles[i].position += projectiles[i].velocity * dt
		wrap(&projectiles[i].position, {0, 0}, {800, 800})
	}
}

projectiles_draw :: proc(projectiles: []Projectile) {
	for projectile in projectiles {
		rl.DrawCircleV(projectile.position, 4, rl.WHITE)
	}
}

NUM_ASTEROIDS_START :: 24
Asteroid :: struct {
	type:     AsteroidType,
	position: [2]f32,
	velocity: [2]f32,
}

AsteroidType :: enum {
	Large,
	Medium,
	Small,
}

AsteroidRadius := [AsteroidType]f32 {
	.Large  = 40,
	.Medium = 20,
	.Small  = 10,
}

AsteroidSpeed := [AsteroidType]f32 {
	.Large  = 20,
	.Medium = 40,
	.Small  = 80,
}

asteroids_init :: proc(asteroids: ^[dynamic]Asteroid) {
	for &asteroid in asteroids {
		asteroid.type = rand.choice_enum(AsteroidType)
		asteroid.position = 800 * {rand.float32(), rand.float32()}
		asteroid.velocity = rl.Vector2Rotate(
			{AsteroidSpeed[asteroid.type], 0},
			rand.float32() * 2 * rl.PI,
		)
	}
}

asteroids_update :: proc(asteroids: ^[dynamic]Asteroid, dt: f32) {
	for &asteroid in asteroids {
		asteroid.position += asteroid.velocity * dt
		wrap(&asteroid.position, {0, 0}, {800, 800})
	}
}

asteroids_draw :: proc(asteroids: [dynamic]Asteroid) {
	for asteroid in asteroids {
		rl.DrawCircleLinesV(asteroid.position, AsteroidRadius[asteroid.type], rl.WHITE)
	}
}

game: Game

init :: proc() {
	run = true
	rl.SetConfigFlags({.WINDOW_RESIZABLE, .VSYNC_HINT})
	rl.InitWindow(800, 800, "asteroids")
	ship_init(&game.ship)
	game.asteroids = make([dynamic]Asteroid, NUM_ASTEROIDS_START, NUM_ASTEROIDS_START * 4)
	asteroids_init(&game.asteroids)
}

update :: proc() {
	dt := rl.GetFrameTime()
	timestamp := rl.GetTime()
	inputs_update(&game.inputs)
	ship_update(&game.ship, game.inputs, dt)
	if game.inputs.fire {
		projectile_spawn(&game.projectiles, game.ship.position, game.ship.heading, timestamp)
	}
	projectiles_update(&game.projectiles, dt)
	asteroids_update(&game.asteroids, dt)
	rl.BeginDrawing()
	rl.ClearBackground(rl.BLACK)
	ship_draw(game.ship)
	projectiles_draw(game.projectiles[:])
	asteroids_draw(game.asteroids)
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
	delete(game.projectiles)
	delete(game.asteroids)
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

