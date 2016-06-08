/datum/event/dust
	startWhen	= 10
	endWhen		= 30

/datum/event/dust/announce()
	command_announcement.Announce("¬ насто&#255;щее врем&#255; станци&#255; проходит через зону выского скоплени&#255; космической пыли.", " осмическа&#255; пыль")

/datum/event/dust/start()
	dust_swarm(get_severity())

/datum/event/dust/end()
	command_announcement.Announce("«она высокого скоплени&#255; космической пыли пройдена.", " осмическа&#255; пыль")

/datum/event/dust/proc/get_severity()
	switch(severity)
		if(EVENT_LEVEL_MUNDANE)
			return "weak"
		if(EVENT_LEVEL_MODERATE)
			return prob(80) ? "norm" : "strong"
		if(EVENT_LEVEL_MAJOR)
			return "super"
	return "weak"
