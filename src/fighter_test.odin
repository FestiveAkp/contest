package main

import "core:testing"

@(test)
test_move_right :: proc(t: ^testing.T) {
	f := Fighter {
		pos      = {WINDOW_WIDTH / 2, GROUND_Y},
		grounded = true,
	}
	start_x := f.pos.x
	simulate_fighter(
		&f,
		TickInput{move_x = 1, crouch_held = false, jump_pressed = false},
		f.pos.x,
		FIXED_DT,
	)
	testing.expect(t, f.pos.x > start_x, "moving right should increase x")
}

@(test)
test_move_left :: proc(t: ^testing.T) {
	f := Fighter {
		pos      = {WINDOW_WIDTH / 2, GROUND_Y},
		grounded = true,
	}
	start_x := f.pos.x
	simulate_fighter(
		&f,
		TickInput{move_x = -1, crouch_held = false, jump_pressed = false},
		f.pos.x,
		FIXED_DT,
	)
	testing.expect(t, f.pos.x < start_x, "moving left should decrease x")
}

@(test)
test_no_input_does_not_move :: proc(t: ^testing.T) {
	f := Fighter {
		pos      = {WINDOW_WIDTH / 2, GROUND_Y},
		grounded = true,
	}
	start_x := f.pos.x
	simulate_fighter(
		&f,
		TickInput{move_x = 0, crouch_held = false, jump_pressed = false},
		f.pos.x,
		FIXED_DT,
	)
	testing.expect_value(t, f.pos.x, start_x)
}

@(test)
test_clamped_at_left_edge :: proc(t: ^testing.T) {
	f := Fighter {
		pos      = {20, GROUND_Y},
		grounded = true,
	}
	for _ in 0 ..< 120 {
		simulate_fighter(
			&f,
			TickInput{move_x = -1, crouch_held = false, jump_pressed = false},
			f.pos.x,
			FIXED_DT,
		)
	}
	testing.expect_value(t, f.pos.x, f32(20))
}

@(test)
test_clamped_at_right_edge :: proc(t: ^testing.T) {
	f := Fighter {
		pos      = {WINDOW_WIDTH - 20, GROUND_Y},
		grounded = true,
	}
	for _ in 0 ..< 120 {
		simulate_fighter(
			&f,
			TickInput{move_x = 1, crouch_held = false, jump_pressed = false},
			f.pos.x,
			FIXED_DT,
		)
	}
	testing.expect_value(t, f.pos.x, f32(WINDOW_WIDTH - 20))
}

@(test)
test_jump_moves_up_and_returns_to_ground :: proc(t: ^testing.T) {
	f := Fighter {
		pos      = {WINDOW_WIDTH / 2, GROUND_Y},
		grounded = true,
	}
	simulate_fighter(
		&f,
		TickInput{move_x = 0, crouch_held = false, jump_pressed = true},
		f.pos.x,
		FIXED_DT,
	)
	testing.expect(t, f.pos.y < GROUND_Y, "jumping should lift the fighter off the ground")
	testing.expect(t, !f.grounded, "fighter should not be grounded immediately after jumping")

	for _ in 0 ..< 300 {
		simulate_fighter(
			&f,
			TickInput{move_x = 0, crouch_held = false, jump_pressed = false},
			f.pos.x,
			FIXED_DT,
		)
	}
	testing.expect_value(t, f.pos.y, f32(GROUND_Y))
	testing.expect(t, f.grounded, "fighter should land back on the ground")
}

@(test)
test_jump_ignored_while_airborne :: proc(t: ^testing.T) {
	f := Fighter {
		pos      = {WINDOW_WIDTH / 2, GROUND_Y},
		grounded = true,
	}
	simulate_fighter(
		&f,
		TickInput{move_x = 0, crouch_held = false, jump_pressed = true},
		f.pos.x,
		FIXED_DT,
	)
	vel_after_first_jump := f.vel_y

	simulate_fighter(
		&f,
		TickInput{move_x = 0, crouch_held = false, jump_pressed = true},
		f.pos.x,
		FIXED_DT,
	)
	testing.expect(
		t,
		f.vel_y != JUMP_VELOCITY,
		"a second jump press while airborne should not re-trigger the jump impulse",
	)
	_ = vel_after_first_jump
}

