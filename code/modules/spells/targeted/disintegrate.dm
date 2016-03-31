spell/targeted/disintegrate
	name = "Disintegrate"
	desc = "This spell instantly kills somebody adjacent to you with the vilest of magick."

	school = "evocation"
	charge_max = 600
	spell_flags = NEEDSCLOTHES
	invocation = "EI NATH"
	invocation_type = "shout"
	range = 1
	cooldown_min = 200 //100 deciseconds reduction per rank

	hud_state =  "wiz_disintegrate"

	destroys = "gib_brain"

	sparks_spread = 1
	sparks_amt = 4