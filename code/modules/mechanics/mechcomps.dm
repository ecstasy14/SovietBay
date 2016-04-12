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

	var/sendSignal = "1"

	var/list/obj/item/mechcomp/inputConnections = null
	var/list/inputFuncs = null
	var/list/obj/item/mechcomp/outputs = new/list()

	// max_outputs<0 = unlimited number of outputs (a REALLY bad idea)
	var/max_outputs = 0

/obj/item/mechcomp/proc/addInput(var/inputName, var/funcName)
	// Lazy initialization?
	// Not all components have inputs, and this function is supposed to work once per input,
	// so the checks are not that expensive
	if(inputFuncs == null)
		inputFuncs = new/list()
	if(inputConnections == null)
		inputConnections = new/list()
	inputFuncs[inputName] = funcName
	inputConnections[inputName] = null

/obj/item/mechcomp/proc/addOutput(var/obj/item/mechcomp/what)
	if(max_outputs < 0 || outputs.len + 1 <= max_outputs && !outputs.Find(what))
		outputs.Add(what)
		return 1
	return 0

/obj/item/mechcomp/proc/removeOutput(var/obj/item/mechcomp/what)
	if(max_outputs > 0 && outputs.Find(what))
		outputs.Remove(what)

//Honestly taken from goons' code. That's a nice thing they didn't use
/obj/item/mechcomp/proc/isSignalTrue(var/signal) //Thanks for not having bools , byond.
	if(istext(signal))
		if(lowertext(signal) == "true" || lowertext(signal) == "1" || lowertext(signal) == "one") return 1
	else if (isnum(signal))
		if(signal == 1) return 1
	return 0

/obj/item/mechcomp/proc/sendSignal()
	if(outputs.len > 0)
		for(var/obj/item/mechcomp/receiver in outputs)
			receiver.receiveSignal(sendSignal, src)

/obj/item/mechcomp/proc/receiveSignal(var/signal,var/obj/item/mechcomp/sender)
	//Shouldn't be possible, but still a failsafe for debugging is nice
	if(inputConnections.len > 0)
		//Important, one output can be connected to a couple of inputs on the same component
		for(var/inputName in inputConnections)
			if(inputConnections[inputName] == sender)
				spawn(1) call(src, inputFuncs[inputName])(signal)

//Not the best name for a proc used for both attaching and detaching
/obj/item/mechcomp/proc/attach()
	return

/obj/item/mechcomp/proc/reset()
	sendSignal = "1"
	return

/obj/item/mechcomp/attackby(var/obj/item/weapon/W as obj, var/mob/user as mob)
	if(istype(W, /obj/item/weapon/wrench) && isturf(src.loc))
		playsound(src.loc, 'sound/items/Ratchet.ogg', 50, 1)
		//Sounds dumb. Need a better string.
		user << "<span class='notice'>You [anchored ? "detach" : "attach"] \the [src] [anchored ? "from" : "to"] the floor.</span>"
		anchored = !anchored
		if(!anchored)
			//Awful. Can't find a better solution right now though
			//Find out if the machine outputs to anything
			for(var/obj/item/mechcomp/what in outputs)
				//Remove the references to the machine
				for(var/inputName in what.inputConnections)
					if(what.inputConnections[inputName] == src)
						what.inputConnections[inputName] = null
			outputs.Cut()

			//Find out if the machine gets an input from somewhere
			if(inputConnections)
				var/obj/item/mechcomp/remove_from
				for(var/input_name in inputConnections)
					remove_from = inputConnections[input_name]
					if(remove_from)
						remove_from.removeOutput(src)
						inputConnections[input_name] = null

		attach()

/*
	if(istype(W, /obj/item/device/multitool))
		var/obj/item/device/multitool/MT = W
		//Another stupid message. Should replace this one aswell
		var/intention = input("What do you want to do with \the [src]?",
					"Connection", "*CANCEL*") in list("input","output","purge","*CANCEL*")
		switch(intention)
			if("output")
				MT.set_buffer(src)
				user << "<span class='notice'>Successfully copied the connection into the buffer.</span>"
			if("input")
				intention = input("Which input do you want to use?", "Connection") in inputs
				if(istype(MT.buffer_object, /obj/item/mechcomp/))
					var/obj/item/mechcomp/target = MT.buffer_object
					if(intention)
						if(target.addOutput(src))
							inputs[intention] = MT.buffer_object
							user << "<span class='notice'>Successfully copied the connection from the buffer.</span>"
			else ..()
*/



/obj/item/mechcomp/attack_hand(var/mob/user)
	if(anchored)
		user << "<span class='warning'>\The [src.name] is attached to the floor!</span>"
		return
	return ..()


/*
		The button
*/
/obj/item/mechcomp/button
	name = "button"
	desc = "A normal button. Dare to press it?"
	icon_state = "comp_button"
	max_outputs = 1

/obj/item/mechcomp/button/attach()
	density = !density

/obj/item/mechcomp/button/attack_hand(var/mob/user)
	if(anchored)
		flick("comp_button_active", src)
		sendSignal()
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

	var/active = 0
	var/ready = 1

	var/id = "tele1"

/obj/item/mechcomp/teleporter/New()
	..()
	addInput("activate", "activate")
	addInput("setID", "setID")
	teleporters.Add(src)

/obj/item/mechcomp/teleporter/proc/activate(var/signal)
	active = isSignalTrue(signal)

/obj/item/mechcomp/teleporter/proc/setID(var/signal)
	id = signal

/obj/item/mechcomp/teleporter/Del()
	..()
	teleporters.Remove(src)

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