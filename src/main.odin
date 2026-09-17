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

	player := Fighter {
		pos      = {WINDOW_WIDTH / 4, GROUND_Y},
		grounded = true,
		facing   = .Right,
	}
	opponent := Fighter {
		pos      = {3 * WINDOW_WIDTH / 4, GROUND_Y},
		grounded = true,
		facing   = .Left,
	}

	pending_input := PendingInput{}

	accumulator := f32(0) // game time not yet simulated
	for !rl.WindowShouldClose() {
		frame_time := rl.GetFrameTime()
		if frame_time > 0.25 {frame_time = 0.25} 	// cap it so a stall doesn't force a huge catch-up burst

		poll_input(&pending_input) // read raylib once per screen redraw, before simulate_player runs

		accumulator += frame_time
		for accumulator >= FIXED_DT {
			opponent_pos_x := opponent.pos.x
			player_pos_x := player.pos.x

			tick_input_player := consume_input(&pending_input)
			simulate_fighter(&player, tick_input_player, opponent_pos_x, FIXED_DT)

			tick_input_opponent := opponent_input(opponent, player)
			simulate_fighter(&opponent, tick_input_opponent, player_pos_x, FIXED_DT)
			accumulator -= FIXED_DT
		}

		rl.BeginDrawing()
		rl.ClearBackground(rl.LIGHTGRAY)

		rl.DrawLine(0, GROUND_Y, WINDOW_WIDTH, GROUND_Y, rl.DARKGRAY)
		draw_fighter(player)
		draw_fighter(opponent)

		rl.DrawFPS(10, 10)
		rl.EndDrawing()
	}
}
