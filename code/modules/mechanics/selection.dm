/obj/item/mechcomp/selectcomp
	name = "selection component"
	desc = "Gotta store them all!"

	icon_state = "comp_selector"

	var/list/buffer = new/list()

	var/current_index = 1
	var/announce = 0

/obj/item/mechcomp/selectcomp/New()
	..()
	handler.addInput("add item", "additem")
	handler.addInput("remove item", "remitem")
	handler.addInput("clear", "clear")
	handler.addInput("select item", "selitem")
	handler.addInput("next", "next")
	handler.addInput("previous", "previous")
	handler.addInput("send selected", "sendCurrent")
	handler.addInput("send random", "sendRand")
	handler.addInput("iterate", "iterate")

/obj/item/mechcomp/selectcomp/proc/additem(var/signal)
	if(buffer.len + 1 > 10)
		return
	buffer.Add(signal)
	if(announce)
		for(var/mob/who in hearers(src, null))
			who.show_message("<span class='game say'><span class='name'>\The [src]</span> [pick("bleeps","beeps", "screeches")], \"Added [signal].\"</span>",2)

/obj/item/mechcomp/selectcomp/proc/remitem(var/signal)
	if(buffer.Find(signal))
		buffer.Remove(signal)
		if(current_index > buffer.len)
			current_index = buffer.len

	if(announce)
		for(var/mob/who in hearers(src, null))
			who.show_message("<span class='game say'><span class='name'>\The [src]</span> [pick("bleeps","beeps", "screeches")], \"Removed [signal].\"</span>",2)

/obj/item/mechcomp/selectcomp/proc/selitem(var/signal)
	var/found = buffer.Find(signal)
	if(found)
		current_index =found

	if(announce)
		for(var/mob/who in hearers(src, null))
			who.show_message("<span class='game say'><span class='name'>\The [src]</span> [pick("bleeps","beeps", "screeches")], \"Current Selection : [buffer[current_index]].\"</span>",2)

/obj/item/mechcomp/selectcomp/proc/clear(var/signal)
	if(signal != handler.trigger_signal)
		return

	if(announce)
		for(var/mob/who in hearers(src, null))
			who.show_message("<span class='game say'><span class='name'>\The [src]</span> [pick("bleeps","beeps", "screeches")], \"Cleared the selection.\"</span>",2)

/obj/item/mechcomp/selectcomp/proc/sendCurrent(var/signal)
	if(signal != handler.trigger_signal)
		return

	if(current_index > buffer.len)
		current_index = buffer.len

	handler.sendSignal(buffer[current_index])

/obj/item/mechcomp/selectcomp/proc/sendRand(var/signal)
	if(signal != handler.trigger_signal)
		return
	handler.sendSignal(pick(buffer))

/obj/item/mechcomp/selectcomp/proc/next(var/signal)
	if(signal != handler.trigger_signal)
		return
	if(!buffer.len)
		return

	if((current_index + 1) > buffer.len)
		current_index = 1
	else
		current_index++

	if(announce)
		for(var/mob/who in hearers(src, null))
			who.show_message("<span class='game say'><span class='name'>\The [src]</span> [pick("bleeps","beeps", "screeches")], \"New selection : [buffer[current_index]].\"</span>",2)

/obj/item/mechcomp/selectcomp/proc/previous(var/signal)
	if(signal != handler.trigger_signal)
		return
	if((current_index - 1) < 1)
		current_index = buffer.len
	else
		current_index--

	if(announce)
		for(var/mob/who in hearers(src, null))
			who.show_message("<span class='game say'><span class='name'>\The [src]</span> [pick("bleeps","beeps", "screeches")], \"New selection : [buffer[current_index]].\"</span>",2)

/obj/item/mechcomp/selectcomp/get_settings(var/source)
	var/dat = "<B>Selection component settings:</B><BR>"
	dat += "Announce actions : <A href='?src=\ref[source];select_action=set_announce'>[announce ? "true" : "false"]</A><BR>"
	dat += "<HR>"
	dat += "<B>Current buffer:</B><BR>"
	for(var/c = 1 to buffer.len)
		dat += "[buffer[c]]<BR>"
	if(buffer.len)
		if(buffer.len != 10)
			dat += "<A href='?src=\ref[source];select_action=add'>Add a new item</A><BR>"
		dat += "<A href='?src=\ref[source];select_action=remove'>Remove the topmost item</A><BR>"
	return dat

/obj/item/mechcomp/selectcomp/set_settings(href, href_list, user)
	if(href_list["select_action"])
		switch(href_list["select_action"])
			if("set_announce")
				announce = !announce
			if("add")
				if(buffer.len != 10)
					var/new_item = sanitize(input(user, "Enter a new item:", "New item"))
					additem(new_item)
			if("remove")
				if(buffer.len > 0)
					//Seems like this is a normal thing
					buffer.len--

		return MT_REFRESH