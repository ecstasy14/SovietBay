/obj/item/mechcomp/sigbuilder
	name = "signal builder"
	desc = "Ain't Bob."

	icon_state = "comp_builder"

	var/buffer = ""
	var/start_sig = ""
	var/end_sig = ""
	var/delim = ""
	var/auto_clear = 0

/obj/item/mechcomp/sigbuilder/New()
	..()
	handler.addInput("add to buffer", "add")
	handler.addInput("send buffer", "send")
	handler.addInput("clear buffer", "clear")

/obj/item/mechcomp/sigbuilder/proc/add(var/signal)
	buffer = "[buffer][signal][delim]"

/obj/item/mechcomp/sigbuilder/proc/send(var/signal)
	if(signal == handler.trigger_signal)
		handler.sendSignal("[start_sig][delim][buffer][end_sig]")
		if(auto_clear)
			clear(handler.trigger_signal)

/obj/item/mechcomp/sigbuilder/proc/clear(var/signal)
	if(signal == handler.trigger_signal)
		buffer = ""

/obj/item/mechcomp/sigbuilder/get_settings(var/source)
	var/dat = "<B>Signal builder settings:</B><BR>"
	dat += "Starting signal : <A href='?src=\ref[source];builder_action=set_start'>[length(start_sig) == 0 ? " " : start_sig]</A><BR>"
	dat += "Ending signal : <A href='?src=\ref[source];builder_action=set_end'>[length(end_sig) == 0 ? " " : end_sig]</A><BR>"
	dat += "Delimiter : <A href='?src=\ref[source];builder_action=set_delim'>[length(delim) == 0 ? " " : delim]</A><BR>"
	dat += "Clear after sending : <A href='?src=\ref[source];builder_action=set_clear'>[auto_clear ? "true" : "false"]</A><BR>"
	dat += "<HR>"
	dat += "Current buffer : [buffer]<BR>"
	return dat

/obj/item/mechcomp/sigbuilder/set_settings(href, href_list, user)
	if(href_list["builder_action"])
		switch(href_list["builder_action"])
			if("set_start")
				start_sig = sanitize(input(user, "Enter a new starting signal:", "Set starting signal") as text)
			if("set_end")
				end_sig = sanitize(input(user, "Enter a new ending signal:", "Set ending signal") as text)
			if("set_delim")
				delim = sanitize(input(user, "Enter a new delimiter:", "Set delimiter") as text)
			if("set_clear")
				auto_clear = !auto_clear

		return MT_REFRESH
