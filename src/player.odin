package main

import rl "vendor:raylib"

PLAYER_SPEED :: 300
PLAYER_WIDTH :: 40
PLAYER_HEIGHT :: 120

Player :: struct {
	pos: rl.Vector2, // feet position (ground contact point)
}

update_player :: proc(p: ^Player, dt: f32) {
	move := f32(0)
	if rl.IsKeyDown(.A) {
		move -= 1
	}
	if rl.IsKeyDown(.D) {
		move += 1
	}

	simulate_player(p, move, dt)
}

// Pure simulation step, decoupled from raylib input polling so it can be unit tested directly.
simulate_player :: proc(p: ^Player, move: f32, dt: f32) {
	p.pos.x += move * PLAYER_SPEED * dt
	p.pos.x = clamp(p.pos.x, 20, WINDOW_WIDTH - 20)
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
