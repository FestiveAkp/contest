package main

import rl "vendor:raylib"

AttackKind :: enum {
	Light,
	Medium,
	Heavy,
}

AttackDef :: struct {
	startup_frames:  int,
	active_frames:   int,
	recovery_frames: int,
}

total_attack_frames :: proc(def: AttackDef) -> int {
	return def.startup_frames + def.active_frames + def.recovery_frames
}

attack_defs := [AttackKind]AttackDef {
	.Light = {startup_frames = 6, active_frames = 3, recovery_frames = 10},
	.Medium = {startup_frames = 10, active_frames = 4, recovery_frames = 16},
	.Heavy = {startup_frames = 16, active_frames = 5, recovery_frames = 24},
}

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

pressed_attack :: proc(input: TickInput) -> (kind: AttackKind, ok: bool) {
	if input.light_attack_pressed {
		return .Light, true
	}
	if input.medium_attack_pressed {
		return .Medium, true
	}
	if input.heavy_attack_pressed {
		return .Heavy, true
	}
	return {}, false
}
