/obj/item/mechcomp/pressure
	name = "pressure sensor"
	desc = "Tread lightly..."

	icon_state = "comp_pressure"

/obj/item/mechcomp/pressure/Crossed(var/atom/movable/what as mob|obj)
	if(isghost(what))
		return
	if(!ready)
		return

	handler.send_signal()

	ready = 0
	//Fair enough?
	spawn(20)
		ready = 1