
/proc/communications_blackout(var/silent = 1)

	if(!silent)
		command_announcement.Announce("Внимание. Станци&#255; входит в зону ионных возмущений. Св&#255;зь со спутником телекомуникаций временно недоступна. Св&#255;ж-пш-ш-ш-ш-ш-ш...", new_sound = 'sound/misc/interference.ogg')
	else // AIs will always know if there's a comm blackout, rogue AIs could then lie about comm blackouts in the future while they shutdown comms
		for(var/mob/living/silicon/ai/A in player_list)
			A << "<br>"
			A << "<span class='warning'><b>Станци&#255; входит в зону ионных возмущений. Св&#255;зь со спутником телекомуникаций временно недоступна. Св&#255;ж-пш-ш-ш-ш-ш-ш...</b></span>"
			A << "<br>"
	for(var/obj/machinery/telecomms/T in telecomms_list)
		T.emp_act(1)
