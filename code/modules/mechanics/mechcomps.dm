//TODO : maybe switch from custom-built signal to radio signals?

/*
=================
	MECHCOMPS
=================
This is a class for "holder" objects. You can attach it to pretty much any /obj by adding
a new variable and initializing it

Mechcomps have a number of "inputs" - i.e. "ports" which can receive special strings - "signals"
Mechomps also have one output with data

You should only attach one datum per class
*/

#define DEFAULT_SIGNAL "1"

/datum/mechcomp
	//Send signal is the string which is sent by the component
	//It might also contain data passed to other components
	var/send_signal = DEFAULT_SIGNAL
	//Trigger signal is the string to which the component MIGHT react.
	var/trigger_signal = DEFAULT_SIGNAL

	//Not all components can have inputs, so we can cut on memory consumption a teeny-tiny bit
	var/list/inputs = null
	//This list is needed so we can detach the component with no outputs properly.
	var/list/datum/mechcomp/incoming = new/list()
	var/list/datum/mechcomp/outgoing = new/list()

	// max_outputs<0 = unlimited number of outputs (probably a REALLY bad idea)
	var/max_outputs = 5

	//If accept is true(e.g. 1) then the mechomp can receive additional connections
	var/accept = 1

	//The master object - the physical component
	//Limiting to obj. Humans and stuff probably shouldn't be components
	var/obj/master = null

/datum/mechcomp/New(var/atom/new_master)
	master = new_master
	//Should this part be visible to everyone? If not, I'll have to think about a better solution"
	master.desc += "\nComponent ID: \ref[master]"
	//The settings are controlled by a multitool extension
	//See code\datums\extensions\multitool\items\mechcomps.dm
	set_extension(master, /datum/extension/interactive/multitool, /datum/extension/interactive/multitool/items/mechcomp)
	..()

//This function is used to bind an input (string) to a function controlling said input
/datum/mechcomp/proc/add_input(input_name as text, func_name as text)
	// Lazy initialization? Why not.
	if(inputs == null)
		inputs = new/list()
	inputs[input_name] = func_name

//Adds an outgoing connection
//Terrible name
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

//Removes an outgoing connection
/datum/mechcomp/proc/remove_output(datum/mechcomp/what)
	outgoing.Remove(what)

//Sends a signal
/datum/mechcomp/proc/send_signal(signal = send_signal)
	if(outgoing.len > 0)
		for(var/datum/mechcomp/receiver in outgoing)
			receiver.receive_signal(signal, outgoing[receiver])

//Called when a signal is received
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

#undef DEFAULT_SIGNAL