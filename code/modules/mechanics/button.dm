/*
		The button
*/
/obj/item/mechcomp/button
	name = "button"
	desc = "A normal button. Dare to press it?"
	icon_state = "comp_button"
	above = 1

/obj/item/mechcomp/button/attach()
	density = !density

/obj/item/mechcomp/button/attack_hand(var/mob/user)
	if(anchored)
		flick(icon_state + "_active", src)
		handler.sendSignal()
	else
		..()