@(test)
test_starts_idle_with_no_input :: proc(t: ^testing.T) {
	f := Fighter {
		pos      = {WINDOW_WIDTH / 2, GROUND_Y},
		grounded = true,
	}
	simulate_fighter(
		&f,
		TickInput{move_x = 0, crouch_held = false, jump_pressed = false},
		f.pos.x,
		FIXED_DT,
	)
	testing.expect_value(t, f.state, FighterState.Idle)
}

@(test)
test_moving_enters_walk_state :: proc(t: ^testing.T) {
	f := Fighter {
		pos      = {WINDOW_WIDTH / 2, GROUND_Y},
		grounded = true,
	}
	simulate_fighter(
		&f,
		TickInput{move_x = 1, crouch_held = false, jump_pressed = false},
		f.pos.x,
		FIXED_DT,
	)
	testing.expect_value(t, f.state, FighterState.Walk)
}

@(test)
test_holding_down_enters_crouch_state :: proc(t: ^testing.T) {
	f := Fighter {
		pos      = {WINDOW_WIDTH / 2, GROUND_Y},
		grounded = true,
	}
	simulate_fighter(
		&f,
		TickInput{move_x = 0, crouch_held = true, jump_pressed = false},
		f.pos.x,
		FIXED_DT,
	)
	testing.expect_value(t, f.state, FighterState.Crouch)
}

@(test)
test_crouch_overrides_walk_input :: proc(t: ^testing.T) {
	f := Fighter {
		pos      = {WINDOW_WIDTH / 2, GROUND_Y},
		grounded = true,
	}
	simulate_fighter(
		&f,
		TickInput{move_x = 1, crouch_held = true, jump_pressed = false},
		f.pos.x,
		FIXED_DT,
	)
	testing.expect_value(t, f.state, FighterState.Crouch)
}

@(test)
test_leaving_ground_enters_jump_state :: proc(t: ^testing.T) {
	f := Fighter {
		pos      = {WINDOW_WIDTH / 2, GROUND_Y},
		grounded = true,
	}
	simulate_fighter(
		&f,
		TickInput{move_x = 0, crouch_held = false, jump_pressed = true},
		f.pos.x,
		FIXED_DT,
	)
	testing.expect_value(t, f.state, FighterState.Jump)
}

@(test)
test_landing_returns_to_idle_state :: proc(t: ^testing.T) {
	f := Fighter {
		pos      = {WINDOW_WIDTH / 2, GROUND_Y},
		grounded = true,
	}
	simulate_fighter(
		&f,
		TickInput{move_x = 0, crouch_held = false, jump_pressed = true},
		f.pos.x,
		FIXED_DT,
	)
	for _ in 0 ..< 300 {
		simulate_fighter(
			&f,
			TickInput{move_x = 0, crouch_held = false, jump_pressed = false},
			f.pos.x,
			FIXED_DT,
		)
	}
	testing.expect_value(t, f.state, FighterState.Idle)
}

@(test)
test_faces_opponent_to_the_right :: proc(t: ^testing.T) {
	f := Fighter {
		pos      = {WINDOW_WIDTH / 2, GROUND_Y},
		grounded = true,
	}
	simulate_fighter(
		&f,
		TickInput{move_x = 0, crouch_held = false, jump_pressed = false},
		f.pos.x + 100,
		FIXED_DT,
	)
	testing.expect_value(t, f.facing, Facing.Right)
}

@(test)
test_faces_opponent_to_the_left :: proc(t: ^testing.T) {
	f := Fighter {
		pos      = {WINDOW_WIDTH / 2, GROUND_Y},
		grounded = true,
	}
	simulate_fighter(
		&f,
		TickInput{move_x = 0, crouch_held = false, jump_pressed = false},
		f.pos.x - 100,
		FIXED_DT,
	)
	testing.expect_value(t, f.facing, Facing.Left)
}

@(test)
test_facing_flips_as_opponent_crosses :: proc(t: ^testing.T) {
	f := Fighter {
		pos      = {WINDOW_WIDTH / 2, GROUND_Y},
		grounded = true,
	}
	simulate_fighter(
		&f,
		TickInput{move_x = 0, crouch_held = false, jump_pressed = false},
		f.pos.x + 100,
		FIXED_DT,
	)
	testing.expect_value(t, f.facing, Facing.Right)

	simulate_fighter(
		&f,
		TickInput{move_x = 0, crouch_held = false, jump_pressed = false},
		f.pos.x - 100,
		FIXED_DT,
	)
	testing.expect_value(t, f.facing, Facing.Left)
}

