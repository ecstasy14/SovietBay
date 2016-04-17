/obj/item/mechcomp/synthcomp
	name = "sound synthesizer"
	desc = "Now YOUR room can also have fucking Tourettes!"

	icon_state = "comp_synth"

	above = 1

/obj/item/mechcomp/synthcomp/New()
	..()
	handler.addInput("input", "fire")
	handler.max_outputs = 0

/obj/item/mechcomp/synthcomp/afterattack(atom/target as turf, mob/user as mob)
	if(get_dist(src, target) == 1)
		if(isturf(target) && target.density)
			user.drop_item()
			src.loc = target
			anchored = 1

/obj/item/mechcomp/synthcomp/proc/fire(var/signal)
	if(!ready)
		return

	flick(icon_state+"_active", src)

	ready = 0
	spawn(20)
		ready = 1

	if(signal)
		for(var/mob/who in hearers(src, null))
			who.show_message("<span class='game say'><span class='name'>\The [src]</span> [pick("bleeps","beeps", "screeches")], \"[signal]\"</span>",2)