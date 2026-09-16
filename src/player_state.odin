package main

// Every state a player can be in. Attacks and hit reactions will key their
// hitbox/hurtbox data and animation off (state, state_frame), so the full
// set is declared now even though only Idle/Walk/Crouch/Jump are reachable
// today — Attack/Hitstun/Blockstun/Knockdown have no transition into them
// yet and will be wired up alongside the attack and hit-detection systems.
PlayerState :: enum {
	Idle,
	Walk,
	Crouch,
	Jump,
	Attack,
	Hitstun,
	Blockstun,
	Knockdown,
}

// Derives this tick's state from movement input and physics results, and
// resets state_frame whenever the state changes so attack/animation code
// can read "how many frames have I been in this state" later.
update_player_state :: proc(p: ^Player, move: f32, down: bool) {
	new_state: PlayerState
	switch {
	case !p.grounded:
		new_state = .Jump
	case down:
		new_state = .Crouch
	case move != 0:
		new_state = .Walk
	case:
		new_state = .Idle
	}

	if new_state != p.state {
		p.state = new_state
		p.state_frame = 0
	} else {
		p.state_frame += 1
	}
}
