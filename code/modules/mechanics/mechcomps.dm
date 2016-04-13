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
	var/max_outputs = 0

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

/datum/mechcomp/proc/sendSignal()
	if(outputs.len > 0)
		for(var/datum/mechcomp/receiver in outputs)
			receiver.receiveSignal(send_signal, outputs[receiver])

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

	//Can't find a better way, so we'll have to go with goons
	//Anything that uses/is a mechcomp must have a variable named mechcomp.
	//That's the most effecient and simple way I see right now
	//We can also search for an instance of /datum/mechcomp
	//But it's needed in a couple of places, so we have to use quite a few loops PER COMPONENT
	var/datum/mechcomp/mechcomp

/obj/item/mechcomp/New()
	mechcomp = new/datum/mechcomp(src)
	..()

//Not the best name for a proc used for both attaching and detaching
/obj/item/mechcomp/proc/attach()
	return

/obj/item/mechcomp/attackby(var/obj/item/weapon/W as obj, var/mob/user as mob)
	if(istype(W, /obj/item/weapon/wrench) && isturf(src.loc))
		playsound(src.loc, 'sound/items/Ratchet.ogg', 50, 1)
		//Sounds dumb. Need a better string.
		user << "<span class='notice'>You [anchored ? "detach" : "attach"] \the [src] [anchored ? "from" : "to"] the floor.</span>"
		anchored = !anchored
		if(!anchored)
			mechcomp.disconnect()

		attach()

/obj/item/mechcomp/attack_hand(var/mob/user)
	if(anchored)
		user << "<span class='warning'>\The [src.name] is attached to the floor!</span>"
		return
	return ..()

/obj/item/mechcomp/MouseDrop(var/atom/target)
	if(!target)
		return

	if(!target.vars.Find("mechcomp") && !istype(target.vars.Find("mechcomp"), /datum/mechcomp))
		return

	var/datum/mechcomp/target_mechcomp = target.vars["mechcomp"]

	if(!anchored)
		return

	var/list/actions = new/list()

	if(mechcomp.max_outputs != 0 && mechcomp.outputs.len != mechcomp.max_outputs && target_mechcomp.inputs)
		actions += "Output to"

	if(mechcomp.inputs)
		actions += "Input from"

	actions += "*CANCEL*"

	var/intention = input("How do you want to use \the [src]:",
				"Connection", "*CANCEL*") in actions
	switch(intention)
		if("Output to")
			intention = input("What input do you want to use?", "Connection", "*CANCEL*") in target_mechcomp.inputs+"*CANCEL*"
			if(intention == "*CANCEL*")
				return
			mechcomp.addOutput(target_mechcomp, intention)
		if("Input from")
			intention = input("What input do you want to use?", "Connection", "*CANCEL*") in mechcomp.inputs+"*CANCEL*"
			if(intention == "*CANCEL*")
				return
			target_mechcomp.addOutput(mechcomp, intention)
		else
			return


/*
		The button
*/
/obj/item/mechcomp/button
	name = "button"
	desc = "A normal button. Dare to press it?"
	icon_state = "comp_button"

/obj/item/mechcomp/button/New()
	..()
	mechcomp.max_outputs = 1

/obj/item/mechcomp/button/attach()
	density = !density

/obj/item/mechcomp/button/attack_hand(var/mob/user)
	if(anchored)
		flick("comp_button_active", src)
		mechcomp.sendSignal()
	else
		..()


/*
	The teleporter
*/
/obj/item/mechcomp/teleporter
	name = "teleporter"
	desc = "Beam me up, Scotty!"

	icon_state = "comp_tele"

	var/static/list/teleporters = new/list()

	var/ready = 1

	var/id = "tele1"

//can't replicate the goons effect with the current codebase :(
/obj/effect/teleparticle
	name = "teleport"
	icon = 'icons/obj/mechComps.dmi'
	icon_state = "portal"

/obj/effect/teleparticle/New(var/new_loc)
	loc = new_loc
	spawn(18) qdel(src)


/obj/item/mechcomp/teleporter/New()
	..()
	mechcomp.addInput("activate", "activate")
	mechcomp.addInput("setID", "setID")
	teleporters.Add(src)

/obj/item/mechcomp/teleporter/proc/activate(var/signal)
	//anchored test just in case for now
	if(signal != mechcomp.trigger_signal) return
	if(!anchored || !ready) return

	var/list/destinations = new/list()
	for (var/obj/item/mechcomp/teleporter/T in teleporters)
		if((T.id == id) && (T != src) && (T.anchored))
			destinations.Add(T)

	if(destinations.len)
		ready = 0
		spawn(100) ready = 1
		new /obj/effect/teleparticle(src.loc)
		//Right now, the teleporter teleports everything currently on the pad to random pads
		//1.Should it be just 1 thing at a time?
		//2.If not, should all the items teleport to 1 pad?
		for(var/atom/movable/what in src.loc)
			if(!what.anchored)
				var/obj/item/mechcomp/teleporter/destination = pick(destinations)
				what.x = destination.x
				what.y = destination.y
				what.z = destination.z

/obj/item/mechcomp/teleporter/proc/setID(var/signal)
	id = signal

/obj/item/mechcomp/teleporter/Del()
	teleporters.Remove(src)
	..()

/*
/obj/item/mechcomp/teleporter/Crossed(var/atom/movable/what)
	..()

	if(what.anchored)
		return

	if(active && ready)
		var/list/destinations = new/list()
		for (var/obj/item/mechcomp/teleporter/T in teleporters)
			if((T.id == id) && (T != src) && (T.anchored))
				destinations.Add(T)

		if(destinations.len)
			ready = 0
			spawn(50) ready = 1
			var/obj/item/mechcomp/teleporter/destination = pick(destinations)
			what.x = destination.x
			what.y = destination.y
			what.z = destination.z	//Yes, z-level teleportation. OP?
*/