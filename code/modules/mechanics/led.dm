/obj/item/mechcomp/led
	name = "\improper LED"
	desc = "O-o-oh, shiny!"

	icon_state = "comp_led"

	place_flags = MECH_PLACE_WALL

	var/cur_color = "#FFFFFF"
	//max 1
	var/cur_power = 0.2
	//max 7
	var/cur_range = 2

/obj/item/mechcomp/led/New()
	..()
	handler.add_input("activate", "turn_on")
	handler.add_input("deactivate", "turn_off")
	handler.add_input("toggle", "toggle")
	handler.add_input("set rgb", "set_rgb")
	handler.add_input("set power", "set_power")
	handler.add_input("set range", "set_range")
	handler.max_outputs = 0

/obj/item/mechcomp/led/proc/turn_on(signal)
	if(signal == handler.trigger_signal)
		ready = 1
		set_light(cur_range, cur_power, cur_color)
		src.color = cur_color

/obj/item/mechcomp/led/proc/turn_off(signal)
	if(signal == handler.trigger_signal)
		ready = 0
		set_light(0)
		src.color = 0

/obj/item/mechcomp/led/proc/toggle(signal)
	if(signal == handler.trigger_signal)
		if(ready)
			turn_off(signal)
		else
			turn_on(signal)

/obj/item/mechcomp/led/proc/set_rgb(var/signal)
	world.log << signal
	if(length(signal) == 7 && copytext(signal, 1, 2) == "#")
		signal = uppertext(signal)
		//TODO : sanity cleanup. Replace everything that's not a number or a character <= F to F
		cur_color = signal
		if(ready)
			turn_on()

/obj/item/mechcomp/led/proc/set_power(signal)
	//TODO : People in Russia use "," as a delimeter between decimal and fractional parts, BYOND uses "."
	//1. "," should be replaced by "."
	//2. text2num might not be enough. "15abc,6" should produce "15.6" (probably?)
	cur_power = max(text2num(signal), 0.2)
	cur_power = min(cur_power, 1)

/obj/item/mechcomp/led/proc/set_range(signal)
	cur_range = max(text2num(signal), 1)
	cur_range = min(cur_range, 10)

/obj/item/mechcomp/led/attach()
	if(!anchored)
		turn_off()

/obj/item/mechcomp/led/get_settings(var/source)
	var/dat = "<B>LED settings:</B><BR>"
	dat += "Set RGB : <A href='?src=\ref[source];led_action=set_rgb'>[cur_color]</A><BR>"
	dat += "Set power : <A href='?src=\ref[source];led_action=set_power'>[cur_power]</A><BR>"
	dat += "Set range : <A href='?src=\ref[source];led_action=set_range'>[cur_range]</A><BR>"

	return dat

/obj/item/mechcomp/led/set_settings(href, href_list, user)
	if(href_list["led_action"])
		switch(href_list["led_action"])
			if("set_rgb")
				var/r = input(user, "Red component(0-255)","Set color") as num
				r = max(r, 0)
				r = min(r, 255)
				var/g = input(user, "Green component(0-255)","Set color") as num
				g = max(g, 0)
				g = min(g, 255)
				var/b = input(user, "Blue component(0-255)","Set color") as num
				b = max(b, 0)
				b = min(b, 255)
				cur_color = uppertext(rgb(r, g, b))

			if("set_power")
				var/new_power = input(user, "Input a new power(0.2-1)", "Set power") as num
				set_power(new_power)

			if("set_range")
				var/new_range = input(user, "Input a new range(1-7)", "Set range") as num
				set_range(new_range)

		if(ready)
			turn_on(handler.trigger_signal)

		return MT_REFRESH