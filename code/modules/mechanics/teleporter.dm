/*
	The teleporter
*/
//can't replicate the goons effect with the current codebase :(
/obj/effect/teleparticle
	name = "teleport"
	icon = 'icons/obj/mechComps.dmi'
	icon_state = "portal"
	//Funny story about this one. The teleporter teleported the teleporter particle. Yeeeeeaaaaaah.
	anchored = 1

/obj/effect/teleparticle/New(new_loc)
	loc = new_loc
	spawn(14) qdel(src)


/obj/item/mechcomp/teleporter
	name = "teleporter"
	desc = "Beam me up, Scotty!"

	icon_state = "comp_tele"

	var/static/list/teleporters = new/list()

	var/id = "tele1"
	var/send_only = 0

/obj/item/mechcomp/teleporter/New()
	..()
	handler.add_input("activate", "activate")
	handler.add_input("setID", "setID")
	teleporters.Add(src)
	handler.max_outputs = 0

/obj/item/mechcomp/teleporter/proc/activate(signal)
	if(signal != handler.trigger_signal) return
	if(!anchored || !ready) return

	new /obj/effect/teleparticle(src.loc)
	flick(icon_state+"_active", src)
	ready = 0
	//1 minute. Sounds fair to me
	spawn(600) ready = 1

	var/list/destinations = new/list()
	for (var/obj/item/mechcomp/teleporter/T in teleporters)
		if((T != src) && (T.id == id) && (T.anchored) && (!T.send_only))
			destinations.Add(T)

	if(destinations.len)
		//Right now, the teleporter teleports everything currently on the pad to random pads
		//1.Should it be just 1 thing at a time?
		//2. What about 20 things at a time?
		//3.If not, should all the items teleport to 1 pad?
		for(var/atom/movable/what in src.loc)
			if(!what.anchored || istype(what, /obj/mecha))
				do_teleport(what, pick(destinations))

/obj/item/mechcomp/teleporter/proc/setID(signal)
	id = signal

/obj/item/mechcomp/teleporter/Del()
	teleporters.Remove(src)
	..()

/obj/item/mechcomp/teleporter/get_settings(source)
	var/dat = "<B>Teleporter settings:</B><BR>"
	dat += "Set ID : <A href='?src=\ref[source];teleporter_action=set_id'>[length(id) == 0 ? " " : id]</A><BR>"
	dat += "Send-only : <A href='?src=\ref[source];teleporter_action=send_only'>[send_only ? "true" : "false"]</A><BR>"

	return dat

/obj/item/mechcomp/teleporter/set_settings(href, href_list, user)
	if(href_list["teleporter_action"])
		switch(href_list["teleporter_action"])
			if("set_id")
				id = inputText(user, "What ID do you want to assign?", "Change ID")
			if("send_only")
				send_only = !send_only

		return MT_REFRESH

	return MT_NOACTION