//Differs from the goons version in order too keep the behaviour consistent with the teleporter
/obj/item/mechcomp/graviton
	name = "graviton launcher"
	desc = "'Ere we go!"

	icon_state = "comp_accel"

	var/range = 5

/obj/item/mechcomp/graviton/New()
	..()
	handler.add_input("activate","activate")
	handler.max_outputs = 0

/obj/item/mechcomp/graviton/proc/activate(signal)
	if(signal != handler.trigger_signal)
		return
	if(!ready)
		return

	var/atom/target = get_edge_target_turf(src, dir)
	flick(icon_state+"_active", src)
	ready = 0
	spawn(100)
		ready = 1
	//Currently, the launcher launches EVERYTHING that's standing on it
	//Should I change this?
	for(var/atom/movable/what in loc)
		if(!what.anchored)
			//Should I remove the HILARIOUS spinning animation?
			spawn (0) what.throw_at(target, range, 1)

/obj/item/mechcomp/graviton/attack_self(mob/user as mob)
	set_dir(turn(dir, -90))

/obj/item/mechcomp/graviton/get_settings(source)
	var/dat = "<B>Graviton launcher settings:</B><BR>"
	dat += "Range : <A href='?src=\ref[source];launcher_action=set_range'>[range]</A><BR>"
	return dat

/obj/item/mechcomp/graviton/set_settings(href, href_list, user)
	if(href_list["launcher_action"])
		switch(href_list["launcher_action"])
			if("set_range")
				range = input(user, "Enter new range(1-10)", "Set range") as num
				range = max(range, 1)
				range = max(range, 10)

		return MT_REFRESH