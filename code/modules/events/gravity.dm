/datum/event/gravity
	announceWhen = 5

/datum/event/gravity/setup()
	endWhen = rand(15, 60)

/datum/event/gravity/announce()
	command_announcement.Announce("Обнаружен откат масс в системе генерации массы. Искуственна&#255; гравитаци&#255; была отключена всв&#255;зи с перезапуском системы. Дальнейшие ошибки могут привести к гравитационному коллапсу и возникновению черных дыр.", "Отказ гравитации")

/datum/event/gravity/start()
	gravity_is_on = 0
	for(var/area/A in world)
		if(A.z in using_map.station_levels)
			A.gravitychange(gravity_is_on, A)

/datum/event/gravity/end()
	if(!gravity_is_on)
		gravity_is_on = 1

		for(var/area/A in world)
			if(A.z in using_map.station_levels)
				A.gravitychange(gravity_is_on, A)

		command_announcement.Announce("Гравитационные генераторы вновь функционируют в нормальном режиме. Извините за неудобства.", "Восстановление гравитации")