@(test)
test_state_frame_resets_on_transition_and_counts_up_otherwise :: proc(t: ^testing.T) {
	f := Fighter {
		pos      = {WINDOW_WIDTH / 2, GROUND_Y},
		grounded = true,
	}
	simulate_fighter(
		&f,
		TickInput{move_x = 1, crouch_held = false, jump_pressed = false},
		f.pos.x,
		FIXED_DT,
	)
	testing.expect_value(t, f.state_frame, 0)

	simulate_fighter(
		&f,
		TickInput{move_x = 1, crouch_held = false, jump_pressed = false},
		f.pos.x,
		FIXED_DT,
	)
	testing.expect_value(t, f.state_frame, 1)

	simulate_fighter(
		&f,
		TickInput{move_x = 0, crouch_held = false, jump_pressed = false},
		f.pos.x,
		FIXED_DT,
	)
	testing.expect_value(t, f.state, FighterState.Idle)
	testing.expect_value(t, f.state_frame, 0)
}

@(test)
test_light_attack_pressed_enters_attack_state :: proc(t: ^testing.T) {
	f := Fighter {
		pos      = {WINDOW_WIDTH / 2, GROUND_Y},
		grounded = true,
	}
	simulate_fighter(
		&f,
		TickInput{move_x = 0, crouch_held = false, light_attack_pressed = true},
		f.pos.x,
		FIXED_DT,
	)
	testing.expect_value(t, f.state, FighterState.Attack)
}

@(test)
test_light_attack_locks_movement :: proc(t: ^testing.T) {
	f := Fighter {
		pos      = {WINDOW_WIDTH / 2, GROUND_Y},
		grounded = true,
	}
	start_x := f.pos.x
	simulate_fighter(
		&f,
		TickInput{move_x = 1, crouch_held = false, light_attack_pressed = true},
		f.pos.x,
		FIXED_DT,
	)
	testing.expect_value(t, f.pos.x, start_x)

	simulate_fighter(
		&f,
		TickInput{move_x = 1, crouch_held = false, light_attack_pressed = false},
		f.pos.x,
		FIXED_DT,
	)
	testing.expect(t, f.pos.x == start_x, "movement should stay locked for the rest of the attack")
}

@(test)
test_light_attack_ignored_while_airborne :: proc(t: ^testing.T) {
	f := Fighter {
		pos      = {WINDOW_WIDTH / 2, GROUND_Y - 100},
		grounded = false,
	}
	simulate_fighter(
		&f,
		TickInput{move_x = 0, crouch_held = false, light_attack_pressed = true},
		f.pos.x,
		FIXED_DT,
	)
	testing.expect_value(t, f.state, FighterState.Jump)
}

@(test)
test_light_attack_repress_does_not_reset_timer :: proc(t: ^testing.T) {
	f := Fighter {
		pos      = {WINDOW_WIDTH / 2, GROUND_Y},
		grounded = true,
	}
	simulate_fighter(
		&f,
		TickInput{move_x = 0, crouch_held = false, light_attack_pressed = true},
		f.pos.x,
		FIXED_DT,
	)
	simulate_fighter(
		&f,
		TickInput{move_x = 0, crouch_held = false, light_attack_pressed = false},
		f.pos.x,
		FIXED_DT,
	)
	testing.expect_value(t, f.state_frame, 1)

	// A second attack press mid-swing should not restart the attack.
	simulate_fighter(
		&f,
		TickInput{move_x = 0, crouch_held = false, light_attack_pressed = true},
		f.pos.x,
		FIXED_DT,
	)
	testing.expect_value(t, f.state, FighterState.Attack)
	testing.expect_value(t, f.state_frame, 2)
}

@(test)
test_light_attack_returns_to_idle_after_total_frames :: proc(t: ^testing.T) {
	f := Fighter {
		pos      = {WINDOW_WIDTH / 2, GROUND_Y},
		grounded = true,
	}
	simulate_fighter(
		&f,
		TickInput{move_x = 0, crouch_held = false, light_attack_pressed = true},
		f.pos.x,
		FIXED_DT,
	)
	for _ in 0 ..< LIGHT_ATTACK_TOTAL_FRAMES {
		testing.expect_value(t, f.state, FighterState.Attack)
		simulate_fighter(
			&f,
			TickInput{move_x = 0, crouch_held = false, light_attack_pressed = false},
			f.pos.x,
			FIXED_DT,
		)
	}
	testing.expect_value(t, f.state, FighterState.Idle)
	testing.expect_value(t, f.state_frame, 0)
}
