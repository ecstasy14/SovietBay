#define IS_MODE_COMPILED(MODE) (ispath(text2path("/datum/game_mode/"+(MODE))))
var/datum/antagonist/vampire/vamp

/proc/isvampire(var/mob/player)
	if(!vamp || !player.mind)
		return 0
	if(player.mind in vamp.current_antagonists)
		return 1

/datum/antagonist/vampire
	id = MODE_VAMPIRE
	//role_type = BE_VAMPIRE
	role_text = "Vampire"
	role_text_plural = "Vampires"
	bantype = "vampires"
	feedback_tag = "vampire_objective"
	restricted_jobs = list("AI", "Cyborg", "Chaplain")
	protected_jobs = list("Security Officer", "Warden", "Detective", "Head of Security", "Captain")
	//restricted_species = list("Machine")
	welcome_text = "You are a Vampire! Use harm intent and aim for the head to drink blood! Stay away from the Chaplain, and use the darkness to your advantage."
	flags = ANTAG_SUSPICIOUS | ANTAG_RANDSPAWN | ANTAG_VOTABLE
	antaghud_indicator = "hudchangeling" //NEEDS TO BE CHANGED

/datum/antagonist/vampire/update_antag_mob(var/datum/mind/player)
		..()
		player.current.make_vampire()


//datum/antagonist/vampire/get_special_objective_text(var/datum/mind/player)
//	return "<br><b>Changeling ID:</b> [player.changeling.changelingID].<br><b>Genomes Absorbed:</b> [player.changeling.absorbedcount]"

/datum/antagonist/vampire/update_antag_mob(var/datum/mind/player)
	..()
	player.current.make_vampire()

/datum/antagonist/vampire/create_objectives(var/datum/mind/vampire)
	if(!..())
		return

	var/datum/objective/absorb_drink/absorb_objective = new
	absorb_objective.owner = vampire
	absorb_objective.gen_amount_goal(200, 400)
	vampire.objectives += absorb_objective

	var/datum/objective/assassinate/kill_objective = new
	kill_objective.owner = vampire
	kill_objective.find_target()
	vampire.objectives += kill_objective

	var/datum/objective/steal/steal_objective = new
	steal_objective.owner = vampire
	steal_objective.find_target()
	vampire.objectives += steal_objective

	switch(rand(1,100))
		if(1 to 80)
			if (!(locate(/datum/objective/escape) in vampire.objectives))
				var/datum/objective/escape/escape_objective = new
				escape_objective.owner = vampire
				vampire.objectives += escape_objective
		else
			if (!(locate(/datum/objective/survive) in vampire.objectives))
				var/datum/objective/survive/survive_objective = new
				survive_objective.owner = vampire
				vampire.objectives += survive_objective
	return

/datum/antagonist/vampire/can_become_antag(var/datum/mind/player, var/ignore_role)
	if(..())
		if(player.current)
			if(ishuman(player.current))
				var/mob/living/carbon/human/H = player.current
				if(H.isSynthetic())
					return 0
				if(H.species.flags & NO_SCAN)
					return 0
				return 1
			else if(isnewplayer(player.current))
				if(player.current.client && player.current.client.prefs)
					var/datum/species/S = all_species[player.current.client.prefs.species]
					if(S && (S.flags & NO_SCAN))
						return 0
					if(player.current.client.prefs.organ_data["torso"] == "cyborg") // Full synthetic.
						return 0
					return 1
 	return 0