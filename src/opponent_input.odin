package main

// Slower than the player's own walk speed (move_x of ±1) so the opponent is
// easy to catch and attack while there's no real AI or offense yet.
OPPONENT_MOVE_SCALE :: 0.5

OPPONENT_MOVE_TOWARD_PLAYER :: false

// Placeholder opponent "AI"
opponent_input :: proc(opponent: Fighter, player: Fighter) -> TickInput {
	move_x: f32 = 0
	when OPPONENT_MOVE_TOWARD_PLAYER {
		if player.pos.x < opponent.pos.x {
			move_x = -OPPONENT_MOVE_SCALE
		} else if player.pos.x > opponent.pos.x {
			move_x = OPPONENT_MOVE_SCALE
		}
	}

	return TickInput{move_x = move_x}
}
