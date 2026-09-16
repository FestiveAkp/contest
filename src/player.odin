package main

import rl "vendor:raylib"

PLAYER_SPEED :: 300
PLAYER_WIDTH :: 40
PLAYER_HEIGHT :: 120
GRAVITY :: 2000
JUMP_VELOCITY :: -800

Player :: struct {
	pos:         rl.Vector2, // feet position (ground contact point)
	vel_y:       f32,
	grounded:    bool,
	state:       PlayerState,
	state_frame: int, // ticks spent in the current state, reset on transition
}

// Advances the player by one tick. Takes plain values instead of reading
// raylib directly, so tests can call it with made-up input, and rollback
// can later call it again with a logged TickInput to redo a past tick.
simulate_player :: proc(p: ^Player, move: f32, down: bool, jump: bool, dt: f32) {
	if !down {
		p.pos.x += move * PLAYER_SPEED * dt
		p.pos.x = clamp(p.pos.x, 20, WINDOW_WIDTH - 20)
	}

	if jump && p.grounded && !down {
		p.vel_y = JUMP_VELOCITY
		p.grounded = false
	}

	p.vel_y += GRAVITY * dt
	p.pos.y += p.vel_y * dt

	if p.pos.y >= GROUND_Y {
		p.pos.y = GROUND_Y
		p.vel_y = 0
		p.grounded = true
	}

	update_player_state(p, move, down)
}

draw_player :: proc(p: Player) {
	height: f32 = PLAYER_HEIGHT
	if p.state == .Crouch {
		height = PLAYER_HEIGHT / 2
	}

	rect := rl.Rectangle{p.pos.x - PLAYER_WIDTH / 2, p.pos.y - height, PLAYER_WIDTH, height}
	rl.DrawRectangleRec(rect, rl.BLACK)
}
