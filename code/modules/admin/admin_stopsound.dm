/client/proc/stop_sounds()
	set category = "Debug"
	set name = "Stop Sounds"
	if(!check_rights(R_SOUNDS)) return

	log_admin("[key_name(src)] stopped all currently playing sounds.")
	message_admins("[key_name_admin(src)] stopped all currently playing sounds.")
	for(var/mob/M in player_list)
		if(M.client)
			M << sound(null)

	feedback_add_details("admin_verb","PLS")