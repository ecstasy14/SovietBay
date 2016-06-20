/*
		The button
*/
/obj/item/mechcomp/button
	name = "button"
	desc = "A normal button. Dare to press it?"

	icon_state = "comp_button"

	place_flags = MECH_PLACE_ABOVE

/obj/item/mechcomp/button/attack_hand(mob/user)
	if(!ready)
		return
	if(anchored)
		flick(icon_state + "_active", src)
		ready = 0
		spawn(21)
			ready = 1
		handler.send_signal()
	else
		..()

/obj/item/mechcomp/button/attach()
	..()
	density = !density