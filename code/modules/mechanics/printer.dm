/obj/item/mechcomp/printer
	name = "printer component"
	desc = "Sadly, it doesn't print money."

	icon_state = "comp_tprint"

	place_flags = MECH_PLACE_WALL | MECH_PLACE_ABOVE

	var/paper_title = ""

/obj/item/mechcomp/printer/New()
	..()
	handler.add_input("set title", "set_title")
	handler.add_input("print", "print")
	handler.max_outputs = 0

/obj/item/mechcomp/printer/proc/set_title(signal)
	paper_title = sanitize(signal)

/obj/item/mechcomp/printer/proc/print(signal)
	if(!ready)
		return

	ready = 0
	spawn(30)
		ready = 1

	var/obj/item/weapon/paper/doc = new/obj/item/weapon/paper(loc)
	doc.info = signal
	doc.name = (paper_title == "" ? "paper" : paper_title)

	flick(icon_state + "_active", src)

/obj/item/mechcomp/printer/get_settings(var/source)
	var/dat = "<B>Printer settings:</B><BR>"
	dat += "Title : <A href='?src=\ref[source];printer_action=set_title'>[length(paper_title) == 0 ? " " : paper_title]</A><BR>"
	return dat

/obj/item/mechcomp/printer/set_settings(href, href_list, user)
	if(href_list["printer_action"])
		switch(href_list["printer_action"])
			if("set_title")
				paper_title = inputText(user, "Enter a new title:", "Set title")

		return MT_REFRESH