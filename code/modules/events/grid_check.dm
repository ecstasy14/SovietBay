/datum/event/grid_check	//NOTE: Times are measured in master controller ticks!
	announceWhen		= 5

/datum/event/grid_check/start()
	power_failure(0, severity, using_map.contact_levels)

/datum/event/grid_check/announce()
	command_announcement.Announce("Аномальна&#255; активность в электросети [station_name()]. В качестве меры предосторожности, питание станции будет отключено на неопределенный срок.", "Автоматическа&#255; проверка сети", new_sound = 'sound/AI/poweroff.ogg')

