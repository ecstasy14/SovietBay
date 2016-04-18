/obj/item/mechcomp/orcomp
	name = "\improper OR component"
	desc = "'To be OR not to be' - always true."

	icon_state = "comp_or"

/obj/item/mechcomp/orcomp/New()
	..()
	handler.addInput("input 1", "fire")
	handler.addInput("input 2", "fire")
	handler.addInput("input 3", "fire")
	handler.addInput("input 4", "fire")
	handler.addInput("input 5", "fire")
	handler.addInput("input 6", "fire")
	handler.addInput("input 7", "fire")
	handler.addInput("input 8", "fire")
	handler.addInput("input 9", "fire")
	handler.addInput("input 10", "fire")

/obj/item/mechcomp/orcomp/proc/fire(var/signal)
	if(signal == handler.trigger_signal)
		handler.sendSignal()