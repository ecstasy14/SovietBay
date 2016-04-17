/obj/item/mechcomp/delaycomp
	name = "delay component"
	desc = "Ve-e-ery slo-o-ow."

	icon_state = "comp_wait"

	var/preserve = 0
	var/active = 0
	var/delay = 10

/obj/item/mechcomp/delaycomp/New()
	..()
	handler.addInput("start", "start_delay")

/obj/item/mechcomp/delaycomp/proc/start_delay(var/signal)
	if(signal == handler.trigger_signal && !active)
		active = 1
		spawn(delay)
			active = 0
			if(preserve)
				handler.sendSignal(signal)
			else
				handler.sendSignal()

/obj/item/mechcomp/delaycomp/attach()
	if(!anchored)
		active = 0

/obj/item/mechcomp/delaycomp/get_settings(var/source)
	var/dat = "<B>ADelay settings:</B><BR>"
	dat += "Set the delay: <A href='?src=\ref[source];delay_action=set_delay'>[delay]</A><BR>"
	dat += "Preserve signal : <A href='?src=\ref[source];delay_action=set_preserve'>[preserve ? "true" : "false"]</A><BR>"
	return dat

/obj/item/mechcomp/delaycomp/set_settings(href, href_list, user)
	if(href_list["delay_action"])
		switch(href_list["delay_action"])
			if("set_delay")
				delay = input(user, "Enter a new delay(10-600)", "Set delay") as num
				delay = max(delay, 10)
				delay = min(delay, 600)
			if("set_preserve")
				preserve = !preserve

		return MT_REFRESH