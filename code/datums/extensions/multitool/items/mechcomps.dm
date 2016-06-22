/datum/extension/interactive/multitool/items/mechcomp/get_interact_window(var/obj/item/device/multitool/M, var/mob/user)
	var/found = 0
	var/c = 1
	while(c != holder.vars.len + 1)
		if(istype(holder.vars[ holder.vars[c] ], /datum/mechcomp))
			found = c
			c = holder.vars.len
		c++

	if(!found)
		return

	var/datum/mechcomp/mechcomp = holder.vars[holder.vars[found]]

	if(!mechcomp.master.allowed(user))
		user << "<span class='warning'>\The [mechcomp.master] is locked!</span>"
		return

	. += "<B>[holder] - Component ID: \ref[holder]</B><HR>"

	. += "Send signal: <A href='?src=\ref[src];change=send;mechcomp=[found]'>[mechcomp.send_signal]</A><BR>"
	. += "Trigger signal: <A href='?src=\ref[src];change=trigger;mechcomp=[found]'>[mechcomp.trigger_signal]</A><BR>"

	if(mechcomp.inputs)
		. += "<HR>Inputs : <BR>"
		for (var/input_name in mechcomp.inputs)
			. += "<B>[input_name]</B><BR>"

	if(mechcomp.outgoing.len > 0)
		. += "<HR>"
		. += "Outputs:"
		for (var/datum/mechcomp/output in mechcomp.outgoing)
			. += "<B>[output.master.name]</B> - Component ID: <B>\ref[output]</B> on input <B>[mechcomp.outgoing[output]]</B><BR>"

	//Snowflake code. It's either this or tons of verbs for each component. I prefer this
	if(istype(holder, /obj/item/mechcomp))
		var/obj/item/mechcomp/snowflake = holder
		var/settings = snowflake.get_settings(src)
		if(settings != 0)
			. += "<HR>"
			. += settings

/datum/extension/interactive/multitool/items/mechcomp/on_topic(href, href_list, user)
	var/datum/mechcomp/mechcomp

	//Yes, that's a scary construction
	if(href_list["mechcomp"])
		mechcomp = holder.vars[ holder.vars[ text2num( href_list["mechcomp"] ) ] ]
	//Terrible hacky snowflake code
	else if(istype(holder, /obj/item/mechcomp))
		mechcomp = holder.vars["handler"]

	if(!mechcomp)
		return MT_CLOSE

	if(href_list["change"])
		var/new_signal = sanitize(input(user, "What signal do you want to use?", "[ capitalize( href_list["change"] ) ] signal") as text)
		if(length(new_signal) == 0)
			new_signal = "1"

		if(href_list["change"] == "send")
			mechcomp.send_signal = new_signal
		else
			mechcomp.trigger_signal = new_signal

		return MT_REFRESH

	//Snowflake code. It's either this or tons of verbs for each component. I prefer this
	if(istype(holder, /obj/item/mechcomp))
		var/obj/item/mechcomp/snowflake = holder
		return snowflake.set_settings(href, href_list, user)

	return ..()