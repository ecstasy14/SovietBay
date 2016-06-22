/obj/item/mechcomp/andcomp
	name = "\improper AND gate"
	desc = "It only lets couples through."

	icon_state = "comp_and"

	var/time_frame = 30
	var/list/inputs = new/list(null, null)
	var/logical = 0


/obj/item/mechcomp/andcomp/New()
	..()
	handler.add_input("input 1", "input1")
	handler.add_input("input 2", "input2")

/obj/item/mechcomp/andcomp/proc/set_input(num as num, signal)
	inputs[num] = signal
	//Don't know how to do this right, really
	var/opposite
	if(num == 2)
		opposite = 1
	else
		opposite = 2

	if(inputs[opposite])
		var/pass = 1
		if(logical)
			if(inputs[num] != inputs[opposite])
				pass = 0

		if(pass)
			handler.send_signal()

	spawn(time_frame)
		inputs[num] = null

/obj/item/mechcomp/andcomp/proc/input1(var/signal)
	set_input(1, signal)

/obj/item/mechcomp/andcomp/proc/input2(var/signal)
	set_input(2, signal)

/obj/item/mechcomp/andcomp/attach()
	..()
	if(!anchored)
		inputs[1] = null
		inputs[2] = null


/obj/item/mechcomp/andcomp/get_settings(var/source)
	var/dat = "<B>AND gate settings:</B><BR>"
	dat += "Set the timeframe : <A href='?src=\ref[source];and_action=set_frame'>[time_frame]</A><BR>"
	dat += "Is boolean : <A href='?src=\ref[source];and_action=set_bool'>[logical ? "true" : "false"]</A><BR>"
	return dat

/obj/item/mechcomp/andcomp/set_settings(href, href_list, user)
	if(href_list["and_action"])
		switch(href_list["and_action"])
			if("set_bool")
				logical = !logical
			if("set_frame")
				time_frame = input(user, "Enter a new timeframe(10-100)", "Set timeframe") as num
				time_frame = max(time_frame, 10)
				time_frame = min(time_frame, 100)
		return MT_REFRESH