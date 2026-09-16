package main

import "core:testing"

@(test)
test_opponent_walks_toward_player_on_the_left :: proc(t: ^testing.T) {
	opponent := Fighter {
		pos = {WINDOW_WIDTH / 2, GROUND_Y},
	}
	player := Fighter {
		pos = {WINDOW_WIDTH / 4, GROUND_Y},
	}
	input := opponent_input(opponent, player)
	testing.expect_value(t, input.move_x, -OPPONENT_MOVE_SCALE)
}

@(test)
test_opponent_walks_toward_player_on_the_right :: proc(t: ^testing.T) {
	opponent := Fighter {
		pos = {WINDOW_WIDTH / 4, GROUND_Y},
	}
	player := Fighter {
		pos = {WINDOW_WIDTH / 2, GROUND_Y},
	}
	input := opponent_input(opponent, player)
	testing.expect_value(t, input.move_x, OPPONENT_MOVE_SCALE)
}

@(test)
test_opponent_stays_still_when_aligned_with_player :: proc(t: ^testing.T) {
	opponent := Fighter {
		pos = {WINDOW_WIDTH / 2, GROUND_Y},
	}
	player := Fighter {
		pos = {WINDOW_WIDTH / 2, GROUND_Y},
	}
	input := opponent_input(opponent, player)
	testing.expect_value(t, input.move_x, f32(0))
}

@(test)
test_opponent_speed_is_slower_than_player_walk_speed :: proc(t: ^testing.T) {
	testing.expect(
		t,
		OPPONENT_MOVE_SCALE < 1,
		"opponent should move slower than the player's own move_x of 1 so it's easy to catch",
	)
}
