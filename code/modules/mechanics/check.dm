/obj/item/mechcomp/check
	name = "signal-check component"
	desc = "Don't fold or go all-in yet!"

	icon_state = "comp_check"

	var/reverse = 0
	var/replace = 0
	var/full_check = 1
	var/case_sensitive = 0

/obj/item/mechcomp/check/New()
	..()
	handler.add_input("check", "checksig")

/obj/item/mechcomp/check/proc/checksig(signal)
	var/send = 0
	if(full_check)
		if(case_sensitive)
			if(signal == handler.trigger_signal)
				send = 1
		else
			if(lowertext(signal) == lowertext(handler.trigger_signal))
				send = 1
	else
		if(case_sensitive)
			if(findtext(signal, handler.trigger_signal))
				send = 1
		else
			if(findtextEx(signal, handler.trigger_signal))
				send = 1

	if(reverse)
		send = !send

	if(send)
		if(replace)
			handler.send_signal()
		else
			handler.send_signal(signal)

/obj/item/mechcomp/check/get_settings(source)
	var/dat = "<B>Signal checker settings:</B><BR>"
	dat += "Replace the signal : <A href='?src=\ref[source];check_action=set_replace'>[replace ? "true" : "false"]</A><BR>"
	dat += "Invert check : <A href='?src=\ref[source];check_action=set_invert'>[reverse ? "true" : "false"]</A><BR>"
	dat += "Match the whole signal : <A href='?src=\ref[source];check_action=set_full'>[full_check ? "true" : "false"]</A><BR>"
	dat += "Case sensitive : <A href='?src=\ref[source];check_action=set_case'>[case_sensitive ? "true" : "false"]</A><BR>"
	return dat

/obj/item/mechcomp/check/set_settings(href, href_list, user)
	if(href_list["check_action"])
		switch(href_list["check_action"])
			if("set_replace")
				replace = !replace
			if("set_reverse")
				reverse = !reverse
			if("set_full")
				full_check = !full_check
			if("set_case")
				case_sensitive = !case_sensitive

		return MT_REFRESH
