//Differs from the goons version in order too keep the behaviour consistent with the teleporter
/obj/item/mechcomp/graviton
	name = "graviton launcher"
	desc = "'Ere we go!"

	icon_state = "comp_accel"

	var/range = 5
	//Kinda haphazard but meh
	var/cooldown = 50
	var/maxrange = 10

/obj/item/mechcomp/graviton/New()
	..()
	handler.add_input("activate","activate")
	handler.max_outputs = 0

/obj/item/mechcomp/graviton/attack_self(mob/user as mob)
	set_dir(turn(dir, -90))

/obj/item/mechcomp/graviton/proc/fling(var/atom/target)
	//Currently, the launcher launches EVERYTHING that's standing on it
	//Should I change this?
	for(var/atom/movable/what in loc)
		if(!what.anchored)
			//Should I remove the HILARIOUS spinning animation?
			spawn (0) what.throw_at(target, range, 1)

/obj/item/mechcomp/graviton/proc/activate(signal)
	if(signal != handler.trigger_signal)
		return
	if(!ready)
		return
	var/atom/target = get_edge_target_turf(src, dir)
	flick(icon_state+"_active", src)
	ready = 0
	spawn(cooldown)
		ready = 1
	fling(target)

/obj/item/mechcomp/graviton/get_settings(source)
	var/dat = "<B>Graviton launcher settings:</B><BR>"
	dat += "Range : <A href='?src=\ref[source];launcher_action=set_range'>[range]</A><BR>"
	return dat

/obj/item/mechcomp/graviton/set_settings(href, href_list, user)
	if(href_list["launcher_action"])
		switch(href_list["launcher_action"])
			if("set_range")
				range = input(user, "Enter new range(1-[maxrange])", "Set range") as num
				range = max(range, 1)
				range = min(range, maxrange)
		return MT_REFRESH



//Bad design, but I kinda want this thing
/obj/item/mechcomp/graviton/advanced
	name = "advanced graviton launcher"
	desc = "Gravity ain't got nothing!"

	icon_state = "comp_advaccel"

	maxrange = 20
	cooldown = 120

/obj/item/mechcomp/graviton/advanced/fling(var/atom/target)
	for(var/atom/movable/what in loc)
		if(!what.anchored || istype(what, /obj/mecha))
			spawn (0) what.throw_at(target, range, 1)