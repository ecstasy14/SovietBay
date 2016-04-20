/obj/item/mechcomp/orcomp
	name = "\improper OR component"
	desc = "'To be OR not to be' - always true."

	icon_state = "comp_or"

/obj/item/mechcomp/orcomp/New()
	..()
	handler.add_input("input 1", "fire")
	handler.add_input("input 2", "fire")
	handler.add_input("input 3", "fire")
	handler.add_input("input 4", "fire")
	handler.add_input("input 5", "fire")
	handler.add_input("input 6", "fire")
	handler.add_input("input 7", "fire")
	handler.add_input("input 8", "fire")
	handler.add_input("input 9", "fire")
	handler.add_input("input 10", "fire")

/obj/item/mechcomp/orcomp/proc/fire(signal)
	if(signal == handler.trigger_signal)
		handler.send_signal()