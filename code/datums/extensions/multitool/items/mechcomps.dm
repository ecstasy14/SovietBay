/datum/extension/multitool/items/mechcomp/get_interact_window(var/obj/item/device/multitool/M, var/mob/user)
	//var/obj/component = holder

	if(!holder.vars.Find("mechcomp"))
		return

	var/datum/mechcomp/mechcomp = holder.vars["mechcomp"]

	. += "<B>[holder] - Component ID: \ref[holder]</B><HR>"

	. += "Send signal: <A href='src=\ref[src];change=send>[mechcomp.send_signal]</A><BR>"

	. += "Trigger signal: <A href='src=\ref[src];change=trigger>[mechcomp.trigger_signal]</A><BR>"

	if(mechcomp.inputs)
		. += "<HR>Inputs : <BR>"
		for (var/input_name in mechcomp.inputs)
			. += "<B>[input_name]</B><BR>"

	if(mechcomp.outputs.len > 0)
		. += "<HR>"
		. += "Outputs:"
		for (var/outputName in mechcomp.outputs)
			. += "[outputName] - Component ID: <B>\ref[holder]</B> on input <B>[mechcomp.outputs[outputName]]</B><BR>"

/datum/extension/multitool/items/mechcomp/on_topic(href, href_list, user)
	//var/obj/item/mechcomp/component = holder

	var/datum/mechcomp/mechcomp = holder.vars["mechcomp"]

	if(href_list["change"])
		var/new_signal = sanitize(input(user, "What signal do you want to use?","[href_list["change"]] Signal") as text|null)
		if(length(new_signal) != 0)
			if(href_list["change"] == "send")
				mechcomp.send_signal = new_signal
			else
				mechcomp.trigger_signal = new_signal
			return MT_REFRESH

	return ..()