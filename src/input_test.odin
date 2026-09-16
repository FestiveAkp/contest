package main

import "core:testing"

@(test)
test_consume_input_clears_jump_pressed :: proc(t: ^testing.T) {
	pending := PendingInput {
		jump_pressed = true,
	}

	first := consume_input(&pending)
	testing.expect(t, first.jump_pressed, "first consume should see the buffered jump press")

	second := consume_input(&pending)
	testing.expect(
		t,
		!second.jump_pressed,
		"a second consume in the same redraw should not see the same jump press again",
	)
}

@(test)
test_consume_input_move_x_persists_across_consumes :: proc(t: ^testing.T) {
	pending := PendingInput {
		move_x = 1,
	}

	first := consume_input(&pending)
	testing.expect_value(t, first.move_x, f32(1))

	second := consume_input(&pending)
	testing.expect_value(t, second.move_x, f32(1))
}
