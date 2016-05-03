/datum/event/rogue_drone
	endWhen = 1000
	var/list/drones_list = list()

/datum/event/rogue_drone/start()
	//spawn them at the same place as carp
	var/list/possible_spawns = list()
	for(var/obj/effect/landmark/C in landmarks_list)
		if(C.name == "carpspawn")
			possible_spawns.Add(C)

	//25% chance for this to be a false alarm
	var/num
	if(prob(25))
		num = 0
	else
		num = rand(2,6)
	for(var/i=0, i<num, i++)
		var/mob/living/simple_animal/hostile/retaliate/malf_drone/D = new(get_turf(pick(possible_spawns)))
		drones_list.Add(D)
		if(prob(25))
			D.disabled = rand(15, 60)

/datum/event/rogue_drone/announce()
	var/msg
	if(prob(33))
		msg = " рыло боевых дронов с корабл&#255; NVD Icarus не смогло вернутьс&#255; на базу из этого сектора. ≈сли таковые будут замечены - отнеситесь с осторожностью."
	else if(prob(50))
		msg = "ѕотер&#255;н контакт с крылом дронов корабл&#255; NVD Icarus. ≈сли таковые будут замечены - отнеситесь с осторожностью."
	else
		msg = "Ќеизвестные хакеры навели крыло боевых дронов с корабл&#255; NVD Icarus на станцию. ≈сли таковые будут замечены - отнеситесь с осторожностью."
	command_announcement.Announce(msg, "”гроза боевых дронов")

/datum/event/rogue_drone/end()
	var/num_recovered = 0
	for(var/mob/living/simple_animal/hostile/retaliate/malf_drone/D in drones_list)
		var/datum/effect/effect/system/spark_spread/sparks = new /datum/effect/effect/system/spark_spread()
		sparks.set_up(3, 0, D.loc)
		sparks.start()
		D.z = using_map.admin_levels[1]
		D.has_loot = 0

		qdel(D)
		num_recovered++

	if(num_recovered > drones_list.len * 0.75)
		command_announcement.Announce("ƒатчики дронов NVD Icarus сообщают, что крыло неисправных дронов было безопасно возвращено.", "”гроза боевых дронов")
	else
		command_announcement.Announce("ƒатчики дронов NVD Icarus сообщают, что часть дронов была потер&#255;на, но оставшиес&#255; были безопасно возвращены", "”гроза боевых дронов")
