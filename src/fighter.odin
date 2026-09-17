package main

import rl "vendor:raylib"

FIGHTER_SPEED :: 300
FIGHTER_WIDTH :: 40
FIGHTER_HEIGHT :: 120
GRAVITY :: 2000
JUMP_VELOCITY :: -800

Facing :: enum {
	Left,
	Right,
}

Fighter :: struct {
	pos:            rl.Vector2, // feet position (ground contact point)
	vel_y:          f32,
	grounded:       bool,
	state:          FighterState,
	state_frame:    int, // ticks spent in the current state, reset on transition
	facing:         Facing,
	current_attack: AttackKind,
}

// Advances the fighter by one tick. Takes plain values instead of reading
// raylib directly, so tests can call it with made-up input, and rollback
// can later call it again with a logged TickInput to redo a past tick.
simulate_fighter :: proc(f: ^Fighter, input: TickInput, opponent_x: f32, dt: f32) {
	f.facing = opponent_x >= f.pos.x ? .Right : .Left

	_, wants_attack := pressed_attack(input)
	attacking := f.state == .Attack || (wants_attack && f.grounded)

	if !attacking {
		if !input.crouch_held {
			// Walk left/right
			f.pos.x += input.move_x * FIGHTER_SPEED * dt
			f.pos.x = clamp(f.pos.x, 20, WINDOW_WIDTH - 20)
		}

		if input.jump_pressed && f.grounded && !input.crouch_held {
			// Jump
			f.vel_y = JUMP_VELOCITY
			f.grounded = false
		}
	}

	// Apply gravity
	f.vel_y += GRAVITY * dt
	f.pos.y += f.vel_y * dt

	// Keep player on the ground
	if f.pos.y >= GROUND_Y {
		f.pos.y = GROUND_Y
		f.vel_y = 0
		f.grounded = true
	}

	update_fighter_state(f, input)
}
