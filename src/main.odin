package main

import rl "vendor:raylib"

WINDOW_WIDTH :: 1280
WINDOW_HEIGHT :: 720
WINDOW_NAME :: "Contest"
GROUND_Y :: WINDOW_HEIGHT - 100

PLAYER_SPEED :: 300
PLAYER_WIDTH :: 40
PLAYER_HEIGHT :: 120

FIXED_DT :: f32(1.0 / 60.0) // fixed sim step, decoupled from render rate, for deterministic replay/rollback later

Player :: struct {
	pos: rl.Vector2, // feet position (ground contact point)
}

main :: proc() {
	rl.InitWindow(WINDOW_WIDTH, WINDOW_HEIGHT, WINDOW_NAME)
	defer rl.CloseWindow()
	rl.SetTargetFPS(60)

	player := Player {
		pos = {WINDOW_WIDTH / 2, GROUND_Y},
	}

	accumulator := f32(0)
	for !rl.WindowShouldClose() {
		frame_time := rl.GetFrameTime()
		if frame_time > 0.25 { frame_time = 0.25 } // avoid spiral of death on stalls
		accumulator += frame_time
		for accumulator >= FIXED_DT {
			update_player(&player, FIXED_DT)
			accumulator -= FIXED_DT
		}

		rl.BeginDrawing()
		rl.ClearBackground(rl.RAYWHITE)

		rl.DrawLine(0, GROUND_Y, WINDOW_WIDTH, GROUND_Y, rl.DARKGRAY)
		draw_player(player)

		rl.DrawFPS(10, 10)
		rl.EndDrawing()
	}
}

update_player :: proc(p: ^Player, dt: f32) {
	move := f32(0)
	if rl.IsKeyDown(.A) || rl.IsKeyDown(.LEFT) {
		move -= 1
	}
	if rl.IsKeyDown(.D) || rl.IsKeyDown(.RIGHT) {
		move += 1
	}

	p.pos.x += move * PLAYER_SPEED * dt

	p.pos.x = clamp(p.pos.x, 20, WINDOW_WIDTH - 20)
}

draw_player :: proc(p: Player) {
	rect := rl.Rectangle {
		p.pos.x - PLAYER_WIDTH / 2,
		p.pos.y - PLAYER_HEIGHT,
		PLAYER_WIDTH,
		PLAYER_HEIGHT,
	}
	rl.DrawRectangleRec(rect, rl.BLACK)
}
