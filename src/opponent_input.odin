package main

// Slower than the player's own walk speed (move_x of ±1) so the opponent is
// easy to catch and attack while there's no real AI or offense yet.
OPPONENT_MOVE_SCALE :: 0.5

// Placeholder opponent "AI": just walks straight toward the player. No
// jumping, crouching, or attacking yet — enough to have a moving target.
opponent_input :: proc(opponent: Fighter, player: Fighter) -> TickInput {
	move_x: f32 = 0
	if player.pos.x < opponent.pos.x {
		move_x = -OPPONENT_MOVE_SCALE
	} else if player.pos.x > opponent.pos.x {
		move_x = OPPONENT_MOVE_SCALE
	}

	return TickInput{move_x = move_x}
}
