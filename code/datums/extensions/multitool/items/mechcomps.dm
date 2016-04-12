/obj/item/mechcomp/New()
	set_extension(src, /datum/extension/multitool, /datum/extension/multitool/items/mechcomp)
	..()

/datum/extension/multitool/items/mechcomp/get_interact_window(var/obj/item/device/multitool/M, var/mob/user)
	var/obj/item/mechcomp/component = holder
	. += "<B>[component]</B>"
	if(component.inputConnections)
		. += "<HR>Inputs : <BR>"
		for (var/input_name in component.inputConnections)
			var/shown = component.inputConnections[input_name]
			if(shown == null)
				shown = "null"
			. += "[input_name] = <A href='?src=\ref[src];input=[input_name];MT=\ref[M]'>[shown]</A>"
			. += "<A href='?src=\ref[src];purgeInput=[input_name]'>Remove</A><BR>"
	if(component.outputs.len > 0)
		. += "<HR>"
		. += "Outputs:"
		for (var/outputName in component.outputs)
			. += "[outputName]<BR>"
	. += "<HR>"
	. += "<A href='?src=\ref[src];store=true;MT=\ref[M]'>Store the component.</A><BR>"
	. += buffer(M)

/datum/extension/multitool/items/mechcomp/on_topic(href, href_list, user)
	var/obj/item/mechcomp/component = holder
	//Sounds like a bad idea, but I can't find any other way to pass the multitool in
	var/obj/item/device/multitool/MT = locate(href_list["MT"])
	if(href_list["input"])
		var/obj/item/mechcomp/buffer = MT.buffer_object
		if(buffer && buffer.addOutput(component))
			component.inputConnections[href_list["input"]] = buffer
			return MT_REFRESH

	if(href_list["purgeInput"])
		var/obj/item/mechcomp/input_machine = component.inputConnections[href_list["purgeInput"]]
		input_machine.removeOutput(component)
		component.inputConnections[href_list["purgeInput"]] = null
		return MT_REFRESH

	if(href_list["store"])
		MT.set_buffer(component)
		return MT_REFRESH

	return ..()