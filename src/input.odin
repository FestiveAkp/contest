package main

import rl "vendor:raylib"

// What simulate_player needs for one step: input for a single 1/60s tick.
// simulate_player never reads raylib directly, so later on, rollback can
// redo a past tick just by handing simulate_player its logged TickInput
// again instead of needing live keyboard state.
TickInput :: struct {
	move_x:       f32, // -1, 0, or 1
	crouch_held:  bool,
	jump_pressed: bool,
}

// Bridges the gap between "raylib key events, valid for one redraw" and
// "simulate_player calls, 0-N per redraw": poll_input sets jump_pressed
// once per redraw, and it survives until consume_input reads and clears
// it, so exactly one simulate_player call picks up each press.
PendingInput :: struct {
	move_x:       f32,
	crouch_held:  bool,
	jump_pressed: bool,
}

// Call once per screen redraw, before simulate_player runs.
poll_input :: proc(pending: ^PendingInput) {
	move := f32(0)
	if rl.IsKeyDown(.A) {
		move -= 1
	}
	if rl.IsKeyDown(.D) {
		move += 1
	}
	pending.move_x = move
	pending.crouch_held = rl.IsKeyDown(.S)

	if rl.IsKeyPressed(.W) {
		pending.jump_pressed = true
	}
}

// Called once per simulate_player call to read the pending input into an
// TickInput, then clears jump_pressed so a second simulate_player call in
// the same redraw doesn't see the same press again.
consume_input :: proc(pending: ^PendingInput) -> TickInput {
	sample := TickInput {
		move_x       = pending.move_x,
		crouch_held  = pending.crouch_held,
		jump_pressed = pending.jump_pressed,
	}
	pending.jump_pressed = false
	return sample
}
