package main

import rl "vendor:raylib"

WINDOW_WIDTH :: 1280
WINDOW_HEIGHT :: 720
WINDOW_NAME :: "Contest"
GROUND_Y :: WINDOW_HEIGHT - 100

FIXED_DT :: f32(1.0 / 60.0) // how much game time each simulate_player call advances, independent of the screen's redraw rate

main :: proc() {
	rl.InitWindow(WINDOW_WIDTH, WINDOW_HEIGHT, WINDOW_NAME)
	defer rl.CloseWindow()
	rl.SetTargetFPS(60)

	player := Player {
		pos      = {WINDOW_WIDTH / 2, GROUND_Y},
		grounded = true,
	}

	pending_input := PendingInput{}

	accumulator := f32(0) // game time not yet simulated
	for !rl.WindowShouldClose() {
		frame_time := rl.GetFrameTime()
		if frame_time > 0.25 {frame_time = 0.25} 	// cap it so a stall doesn't force a huge catch-up burst

		poll_input(&pending_input) // read raylib once per screen redraw, before simulate_player runs

		accumulator += frame_time
		for accumulator >= FIXED_DT {
			sample := consume_input(&pending_input)
			simulate_player(
				&player,
				sample.move_x,
				sample.crouch_held,
				sample.jump_pressed,
				FIXED_DT,
			)
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
