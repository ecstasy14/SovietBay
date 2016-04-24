//TODO : Waht about adding an ability to rename the components using a pen?

/*
	The base class
*/
/obj/item/mechcomp
	name = "MechComp"
	desc = "If you're reading this, then something's totally broken!"
	w_class = 3

	icon = 'icons/obj/mechComps.dmi'
	icon_state = "comp_unk"

	anchored = 0
	density = 0

	var/ready = 1

	var/datum/mechcomp/handler

	var/place_flags = 0

	var/orig_icon

/obj/item/mechcomp/New()
	handler = new/datum/mechcomp(src)
	orig_icon = icon_state
	..()

/obj/item/mechcomp/update_icon()
	icon_state = orig_icon
	if(!(place_flags & MECH_PLACE_ABOVE))
		var/turf/T = get_turf(src)
		if(!istype(T))
			return
		if(!T.is_plating())
			icon_state = "u_"+icon_state

/obj/item/mechcomp/hide(intact)
	update_icon()

/obj/item/mechcomp/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(istype(W, /obj/item/weapon/wrench) && isturf(src.loc))
		playsound(src.loc, 'sound/items/Ratchet.ogg', 50, 1)
		if(anchored)
			var/turf/T = get_turf(src)
			if(!(place_flags & MECH_PLACE_ABOVE) && !T.is_plating())
				user << "<span class='warning'>You must remove the plating first!</span>"
				return
			handler.disconnect()
			icon_state = orig_icon
		else
			hide()

		attach()

		//Sounds dumb. Need a better string.
		user << "<span class='notice'>You [anchored ? "detach" : "attach"] \the [src] [anchored ? "from" : "to"] \the [loc].</span>"
		anchored = !anchored


/obj/item/mechcomp/afterattack(atom/target as turf, mob/user as mob)
	if(place_flags & MECH_PLACE_WALL)
		if(get_dist(src, target) == 1)
			if(isturf(target) && target.density)
				user.drop_item()
				src.loc = target
				anchored = 1

/obj/item/mechcomp/attack_hand(mob/user as mob)
	if(anchored)
		return
	return ..()

/obj/item/mechcomp/MouseDrop(var/atom/target)
	if(!anchored)
		return
	if(!target)
		return

	var/mob/living/user = usr
	var/obj/item/MT = user.get_active_hand()
	if(!istype(MT, /obj/item/device/multitool))
		usr << "<span class='warning'>You need to hold a multitool to connect the components!</span>"
		return

	//The only hacky way I can think of
	var/found = 0
	var/c = 1
	while(c != target.vars.len + 1)
		if(istype(target.vars[ target.vars[c] ], /datum/mechcomp))
			found = c
			c = target.vars.len
		c++

	if(!found)
		return

	var/datum/mechcomp/target_handler = target.vars[target.vars[found]]

	var/list/actions = new/list()

	if(handler.max_outputs != 0 && handler.outgoing.len != handler.max_outputs && target_handler.inputs)
		actions += "Output to"

	if(handler.inputs && target_handler.outgoing.len != target_handler.max_outputs)
		actions += "Input from"

	actions += "*CANCEL*"

	var/intention = input("How do you want to use \the [src]:",
				"Connection", "*CANCEL*") in actions
	switch(intention)
		if("Output to")
			intention = input("Which input do you want to use?", "Connection", "*CANCEL*") in target_handler.inputs+"*CANCEL*"
			if(intention == "*CANCEL*")
				return
			handler.add_output(target_handler, intention)
		if("Input from")
			intention = input("Which input do you want to use?", "Connection", "*CANCEL*") in handler.inputs+"*CANCEL*"
			if(intention == "*CANCEL*")
				return
			target_handler.add_output(handler, intention)
		else
			return

//Not the best name for a proc used for both attaching AND detaching
/obj/item/mechcomp/proc/attach()
	return

//This function must be overloaded if you want the component to have settings
//Must return the string containing the HTML window or 0 if no settings are available
//Also, try to make the hrefs unique
//Also, use the source variable in hrefs instead of src. That is to ensure that the game uses the extension's Topic()
/obj/item/mechcomp/proc/get_settings(source)
	return 0

//This function must be overloaded if you want the component to have settings
//This function MUST be overloaded if the value returned by get_settings() has any 'href's
//Return values (taken from /code/datums/extensions/multitool/_multitool.dm):
//MT_NOACTION - do nothing
//MT_REFRESH - referesh the window
//MT_CLOSE - close the window
/obj/item/mechcomp/proc/set_settings(href, href_list, user)
	return MT_NOACTION

/obj/item/mechcomp/proc/inputText(mob/user as mob, title as text, prompt as text, default_value = "" as text)
	var/ret = sanitize(input(user, prompt, title) as text, encode = 0)
	if(length(ret) == 0)
		ret = default_value

	return ret

/obj/item/mechcomp/proc/compSay(message)
	for(var/mob/who in hearers(src, null))
		who.show_message("<span class='game say'><span class='name'>\The [src]</span> [pick("bleeps","beeps", "screeches")], \"[message]\"</span>",2)
