package main

opponent_input :: proc(opponent: Fighter, player: Fighter) -> TickInput {
	move_x: f32 = 0
	if player.pos.x < opponent.pos.x {
		move_x = -0.5
	} else if player.pos.x > opponent.pos.x {
		move_x = 0.5
	}

	return TickInput{move_x = move_x}
}
