/obj/item/mechcomp/synthcomp
	name = "sound synthesizer"
	desc = "Now YOUR room can also have fucking Tourettes!"

	icon_state = "comp_synth"

	place_flags = MECH_PLACE_ABOVE | MECH_PLACE_WALL

/obj/item/mechcomp/synthcomp/New()
	..()
	handler.add_input("input", "fire")
	handler.max_outputs = 0

/obj/item/mechcomp/synthcomp/proc/fire(signal)
	if(!ready)
		return

	flick(icon_state+"_active", src)

	ready = 0
	spawn(20)
		ready = 1

	if(signal)
		/*
		for(var/mob/who in hearers(src, null))
			who.show_message("<span class='game say'><span class='name'>\The [src]</span> [pick("bleeps","beeps", "screeches")], \"[signal]\"</span>",2)
		*/
		compSay(signal)