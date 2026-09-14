package main

import "core:testing"

@(test)
test_move_right :: proc(t: ^testing.T) {
	p := Player {
		pos      = {WINDOW_WIDTH / 2, GROUND_Y},
		grounded = true,
	}
	start_x := p.pos.x
	simulate_player(&p, 1, false, FIXED_DT)
	testing.expect(t, p.pos.x > start_x, "moving right should increase x")
}

@(test)
test_move_left :: proc(t: ^testing.T) {
	p := Player {
		pos      = {WINDOW_WIDTH / 2, GROUND_Y},
		grounded = true,
	}
	start_x := p.pos.x
	simulate_player(&p, -1, false, FIXED_DT)
	testing.expect(t, p.pos.x < start_x, "moving left should decrease x")
}

@(test)
test_no_input_does_not_move :: proc(t: ^testing.T) {
	p := Player {
		pos      = {WINDOW_WIDTH / 2, GROUND_Y},
		grounded = true,
	}
	start_x := p.pos.x
	simulate_player(&p, 0, false, FIXED_DT)
	testing.expect_value(t, p.pos.x, start_x)
}

@(test)
test_clamped_at_left_edge :: proc(t: ^testing.T) {
	p := Player {
		pos      = {20, GROUND_Y},
		grounded = true,
	}
	for _ in 0 ..< 120 {
		simulate_player(&p, -1, false, FIXED_DT)
	}
	testing.expect_value(t, p.pos.x, f32(20))
}

@(test)
test_clamped_at_right_edge :: proc(t: ^testing.T) {
	p := Player {
		pos      = {WINDOW_WIDTH - 20, GROUND_Y},
		grounded = true,
	}
	for _ in 0 ..< 120 {
		simulate_player(&p, 1, false, FIXED_DT)
	}
	testing.expect_value(t, p.pos.x, f32(WINDOW_WIDTH - 20))
}

@(test)
test_jump_moves_up_and_returns_to_ground :: proc(t: ^testing.T) {
	p := Player {
		pos      = {WINDOW_WIDTH / 2, GROUND_Y},
		grounded = true,
	}
	simulate_player(&p, 0, true, FIXED_DT)
	testing.expect(t, p.pos.y < GROUND_Y, "jumping should lift the player off the ground")
	testing.expect(t, !p.grounded, "player should not be grounded immediately after jumping")

	for _ in 0 ..< 300 {
		simulate_player(&p, 0, false, FIXED_DT)
	}
	testing.expect_value(t, p.pos.y, f32(GROUND_Y))
	testing.expect(t, p.grounded, "player should land back on the ground")
}

@(test)
test_jump_ignored_while_airborne :: proc(t: ^testing.T) {
	p := Player {
		pos      = {WINDOW_WIDTH / 2, GROUND_Y},
		grounded = true,
	}
	simulate_player(&p, 0, true, FIXED_DT)
	vel_after_first_jump := p.vel_y

	simulate_player(&p, 0, true, FIXED_DT)
	testing.expect(
		t,
		p.vel_y != JUMP_VELOCITY,
		"a second jump press while airborne should not re-trigger the jump impulse",
	)
	_ = vel_after_first_jump
}
