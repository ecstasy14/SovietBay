/obj/item/mechcomp/handscanner
	name = "hand scanner"
	desc = "MAXIMUM SECURITY!!!"

	icon_state = "comp_hscan"

	above = 1

	var/send_name = 1

/obj/item/mechcomp/handscanner/attack_hand(var/mob/user as mob)
	if(!ready)
		return

	if (ishuman(user))
		if (mFingerprints in user.mutations)
			return

		var/mob/living/carbon/human/H = user
		if (H.gloves)
			return

		flick(icon_state + "_active",src)
		if(send_name)
			handler.sendSignal(H.name)
			return
		else
			handler.sendSignal(H.get_full_print())
			return

	..()

/obj/item/mechcomp/handscanner/afterattack(atom/target as turf, mob/user as mob)
	if(get_dist(src, target) == 1)
		if(isturf(target) && target.density)
			user.drop_item()
			src.loc = target
			anchored = 1

/obj/item/mechcomp/handscanner/get_settings(var/source)
	var/dat = "<B>Hand scanner settings:</B><BR>"
	dat += "Send name or fingerprints : <A href='?src=\ref[source];hand_action=set_name'>[send_name ? "name" : "fingerprints"]</A><BR>"
	return dat

/obj/item/mechcomp/handscanner/set_settings(href, href_list, user)
	if(href_list["hand_action"])
		switch(href_list["hand_action"])
			if("set_name")
				send_name = !send_name

		return MT_REFRESH