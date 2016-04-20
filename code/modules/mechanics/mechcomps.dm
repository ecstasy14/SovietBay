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
	//This list is needed so we can detach the component with no outputs properly.
	var/list/datum/mechcomp/incoming = new/list()
	var/list/datum/mechcomp/outgoing = new/list()

	// max_outputs<0 = unlimited number of outputs (probably a REALLY bad idea)
	var/max_outputs = 5

	var/atom/master = null

/datum/mechcomp/New(var/atom/new_master)
	master = new_master
	//Should this part be visible to everyone? If not, I'll have to think about a better solution"
	master.desc += "\nComponent ID: \ref[master]"
	set_extension(master, /datum/extension/multitool, /datum/extension/multitool/items/mechcomp)
	..()

/datum/mechcomp/proc/add_input(input_name as text, func_name as text)
	// Lazy initialization? Why not.
	if(inputs == null)
		inputs = new/list()
	inputs[input_name] = func_name

/datum/mechcomp/proc/add_output(var/datum/mechcomp/what, to_input)
	var/added = 0
	if(outgoing.Find(what))
		if(outgoing[what] != to_input)
			outgoing[what] = to_input
		added = 1
	else if(max_outputs < 0 || outgoing.len + 1 <= max_outputs)
		outgoing.Add(what)
		outgoing[what] = to_input
		what.incoming.Add(src)
		added = 1

	return added

/datum/mechcomp/proc/remove_output(datum/mechcomp/what)
	outgoing.Remove(what)

/datum/mechcomp/proc/send_signal(signal = send_signal)
	if(outgoing.len > 0)
		for(var/datum/mechcomp/receiver in outgoing)
			receiver.receive_signal(signal, outgoing[receiver])

/datum/mechcomp/proc/receive_signal(signal, input_name)
	spawn(1) call(master, inputs[input_name])(signal)

/datum/mechcomp/proc/disconnect()
	if(incoming.len > 0)
		for(var/datum/mechcomp/receiver in incoming)
			receiver.remove_output(src)
	incoming.Cut()
	outgoing.Cut()

//Useless for now
/*
//Honestly taken from goons' code. That's a nice thing they didn't use
/datum/mechcomp/proc/isSignalTrue(var/signal) //Thanks for not having bools , byond.
	if(istext(signal))
		if(lowertext(signal) == "true" || lowertext(signal) == "1" || lowertext(signal) == "one") return 1
	else if (isnum(signal))
		if(signal == 1) return 1
	return 0
*/