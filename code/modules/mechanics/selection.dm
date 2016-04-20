/obj/item/mechcomp/selectcomp
	name = "selection component"
	desc = "Gotta store them all!"

	icon_state = "comp_selector"

	var/list/buffer = new/list()

	var/current_index = 1
	var/announce = 0

/obj/item/mechcomp/selectcomp/New()
	..()
	handler.add_input("add item", "additem")
	handler.add_input("remove item", "remitem")
	handler.add_input("clear", "clear")
	handler.add_input("select item", "selitem")
	handler.add_input("next", "next")
	handler.add_input("previous", "previous")
	handler.add_input("send selected", "send_current")
	handler.add_input("send random", "send_rand")
	handler.add_input("iterate", "iterate")

/obj/item/mechcomp/selectcomp/proc/additem(signal)
	if(buffer.len + 1 > 10)
		return
	buffer.Add(signal)
	if(announce)
		/*
		for(var/mob/who in hearers(src, null))
			who.show_message("<span class='game say'><span class='name'>\The [src]</span> [pick("bleeps","beeps", "screeches")], \"Added [signal].\"</span>",2)
		*/
		compSay("Added [signal].")

/obj/item/mechcomp/selectcomp/proc/remitem(signal)
	if(buffer.Find(signal))
		buffer.Remove(signal)
		if(current_index > buffer.len)
			current_index = buffer.len

	if(announce)
	/*
		for(var/mob/who in hearers(src, null))
			who.show_message("<span class='game say'><span class='name'>\The [src]</span> [pick("bleeps","beeps", "screeches")], \"Removed [signal].\"</span>",2)
	*/
		compSay("Removed [signal].")

/obj/item/mechcomp/selectcomp/proc/selitem(signal)
	var/found = buffer.Find(signal)
	if(found)
		current_index =found

	if(announce)
		/*
		for(var/mob/who in hearers(src, null))
			who.show_message("<span class='game say'><span class='name'>\The [src]</span> [pick("bleeps","beeps", "screeches")], \"Current Selection : [buffer[current_index]].\"</span>",2)
		*/
		compSay("Current Selection : [buffer[current_index]].")

/obj/item/mechcomp/selectcomp/proc/clear(signal)
	if(signal != handler.trigger_signal)
		return

	if(announce)
	/*
		for(var/mob/who in hearers(src, null))
			who.show_message("<span class='game say'><span class='name'>\The [src]</span> [pick("bleeps","beeps", "screeches")], \"Cleared the selection.\"</span>",2)
	*/
		compSay("Cleared the buffer.")

/obj/item/mechcomp/selectcomp/proc/send_current(signal)
	if(signal != handler.trigger_signal)
		return

	if(current_index > buffer.len)
		current_index = buffer.len

	handler.send_signal(buffer[current_index])

	if(announce)
		compSay("Sent [buffer[current_index]].")

/obj/item/mechcomp/selectcomp/proc/send_rand(signal)
	if(signal != handler.trigger_signal)
		return
	var/sent = pick(buffer)
	handler.send_signal(sent)

	if(announce)
		compSay("Sent a random item : [sent].")

/obj/item/mechcomp/selectcomp/proc/next(signal)
	if(signal != handler.trigger_signal)
		return
	if(!buffer.len)
		return

	if((current_index + 1) > buffer.len)
		current_index = 1
	else
		current_index++

	if(announce)
	/*
		for(var/mob/who in hearers(src, null))
			who.show_message("<span class='game say'><span class='name'>\The [src]</span> [pick("bleeps","beeps", "screeches")], \"New selection : [buffer[current_index]].\"</span>",2)
	*/
		compSay("New selection : [buffer[current_index]].")

/obj/item/mechcomp/selectcomp/proc/iterate(signal)
	if(signal != handler.trigger_signal)
		return
	if(!buffer.len)
		return

	if(announce)
		compSay("Iterating...")

	for(var/c = 1 to buffer.len)
		handler.send_signal(buffer[c])

/obj/item/mechcomp/selectcomp/proc/previous(signal)
	if(signal != handler.trigger_signal)
		return
	if((current_index - 1) < 1)
		current_index = buffer.len
	else
		current_index--

	if(announce)
		/*
		for(var/mob/who in hearers(src, null))
			who.show_message("<span class='game say'><span class='name'>\The [src]</span> [pick("bleeps","beeps", "screeches")], \"New selection : [buffer[current_index]].\"</span>",2)
		*/
		compSay("New selection : [buffer[current_index]].")

/obj/item/mechcomp/selectcomp/get_settings(source)
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
				//10 is max. Enough?
				if(buffer.len != 10)
					var/new_item = inputText(user, "Enter a new item:", "New item")
					additem(new_item)
			if("remove")
				if(buffer.len > 0)
					//Seems like this is a normal thing
					buffer.len--

		return MT_REFRESH