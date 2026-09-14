package main

import "core:testing"

@(test)
test_move_right :: proc(t: ^testing.T) {
	p := Player{pos = {WINDOW_WIDTH / 2, GROUND_Y}}
	start_x := p.pos.x
	simulate_player(&p, 1, FIXED_DT)
	testing.expect(t, p.pos.x > start_x, "moving right should increase x")
}

@(test)
test_move_left :: proc(t: ^testing.T) {
	p := Player{pos = {WINDOW_WIDTH / 2, GROUND_Y}}
	start_x := p.pos.x
	simulate_player(&p, -1, FIXED_DT)
	testing.expect(t, p.pos.x < start_x, "moving left should decrease x")
}

@(test)
test_no_input_does_not_move :: proc(t: ^testing.T) {
	p := Player{pos = {WINDOW_WIDTH / 2, GROUND_Y}}
	start_x := p.pos.x
	simulate_player(&p, 0, FIXED_DT)
	testing.expect_value(t, p.pos.x, start_x)
}

@(test)
test_clamped_at_left_edge :: proc(t: ^testing.T) {
	p := Player{pos = {20, GROUND_Y}}
	for _ in 0 ..< 120 {
		simulate_player(&p, -1, FIXED_DT)
	}
	testing.expect_value(t, p.pos.x, f32(20))
}

@(test)
test_clamped_at_right_edge :: proc(t: ^testing.T) {
	p := Player{pos = {WINDOW_WIDTH - 20, GROUND_Y}}
	for _ in 0 ..< 120 {
		simulate_player(&p, 1, FIXED_DT)
	}
	testing.expect_value(t, p.pos.x, f32(WINDOW_WIDTH - 20))
}
