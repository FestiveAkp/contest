package main

// Every state a fighter can be in. Attacks and hit reactions will key their
// hitbox/hurtbox data and animation off (state, state_frame), so the full
// set is declared now even though only Idle/Walk/Crouch/Jump are reachable
// today — Attack/Hitstun/Blockstun/Knockdown have no transition into them
// yet and will be wired up alongside the attack and hit-detection systems.
FighterState :: enum {
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
update_fighter_state :: proc(f: ^Fighter, input: TickInput) {
	new_state: FighterState
	switch {
	case !f.grounded:
		new_state = .Jump
	case input.crouch_held:
		new_state = .Crouch
	case input.move_x != 0:
		new_state = .Walk
	case:
		new_state = .Idle
	}

	if new_state != f.state {
		f.state = new_state
		f.state_frame = 0
	} else {
		f.state_frame += 1
	}
}
