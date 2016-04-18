//TODO : make it preeeety. replace camelCase with underscores

//TODO : test everything

//TODO : switch from custom-built signal to radio signals, I totally forgot about them
//But I really want to finish these components so the current system stays

//TODO : Document everything

/*
You can attach this datum to nearly anything, then wire it up nearly seamlessly into the whole system

You should only attach one datum per class
*/
/datum/mechcomp
	var/send_signal = "1"
	var/trigger_signal = "1"

	//Not all components can have inputs, so we can cut on memory consumption a teeny-tiny bit
	var/list/inputs = null
	var/list/datum/mechcomp/outputs = new/list()

	// max_outputs<0 = unlimited number of outputs (probably a REALLY bad idea)
	var/max_outputs = 5

	var/atom/master = null

/datum/mechcomp/New(var/atom/new_master)
	master = new_master
	//Should this part be visible to everyone? If not, I'll have to think about a better solution"
	master.desc += "\nComponent ID: \ref[master]"
	set_extension(master, /datum/extension/multitool, /datum/extension/multitool/items/mechcomp)
	..()

/datum/mechcomp/proc/addInput(var/input_name, var/func_name)
	// Lazy initialization? Why not.
	if(inputs == null)
		inputs = new/list()
	inputs[input_name] = func_name

/datum/mechcomp/proc/addOutput(var/datum/mechcomp/what, var/to_input)
	var/added = 0
	if(outputs.Find(what))
		if(outputs[what] == null || outputs[what] != to_input)
			outputs[what]=to_input
		added = 1
	else if(max_outputs < 0 || outputs.len + 1 <= max_outputs)
		outputs.Add(what)
		outputs[what]=to_input
		added = 1

	return added

/datum/mechcomp/proc/removeOutput(var/datum/mechcomp/what)
	outputs.Remove(what)

//Honestly taken from goons' code. That's a nice thing they didn't use
/datum/mechcomp/proc/isSignalTrue(var/signal) //Thanks for not having bools , byond.
	if(istext(signal))
		if(lowertext(signal) == "true" || lowertext(signal) == "1" || lowertext(signal) == "one") return 1
	else if (isnum(signal))
		if(signal == 1) return 1
	return 0

/datum/mechcomp/proc/sendSignal(new_signal)
	if(outputs.len > 0)
		var/send = send_signal
		if(new_signal != null)
			send = new_signal
		for(var/datum/mechcomp/receiver in outputs)
			receiver.receiveSignal(send, outputs[receiver])

/datum/mechcomp/proc/receiveSignal(var/signal, var/input_name)
	spawn(1) call(master, inputs[input_name])(signal)

/datum/mechcomp/proc/disconnect()
	outputs.Cut()

/*
	The base class
*/
/obj/item/mechcomp
	name = "MechComp"
	desc = "If you're reading this, then something's broken!"
	w_class = 3

	icon = 'icons/obj/mechComps.dmi'

	anchored = 0
	density = 0

	var/send_signal = "1"

	var/datum/mechcomp/handler

	var/above = 0

	var/orig_icon

	var/ready = 1

/obj/item/mechcomp/New()
	handler = new/datum/mechcomp(src)
	orig_icon = icon_state
	..()

/obj/item/mechcomp/update_icon()
	icon_state = orig_icon
	if(!above)
		var/turf/T = get_turf(src)
		if(!istype(T))
			return
		if(!T.is_plating())
			icon_state = "u_"+icon_state

/obj/item/mechcomp/hide(var/intact)
	update_icon()

//Not the best name for a proc used for both attaching and detaching
/obj/item/mechcomp/proc/attach()
	return

/obj/item/mechcomp/attackby(var/obj/item/weapon/W as obj, var/mob/user as mob)
	if(istype(W, /obj/item/weapon/wrench) && isturf(src.loc))
		playsound(src.loc, 'sound/items/Ratchet.ogg', 50, 1)
		if(anchored)
			var/turf/T = get_turf(src)
			if(!above && !T.is_plating())
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

/obj/item/mechcomp/attack_hand(var/mob/user)
	if(anchored)
		return
	return ..()

/obj/item/mechcomp/MouseDrop(var/atom/target)
	var/mob/living/user = usr
	var/obj/item/MT = user.get_active_hand()
	if(!istype(MT, /obj/item/device/multitool))
		usr << "<span class='warning'>You need to hold a multitool to connect the components!</span>"
		return

	if(!target)
		return

	var/found = 0
	var/c = 1
	while(c != target.vars.len + 1)
		if(istype(target.vars[ target.vars[c] ], /datum/mechcomp))
			found = c
			c = target.vars.len
		c++

	if(!found || !istype(target.vars[ target.vars[found] ], /datum/mechcomp))
		return

	var/datum/mechcomp/target_handler = target.vars[target.vars[found]]

	if(!anchored)
		return

	var/list/actions = new/list()

	if(handler.max_outputs != 0 && handler.outputs.len != handler.max_outputs && target_handler.inputs)
		actions += "Output to"

	if(handler.inputs && target_handler.outputs.len != target_handler.max_outputs)
		actions += "Input from"

	actions += "*CANCEL*"

	var/intention = input("How do you want to use \the [src]:",
				"Connection", "*CANCEL*") in actions
	switch(intention)
		if("Output to")
			intention = input("What input do you want to use?", "Connection", "*CANCEL*") in target_handler.inputs+"*CANCEL*"
			if(intention == "*CANCEL*")
				return
			handler.addOutput(target_handler, intention)
		if("Input from")
			intention = input("What input do you want to use?", "Connection", "*CANCEL*") in handler.inputs+"*CANCEL*"
			if(intention == "*CANCEL*")
				return
			target_handler.addOutput(handler, intention)
		else
			return

//This function must be overloaded if you want the component to have settings
//Must return the string containing the HTML window or 0 if no settings are available
//Also, try to make the hrefs unique
//Also, use the source variable in hrefs instead of src. That is to ensure that the game uses the extension's Topic()
/obj/item/mechcomp/proc/get_settings(var/source)
	return 0

//This function must be overloaded if you want the component to have settings
//This function MUST be overloaded if the value returned by get_settings() has any 'href's
//Return values (taken from /code/datums/extensions/multitool/_multitool.dm):
//MT_NOACTION - do nothing
//MT_REFRESH - referesh the window
//MT_CLOSE - close the window
/obj/item/mechcomp/proc/set_settings(href, href_list, user)
	return MT_NOACTION