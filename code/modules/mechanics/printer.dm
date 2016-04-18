/obj/item/mechcomp/printer
	name = "printer component"
	desc = "Sadly, it doesn't print money."

	icon_state = "comp_tprint"

	above = 1

	var/paper_title = ""

/obj/item/mechcomp/printer/New()
	..()
	handler.addInput("set title", "set_title")
	handler.addInput("print", "print")
	handler.max_outputs = 0

/obj/item/mechcomp/printer/proc/set_title(var/signal)
	paper_title = sanitize(signal)

/obj/item/mechcomp/printer/proc/print(var/signal)
	if(!ready)
		return

	ready = 0
	spawn(30)
		ready = 1
	var/obj/item/weapon/paper/doc = new/obj/item/weapon/paper(loc)
	doc.info = signal
	doc.name = (paper_title == "" ? "paper" : paper_title)

	flick(icon_state + "_active", src)

/obj/item/mechcomp/printer/afterattack(atom/target as turf, mob/user as mob)
	if(get_dist(src, target) == 1)
		if(isturf(target) && target.density)
			user.drop_item()
			src.loc = target
			anchored = 1