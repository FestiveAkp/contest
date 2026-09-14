package main

import rl "vendor:raylib"

PLAYER_SPEED :: 300
PLAYER_WIDTH :: 40
PLAYER_HEIGHT :: 120
GRAVITY :: 2000
JUMP_VELOCITY :: -800

Player :: struct {
	pos:      rl.Vector2, // feet position (ground contact point)
	vel_y:    f32,
	grounded: bool,
}

update_player :: proc(p: ^Player, dt: f32) {
	move := f32(0)
	if rl.IsKeyDown(.A) {
		move -= 1
	}
	if rl.IsKeyDown(.D) {
		move += 1
	}

	jump := rl.IsKeyPressed(.W)

	simulate_player(p, move, jump, dt)
}

// Pure simulation step, decoupled from raylib input polling so it can be unit tested directly.
simulate_player :: proc(p: ^Player, move: f32, jump: bool, dt: f32) {
	p.pos.x += move * PLAYER_SPEED * dt
	p.pos.x = clamp(p.pos.x, 20, WINDOW_WIDTH - 20)

	if jump && p.grounded {
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
}

draw_player :: proc(p: Player) {
	rect := rl.Rectangle {
		p.pos.x - PLAYER_WIDTH / 2,
		p.pos.y - PLAYER_HEIGHT,
		PLAYER_WIDTH,
		PLAYER_HEIGHT,
	}
	rl.DrawRectangleRec(rect, rl.BLACK)
}
