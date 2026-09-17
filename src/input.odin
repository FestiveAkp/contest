package main

import rl "vendor:raylib"

// What simulate_fighter needs for one step: input for a single 1/60s tick.
// simulate_fighter never reads raylib directly, so later on, rollback can
// redo a past tick just by handing simulate_fighter its logged TickInput
// again instead of needing live keyboard state.
TickInput :: struct {
	move_x:                f32, // -1, 0, or 1
	crouch_held:           bool,
	jump_pressed:          bool,
	light_attack_pressed:  bool,
	medium_attack_pressed: bool,
	heavy_attack_pressed:  bool,
}

// Bridges the gap between "raylib key events, valid for one redraw" and
// "simulate_fighter calls, 0-N per redraw": poll_input sets jump_pressed
// once per redraw, and it survives until consume_input reads and clears
// it, so exactly one simulate_fighter call picks up each press.
PendingInput :: struct {
	move_x:                f32,
	crouch_held:           bool,
	jump_pressed:          bool,
	light_attack_pressed:  bool,
	medium_attack_pressed: bool,
	heavy_attack_pressed:  bool,
}

// Call once per screen redraw, before simulate_fighter runs.
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
	if rl.IsKeyPressed(.J) {
		pending.light_attack_pressed = true
	}
	if rl.IsKeyPressed(.K) {
		pending.medium_attack_pressed = true
	}
	if rl.IsKeyPressed(.L) {
		pending.heavy_attack_pressed = true
	}
}

// Called once per simulate_fighter call to read the pending input into an
// TickInput, then clears jump_pressed so a second simulate_fighter call in
// the same redraw doesn't see the same press again.
consume_input :: proc(pending: ^PendingInput) -> TickInput {
	input := TickInput {
		move_x                = pending.move_x,
		crouch_held           = pending.crouch_held,
		jump_pressed          = pending.jump_pressed,
		light_attack_pressed  = pending.light_attack_pressed,
		medium_attack_pressed = pending.medium_attack_pressed,
		heavy_attack_pressed  = pending.heavy_attack_pressed,
	}
	pending.jump_pressed = false
	pending.light_attack_pressed = false
	pending.medium_attack_pressed = false
	pending.heavy_attack_pressed = false
	return input
}
