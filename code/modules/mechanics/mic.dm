/obj/item/mechcomp/mic
	name = "microphone"
	desc = "Sh-h-h... Be vewy, vewy quiet!"

	icon_state = "comp_mic"

	var/show_name = 0

//Should the component care about the language or the verb?
/obj/item/mechcomp/mic/hear_talk(var/mob/speaker as mob, var/text, verb, datum/language/speaking)
	var/msg = text
	if(show_name)
		if(isliving(speaker))
			var/mob/living/living = speaker
			msg = living.GetVoice() + ":" + msg
		else
			msg = speaker.name + ":" + msg
	handler.sendSignal(msg)

/obj/item/mechcomp/mic/afterattack(atom/target as turf, mob/user as mob)
	if(get_dist(src, target) == 1)
		if(isturf(target) && target.density)
			user.drop_item()
			src.loc = target
			anchored = 1

/obj/item/mechcomp/mic/get_settings(var/source)
	var/dat = "<B>Microphone settings:</B><BR>"
	dat += "Add the speaker's name : <A href='?src=\ref[source];mic_action=set_sender'>[show_name ? "true" : "false"]</A><BR>"
	return dat

/obj/item/mechcomp/mic/set_settings(href, href_list, user)
	if(href_list["mic_action"])
		switch(href_list["mic_action"])
			if("set_sender")
				show_name = !show_name

		return MT_REFRESH