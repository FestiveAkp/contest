package main

import rl "vendor:raylib"

WINDOW_WIDTH :: 1280
WINDOW_HEIGHT :: 720
WINDOW_NAME :: "Contest"
GROUND_Y :: WINDOW_HEIGHT - 100

FIXED_DT :: f32(1.0 / 60.0) // fixed sim step, decoupled from render rate, for deterministic replay/rollback later

main :: proc() {
	rl.InitWindow(WINDOW_WIDTH, WINDOW_HEIGHT, WINDOW_NAME)
	defer rl.CloseWindow()
	rl.SetTargetFPS(60)

	player := Player {
		pos      = {WINDOW_WIDTH / 2, GROUND_Y},
		grounded = true,
	}

	accumulator := f32(0)
	for !rl.WindowShouldClose() {
		frame_time := rl.GetFrameTime()
		if frame_time > 0.25 {frame_time = 0.25} 	// avoid spiral of death on stalls
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
