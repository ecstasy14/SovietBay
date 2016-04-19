/obj/item/mechcomp/mic
	name = "microphone"
	desc = "Sh-h-h... Be vewy, vewy quiet!"

	icon_state = "comp_mic"

	place_flags = MECH_PLACE_ABOVE | MECH_PLACE_WALL

	var/show_name = 0

//Should the component care about the language or the verb?
/obj/item/mechcomp/mic/hear_talk(mob/speaker as mob, text, verb, datum/language/speaking)
	var/msg = text
	if(show_name)
		if(isliving(speaker))
			var/mob/living/living = speaker
			msg = living.GetVoice() + ":" + msg
		else
			msg = speaker.name + ":" + msg
	handler.send_signal(msg)

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