/obj/item/mechcomp/toggle
	name = "toggle component"
	desc = "A high-tech lightswitch"

	icon_state = "comp_toggle"

	var/active = 0

	var/signal_on = "1"
	var/signal_off = "0"

/obj/item/mechcomp/toggle/update_icon()
	..()
	if(active)
		icon_state += "_active"

/obj/item/mechcomp/toggle/New()
	..()
	handler.add_input("activate", "turn_on")
	handler.add_input("deactivate", "turn_off")
	handler.add_input("toggle", "toggle")
	handler.add_input("send state", "state")

/obj/item/mechcomp/toggle/proc/turn_on(signal)
	if(signal == handler.trigger_signal)
		active = 1
		handler.send_signal(signal_on)
		update_icon()

/obj/item/mechcomp/toggle/proc/turn_off(signal)
	if(signal == handler.trigger_signal)
		active = 0
		handler.send_signal(signal_off)
		update_icon()

/obj/item/mechcomp/toggle/proc/toggle(signal)
	if(signal == handler.trigger_signal)
		if(active)
			turn_off(signal)
		else
			turn_on(signal)

/obj/item/mechcomp/toggle/proc/state(signal)
	if(signal == handler.trigger_signal)
		handler.send_signal(active ? signal_on : signal_off)

/obj/item/mechcomp/toggle/get_settings(var/source)
	var/dat = "<B>Toggle component settings:</B><BR>"
	dat += "'On' signal: <A href='?src=\ref[source];toggle_action=set_on'>[signal_on]</A><BR>"
	dat += "'Off' signal: <A href='?src=\ref[source];toggle_action=set_off'>[signal_off]</A><BR>"
	dat += "<HR>"
	dat += "Current state : [active ? "on" : "off"]<BR>"
	return dat

/obj/item/mechcomp/toggle/set_settings(href, href_list, user)
	if(href_list["toggle_action"])
		switch(href_list["toggle_action"])
			if("set_on")
				signal_on = inputText(user, "Enter a new 'on' signal:", "Set 'on' signal", "1")
			if("set_off")
				signal_off = inputText(user, "Enter a new 'off' signal:", "Set 'off' signal", "0")

		return MT_REFRESH