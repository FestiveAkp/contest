package main

import rl "vendor:raylib"

AttackVisual :: struct {
	reach:     f32,
	thickness: f32,
	color:     rl.Color,
}

// Reach/thickness/color of the attack's arm swing, purely for telling the
// three attack kinds apart on screen until real sprites exist.
attack_visuals := [AttackKind]AttackVisual {
	.Light = {reach = FIGHTER_WIDTH, thickness = 4, color = rl.YELLOW},
	.Medium = {reach = FIGHTER_WIDTH * 1.5, thickness = 7, color = rl.ORANGE},
	.Heavy = {reach = FIGHTER_WIDTH * 2, thickness = 10, color = rl.RED},
}

draw_fighter :: proc(f: Fighter) {
	height: f32 = FIGHTER_HEIGHT
	if f.state == .Crouch {
		height = FIGHTER_HEIGHT / 2
	}

	rect := rl.Rectangle{f.pos.x - FIGHTER_WIDTH / 2, f.pos.y - height, FIGHTER_WIDTH, height}
	rl.DrawRectangleRec(rect, f.state == .Attack ? rl.BLUE : rl.BLACK)

	notch_x := f.facing == .Right ? f.pos.x + FIGHTER_WIDTH / 2 : f.pos.x - FIGHTER_WIDTH / 2
	rl.DrawCircleV({notch_x, f.pos.y - height}, 5, rl.RED)

	if f.state == .Attack {
		attack_def := attack_defs[f.current_attack]

		if f.state_frame >= attack_def.startup_frames &&
		   f.state_frame < attack_def.startup_frames + attack_def.active_frames {
			visual := attack_visuals[f.current_attack]
			arm_x :=
				f.facing == .Right ? f.pos.x + FIGHTER_WIDTH / 2 + visual.reach : f.pos.x - FIGHTER_WIDTH / 2 - visual.reach
			rl.DrawLineEx(
				{f.pos.x, f.pos.y - height / 2},
				{arm_x, f.pos.y - height / 2},
				visual.thickness,
				visual.color,
			)
		}
	}
}
