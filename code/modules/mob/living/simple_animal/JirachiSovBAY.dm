/mob/living/simple_animal/jirachi
	name = "Jirachi"
	real_name = "Jirachi"
	desc = "Small, white, humanoid creature, with short, stubby legs and comparatively longer arms."
	icon = 'icons/mob/jirachi.dmi'
	icon_state = "Jirachi"
	icon_living = "Jirachi"
	maxHealth = 80
	health = 80
	luminosity = 3	//Jirachi is glowing slightly
	wander = 0
	response_help = "hugs"
	response_disarm = "pokes"
	response_harm = "punches"
	harm_intent_damage = 15
	speed = 0
	universal_speak = 1
	universal_understand = 1
	unacidable = 1
	speed = -1 //You move faster, when you fly
	pass_flags = PASSTABLE
	mob_size = MOB_SMALL
	var/energy = 1000
	var/max_energy = 1000
	var/star_form = 0		//Is S-form enabled?
	var/processing = 0		//Is Jirachi processing somebody?
	var/list/startelelocs = list()		//Teleport locations
	var/list/telelocs = list()
	var/fixatedz = 50//Fixated Z-level
	heat_damage_per_tick = -10
	cold_damage_per_tick = 0
	min_oxy = 0
	max_oxy = 0
	min_tox = 0
	max_tox = 0
	min_co2 = 0
	max_co2 = 0
	min_n2 = 0
	max_n2 = 0
	minbodytemp = 0
	var/used_star
	var/used_forcewall		//Cooldowns
	var/used_psycho
	var/used_teleport
	var/used_steleport
	var/used_hypno
	var/used_shock



//////////// LIFE & DEATH ////////////

/mob/living/simple_animal/jirachi/New()
	..()
	if(!startelelocs.len)
		for(var/area/AR in world)
			if(istype(AR, /area/shuttle) || istype(AR, /area/syndicate_station) || istype(AR, /area/wizard_station)) continue
			if(startelelocs.Find(AR.name)) continue
			var/turf/picked = pick_area_turf(AR.type, list(/proc/is_station_turf))
			if (picked)
				startelelocs += AR.name
				startelelocs[AR.name] = AR
		startelelocs = sortAssoc(startelelocs)	//Jirachi has it's own list with locs

/mob/living/simple_animal/jirachi/Life()		//Jirachi loves fire!
	..()
	weakened = 0
	var/gain = 0
	if(energy < 0)
		energy = 0

	handle_hud_glasses(src)
	if(star_form == 1)
		process_med_hud(src)

	if(bodytemperature > 400)
		gain = bodytemperature - 400
		bodytemperature -= 200

	energy = min(energy + gain, max_energy)



/mob/living/simple_animal/jirachi/death()
	new /obj/effect/decal/cleanable/ash(src.loc)
	..(null,"starts burning with bright fire from inside, before turning into ashes")
	ghostize()
	qdel(src)



//////////// OTHER PROCS ////////////



/mob/living/simple_animal/jirachi/Allow_Spacemove(var/check_drift = 0)		//Move freely in space
	return 1



/mob/living/simple_animal/jirachi/attackby(var/obj/item/O as obj, var/mob/user as mob)
	if(O.force)
		var/damage = O.force
		if (O.damtype == HALLOSS || star_form == 1)
			damage = 0
		adjustBruteLoss(damage)
		if(star_form == 1)		visible_message("\red \b [user] tries to strike [src] with [O], but it shields itself from the attack!")
		else		visible_message("\red \b [src] has been attacked with [O] by [user].")
	else
		usr << "\red This weapon is ineffective, it does no damage."
		visible_message("\red [user] gently taps [src] with [O]. ")



/mob/living/simple_animal/jirachi/attack_generic(mob/living/M as mob)
	if(star_form == 1)		visible_message("\red <b>[M] tries to attack [src], but it deflects the attack!</b>")
	else
		..()



/mob/living/simple_animal/jirachi/hitby(atom/movable/AM as mob|obj)
	if(star_form == 1)		visible_message("\red [src] dodges [AM]!")
	else
		..()



/mob/living/simple_animal/jirachi/say(var/message, var/datum/language/speaking = null, var/verb="says", var/alt_name="", var/italics=0, var/message_range = world.view, var/list/used_radios = list())
	if(processing == 1)
		src << "\red I can't speak while healing, hibernating or hypnotizing..."
		return

	..(message, speaking, verb, alt_name, italics, message_range, used_radios)


/mob/living/simple_animal/jirachi/say_quote(var/text)
	var/ending = copytext(text, length(text))
	if (ending == "?")
		return "telepatically asks";
	else if (ending == "!")
		return "telepatically cries";

	return "telepatically says";



///////////HANDLING PROCS///////////



/mob/living/simple_animal/jirachi/proc/checkuse(var/energyrequired=0,var/cldwnvrbl=0,var/cooldown=0)
	if(processing == 1)
		src << "\red I can't use my abilities while healing, hibernating or hypnotizing!"
		return

	if(energy < energyrequired)
		src << "\red I don't have enough power..."
		return 0

	if(processing == 1)
		src << "\red I can't use any of my powers, until my hybernation ends."
		return 0

	if(round((world.time - cldwnvrbl)/10, 1)<=cooldown)
		src << "I am not ready. Wait for [(cooldown-round((world.time - cldwnvrbl)/10, 1))+1] seconds"
		return 0


	return 1

/mob/living/simple_animal/jirachi/update_sight()
	if(stat == DEAD)
		update_dead_sight()




///////////HOTKEYS///////////



//Blink



/mob/living/simple_animal/jirachi/MiddleClickOn(var/atom/O)		//Blink on middle mouse button
	if(!checkuse(100,used_steleport,5-6*star_form))		return

	if(buckled)		src.buckled.unbuckle_mob()//On my Jirachi event, I got buckled to the chair, and blink away from it. And then, shit happens

	var/turf/T=get_turf(O)

	if((T.density) || (is_blocked_turf(T)))
		src << "\red I can't teleport into solid matter."
		return

	if(get_dist(src, T) >= 8)		return

	var/datum/effect/effect/system/spark_spread/spark_system = new /datum/effect/effect/system/spark_spread()
	spark_system.set_up(5, 0, src.loc)
	spark_system.start()
	playsound(src.loc, 'sound/effects/sparks2.ogg', 50, 1)

	src.loc = T

	var/datum/effect/effect/system/spark_spread/spark = new /datum/effect/effect/system/spark_spread()
	spark.set_up(5,0, src.loc)
	spark.start()

	energy=max(energy-100,0)
	used_steleport = world.time



//Psystrike



/mob/living/simple_animal/jirachi/AltClickOn(var/atom/W)
	if(!W || !src || !istype(W,/mob/living/carbon/human))		 return
	if(!checkuse(150,used_psycho,30))		return

	if(get_dist(src, W) > 7 && star_form != 1)
		src << "Target moved too far away"
		return

	var/mob/living/carbon/human/M=W
	if((M.species.flags & NO_SCAN) && !(M.species.flags & IS_PLANT))
		src << "\red This creature ignores my attempt to influence it's mind"
		return

	visible_message("\red <b>[src] eyes flashes blue as [M] falls to the floor</b>")

	src << "\red I focus my mind on the [M] brain and send psychic wave to it."

	if(star_form == 0)
		M.Weaken(15)
		M << "\red Your legs become paralyzed for a moment, and you fall to the floor!"
	else		//In S-form it will be more painful...
		M.Weaken(30)
		M.adjustBrainLoss(30)
		M.eye_blurry += 30
		M << "\red <b>You feel powerful psychic impulse penetrating your brain!</b>"

	energy=max(energy-100,0)
	used_psycho = world.time



//Forcewall



/mob/living/simple_animal/jirachi/CtrlClickOn(var/atom/J)
	if(!checkuse(50,used_forcewall,30-31*star_form))		return

	var/obj/effect/forcefield/my_field = new /obj/machinery/shield(get_turf(J))
	my_field.name = "Forcewall"
	my_field.desc = "Wall consisting of pure energy"
	src << "\red I concentrated energy in my hands and shape a wall from it"
	energy=max(energy-50,0)
	used_forcewall = world.time
	spawn(300)		qdel(my_field)



//Teleport



/mob/living/simple_animal/jirachi/ShiftClickOn(var/mob/living/I as mob)
	if(!I || !src || !istype(I,/mob/living))		 return
	if(!checkuse(200,used_teleport,20))		return

	if(src.z != fixatedz && star_form == 0)
		telelocs.Cut()
		for(var/area/B)
			if(startelelocs.Find(B.name) && B.z == src.z)
				telelocs += B.name
		fixatedz=src.z
		telelocs = sortAssoc(telelocs)

	var/A
	if(star_form == 1)		A = input("Area to teleport to", "Teleport") in startelelocs
	else		A = input("Area to teleport to", "Teleport") in telelocs


	if(!checkuse(200,used_teleport,20))		return

	if(get_dist(src, I) > 7 && star_form != 1)
		src << "Target moved too far away from me"
		return

	var/area/thearea = startelelocs[A]
	if(!thearea)	return

	var/list/L = list()
	for(var/turf/T in get_area_turfs(thearea.type))
		L+=T

	if(!L || !L.len)
		usr << "\red I can not teleport there, for some reason..."
		return

	for(var/obj/mecha/Z)
		if(Z.occupant == I)
			Z.go_out()

	if(I.buckled)		I.buckled.unbuckle_mob()

	src.visible_message("\red [src]'s eyes starts to glow with the blue light...")

	for(var/mob/M in viewers(I, null))
		if ((M.client && !( M.blinded ) && (M != I)))
			M << "\red [I] wanishes in a cerulean flash!"

	if(I == src)		src << "\blue I transfer myself to the [A]"
	else
		src << "\blue I teleport [I] to the [A]"
		I << "\red Suddenly, you've been blinded with a flash of light!"
		flick("e_flash", I.flash_eyes)

	I.forceMove(pick(L))

	for(var/mob/M in viewers(I, null))
		if ((M.client && !( M.blinded ) && (M != I)))
			M << "\red [I] suddenly appears out of nowhere!"

	energy=max(energy-200,0)
	used_teleport = world.time



///////////VERBS///////////



//Forcewall



/mob/living/simple_animal/jirachi/verb/forcewall()
	set category = "Jirachi"
	set name = "Forcewall(50)"
	set desc = "Create a forcewall, that lasts for 30 seconds"

	if(!checkuse(50,used_forcewall,30-31*star_form))		return

	var/obj/effect/forcefield/my_field = new /obj/machinery/shield(loc)
	my_field.name = "Forcewall"
	my_field.desc = "Wall consisting of pure energy"
	src << "\red I concentrated energy in my hands and shape a wall from it"
	energy=max(energy-50,0)
	used_forcewall = world.time
	sleep(300)
	qdel(my_field)



//Psystrike



/mob/living/simple_animal/jirachi/verb/energyblast(mob/living/carbon/human/M as mob in oview())
	set category = "Jirachi"
	set name = "Psystrike(150)"
	set desc = "Stuns target"

	if(!checkuse(150,used_psycho,30))		return

	if(get_dist(src, M) > 7 && star_form != 1)
		src << "Target moved too far away"
		return

	if(!M || !src) return

	if((M.species.flags & NO_SCAN) && !(M.species.flags & IS_PLANT))
		src << "\red This creature ignores my attempt to influence it's mind"
		return

	visible_message("\red <b>[src] eyes flashes blue as [M] falls to the floor</b>")

	src << "\red I focus my mind on the [M] brain and send psychic wave to it."

	if(star_form == 0)
		M.Weaken(15)
		M << "\red Your legs become paralyzed for a moment, and you fall to the floor!"
	else		//In S-form it will be more painful...
		M.Weaken(30)
		M.adjustBrainLoss(30)
		M.eye_blurry += 30
		M << "\red <b>You feel powerful psychic impulse penetrating your brain!</b>"

	energy=max(energy-150,0)
	used_psycho=world.time



//Heal


/mob/living/simple_animal/jirachi/verb/heal()
	set category = "Jirachi"
	set name = "Heal(50/s)"
	set desc = "Heal wounds of selected target"

	var/list/choices = list()
	for(var/mob/living/C in view(1,src))
		if(C != src)
			if(!istype(C, /mob/living/carbon/brain))
				choices += C

	var/mob/living/Z = input(src,"Who do you wish to heal?") in null|choices
	if(!Z)
		src << "There is no creatures near me to heal"
		return

	if(!checkuse(50,0,0))		return

	if(get_dist(src, Z) > 1 )
		src << "Target moved too far away from me"
		return
	if(istype(Z, /mob/living/silicon) || istype(Z, /mob/living/carbon/human/machine))
		src << "\red For some reason, I can't heal that creature"
		return
	if(Z.stat == 2)
		src << "\red I can't heal dead creatures"
		return

	src << "\blue I put my hands on [Z] and let my energy flow through it's body."
	visible_message("\blue <i>[src] puts it's hands on [Z] and closes it's eyes...suddenly waves of white energy starts to envelop [Z] body! </i>")

	if(Z.faction != "cult")		Z << "\blue <b>You feel immense energy course through you body!</b>"
	else		Z << "\red \bold That power makes you burn from inside! Aaarrgh!!!"

	processing = 1

	var/X1 = src.loc
	var/X2 = Z.loc

	spawn while(1)
		if(processing == 0)
			return

		if(Z.stat == 2 || !Z in living_mob_list || !Z)
			src << "\red It...died..."
			processing = 0
			return

		if(X1 != src.loc || X2 != Z.loc)
			src << "<span class='warning'>Healing was interrupted, because [Z] moved away from me.</span>"
			processing = 0
			return

		if(istype(Z, /mob/living/carbon))
			if(istype(Z, /mob/living/carbon/human))
				var/mob/living/carbon/human/H = Z
				H.adjustToxLoss(-10 - 10*star_form)
				H.adjustOxyLoss(-10 - 10*star_form)
				H.adjustCloneLoss(-10 - 10*star_form)
				H.adjustBrainLoss(-10 - 10*star_form)
				for(var/obj/item/organ/external/O in H.organs)
					for(var/datum/wound/W in O.wounds)
						W.heal_damage(5+10*star_form, 1)
						if(W.damage == 0)		O.wounds -=W
					if(!O.wounds.len)
						O.rejuvenate()
						O.update_damages()
					H.update_body()

				if(H.health>=40)
					if(HUSK in H.mutations)
						H.mutations.Remove(HUSK)
						H << "\blue As the power channels through your damaged skin, it starts to regenerate..."
					if(H.jitteriness > 101)		H.jitteriness = 101
					H.reagents.clear_reagents()
					H.restore_blood()
					if(H.shock_stage > 0 || H.traumatic_shock > 0)
						H.shock_stage = 0
						H.traumatic_shock = 0
						H.next_pain_time = 0
						H << "\blue You feel energies going through your body, subsiding your pain"

					if(H.health>=60)
						var/obj/item/organ/external/head/h = H.organs_by_name["head"]
						if(h.disfigured != 0)
							h.disfigured = 0
							H << "\blue Waves of energy goes through your face, restoring it back to normal"

						for(var/obj/item/organ/I in H.internal_organs)
							if(I.damage != 0)
								I.damage = 0
								H << "\blue Sweet feeling fills your body, as your viscera regenerates"
							I.germ_level = 0
						H.radiation = 0

						if(H.health>=85)
							H.revive()
							H.restore_all_organs()
							H << "\blue <b>You feel much better!</b>"

				H.update_body()
				H.regenerate_icons()
				H.updatehealth()

			else if(istype(Z, /mob/living/carbon/alien))	//Aliens have different dam.system
				var/mob/living/carbon/alien/A = Z
				A.adjustOxyLoss(-10 - 10*star_form)
				A.adjustBruteLoss(-10 - 10*star_form)
				A.adjustFireLoss(-10 - 10*star_form)
				A.adjustCloneLoss(-10 - 10*star_form)


			else
				var/mob/living/carbon/E = Z
				E.adjustOxyLoss(-10 - 10*star_form)
				E.adjustBruteLoss(-10 - 10*star_form)
				E.adjustFireLoss(-10 - 10*star_form)
				E.adjustCloneLoss(-10 - 10*star_form)
				E.adjustToxLoss(-10 - 10*star_form)
				E.adjustBrainLoss(-10 - 10*star_form)




		else if(istype(Z, /mob/living/simple_animal))	//Constructs and faithlesses are dark creatures. What happens if we channel light energy through dark creature?
			var/mob/living/simple_animal/S = Z
			if(S.faction != "cult")
				S.health += 20+10*star_form
			else
				S.health -= 30-20*star_form


		if(src)
			energy=max(energy-50,0)
			if(energy<50)
				energy = 0
				processing = 0
				return

		if(Z.health >= Z.maxHealth)
			Z.health = Z.maxHealth
			Z.rejuvenate()
			src << "\blue I healed all wounds of that creature"
			processing = 0
			return


		sleep(15)


//Telepathy


/mob/living/simple_animal/jirachi/verb/telepathy(mob/living/E as mob in player_list)
	set category = "Jirachi"
	set name = "Telepathy"
	set desc = "Send telepathic message to anyone on the station"


	if(!checkuse())		return

	if(E.stat == 2 || istype(E, /mob/living/silicon))
		src << "\red I can't make a telepathic link with this mind for some reason"
		return


	var/msg = sanitize(input("Message:", "Telepathy") as text|null)

	if(msg)
		log_say("Telepathy: [key_name(src)]->[E.key] : [msg]")

		if(star_form == 0)
			E << "\blue <i>You hear a soft voice in your head...</i> \italic [msg]"
		else
			E << "\blue <b><i>You hear soft and powerful voice in your head...</i></b> \italic \bold [msg]"

		for(var/mob/observer/G in player_list)
			G << "\bold TELEPATHY([src] --> [E]): [msg]"

		src << {"\blue You project "[msg]" into [E] mind"}
	return


//Teleport


/mob/living/simple_animal/jirachi/verb/teleport()
	set category = "Jirachi"
	set name = "Teleportation(200)"
	set desc = "Teleport yourself or somebody near you to the any location"

	spawn(1)
		if(src.z != fixatedz && star_form==0)
			telelocs.Cut()
			for(var/area/B)
				if(startelelocs.Find(B.name) && B.z == src.z)
					telelocs += B.name
			fixatedz=src.z
			telelocs = sortAssoc(telelocs)

		if(!checkuse(200,used_teleport,20))		return

		var/mob/living/I

		if(star_form==0)
			var/list/choices = list()
			for(var/mob/living/C in view(7,src))		choices += C
			I = input(src,"Who do you wish to teleport?") in choices
		else		I = input(src,"Who do you wish to teleport?") in mob_list

		if(!I)		return

		var/A
		if(star_form == 1)		A = input("Area to teleport to", "Teleport") in startelelocs
		else		A = input("Area to teleport to", "Teleport") in telelocs

		if(!checkuse(200,used_teleport,20))		return

		if(get_dist(src, I) > 7 && star_form != 1)
			src << "Target moved too far away from me"
			return

		var/area/thearea = startelelocs[A]
		if(!thearea)	return

		var/list/L = list()
		for(var/turf/T in get_area_turfs(thearea.type))
			L+=T

		if(!L || !L.len)
			usr << "\red I can not teleport there, for some reason..."
			return

		for(var/obj/mecha/Z)
			if(Z.occupant == I)
				Z.go_out()

		if(I.buckled)		I.buckled.unbuckle_mob()

		src.visible_message("\red [src]'s eyes starts to glow with the blue light...")

		for(var/mob/M in viewers(I, null))
			if ((M.client && !( M.blinded ) && (M != I)))
				M << "\red [I] wanishes in a cerulean flash!"

		if(I == src)		src << "\blue I transfer myself to the [A]"
		else
			src << "\blue I teleport [I] to the [A]"
			I << "\red Suddenly, you've been blinded with a flash of light!"
			flick("e_flash", I.flash_eyes)

		I.forceMove(pick(L))

		for(var/mob/M in viewers(I, null))
			if ((M.client && !( M.blinded ) && (M != I)))
				M << "\red [I] suddenly appears out of nowhere!"

		energy=max(energy-200,0)
		used_teleport=world.time




//Hybernation


/mob/living/simple_animal/jirachi/verb/hibernate()
	set category = "Jirachi"
	set name = "Hibernation"
	set desc = "Hibernate to regain your health and energy"
	if(star_form == 1)
		src << "\red You can't hibernate while in Star Form!"
		return

	if(!checkuse())		return

	if(energy >= 1000 && health >=80)
		src << "\red I do not need to hibernate right now"
		return

	src << "\blue \bold I start hibernating, to regain my life and energy..."

	processing = 1
	src.icon_state = "Jirachi-Sleep"

	canmove=0
	ear_deaf = 1
	paralysis = 8000
	luminosity = 5
	spawn while(processing == 1)
		if(energy < 1000)
			energy += 10

		if(health < 80)
			health += 1

		if(energy >= max_energy)
			energy = max_energy


		if(health >= maxHealth)
			health = maxHealth

		if(health == maxHealth && energy == max_energy)
			src << "\blue I regained my life and energy and awoken from my sleep"
			ear_deaf = null
			paralysis = 0
			luminosity = 3
			icon_state = "Jirachi"
			dir = SOUTH
			processing = 0
			return

		sleep(10)


//Star Form

/mob/living/simple_animal/jirachi/verb/star()
	set category = "Jirachi"
	set name = "Star Form"
	set desc = "Enter your true form"

	if(!checkuse(1000,used_star,600))
		if(star_form !=1)
			return

	if(star_form == 0)
		if(alert("Are you sure that you want to enter your true form?",,"Yes","No") == "No")
			return

		if(!checkuse(1000,used_star,600))		return

		src << "\blue <i><b>Immense energy starts to flow inside my body, filling every inch of it, as it starts to transform. My True Eye opens, my powers amplifies. I entered Star Form. My powers are now at maximum level, but my energy depletes with time.</b></i>"
		star_form = 1	//Enhances it's other abilities
		sight |= (SEE_MOBS|SEE_OBJS|SEE_TURFS)
		see_in_dark = 8
		see_invisible = SEE_INVISIBLE_LEVEL_TWO	//X-RAY
		luminosity = 8		//Glows strongly while in Star Form
		response_harm   = "tries to punch"
		harm_intent_damage = 0
		verbs.Add(/mob/living/simple_animal/jirachi/proc/global_telepathy,/mob/living/simple_animal/jirachi/proc/shockwave, /mob/living/simple_animal/jirachi/proc/starlight)
		max_energy = 2000
		energy = max_energy
		icon_state = "Jirachi-Star"
		name = "Jirachi-S"	//Change it's sprite!

		for(var/mob/living/carbon/P in view(7,src))
			flick("e_flash", P.flash_eyes)
			P << "\red <b>Jirachi starts to glow very brightly!</b>"
	else
		if(star_form)
			src << "<b>Strange feeling of blindness covered me, as I closed my Third Eye. Energies calms inside me and I revert back to my orginal form.</b>"
			star_form = 0
			return


	for(energy, energy>0, energy -= 1)
		if(star_form == 0)
			energy += 1
			break
		sleep(1)

	if(energy <= 0)
		energy = 0
		star_form = 0
		src << "\red <b>I am too exhausted...I can't further maintain my true form, I almost ran out of energy...I revert back to my original form.</b>"

	max_energy = 1000
	energy = min(energy, max_energy)
	see_invisible = SEE_INVISIBLE_LIVING
	sight = null
	luminosity = 3
	response_harm   = "punches"
	harm_intent_damage = 15
	verbs -= /mob/living/simple_animal/jirachi/proc/global_telepathy
	verbs -= /mob/living/simple_animal/jirachi/proc/shockwave
	verbs -=/mob/living/simple_animal/jirachi/proc/starlight
	icon_state = "Jirachi"
	name = "Jirachi"
	used_star = world.time


//Hypnosis


/mob/living/simple_animal/jirachi/verb/hypnosis()
	set category = "Jirachi"
	set name = "Hypnosis(250)"
	set desc = "Hypnotize selected target cause it to fall asleep"

	if(!checkuse(250,used_hypno,15))		return

	var/list/choices = list()
	for(var/mob/living/carbon/human/C in view(1,src))
		choices += C

	var/mob/living/carbon/human/M = input(src,"Who do you wish to hypnotize?") in null|choices

	if(get_dist(src, M) > 1 )
		src << "\red There is no target"
		return

	if(M == null)
		src << "There is no creature near me to hypnotize"
		return
	if(M.stat != CONSCIOUS)
		src << "I can't hypnotize dead or sleeping creatures"
		return

	if((M.species.flags & NO_SCAN) && !(M.species.flags & IS_PLANT))
		src << "\red This creature ignores my attempt to hypnotize it"
		return

	if(star_form != 1)
		var/safety = M:eyecheck()
		if(safety >= 1)
			src << "I can't make a direct eye contact with that creature."
			return

	var/X1 = src.loc
	var/X2 = M.loc

	processing = 1

	if(star_form == 1)
		M.canmove = 0
		M.Stun(15)

	M.eye_blurry = 15

	src << "\red I look directly into the [M] eyes, hypnotizing it."
	M << "\red Jirachi gazes directly into your eyes. Sweet feeling fills your brain, as you start feeling very drowsy."
	var/i
	for(i=1; i<=12; i++)
		sleep (10)
		if(X1 != src.loc || X2 != M.loc)
			M.canmove = 1
			M.SetStunned(0)
			M.eye_blurry = 0
			src << "<span class='warning'>My eye contact with [M] was interrupted.</span>"
			M << "\blue My mind starts feel clear again, as my eye-contact with Jirachi was interrupted"
			used_hypno = world.time		//Only if hypnosis is interrupted
			processing = 0
			return

	M.canmove = 1
	M.Sleeping(300)
	M.eye_blurry = 0
	src << "\blue I finished hypnotizing this creature, it will be sleeping for approximately 5 minutes"
	processing = 0
	energy=max(energy-250,0)


//Global Telepathy


/mob/living/simple_animal/jirachi/proc/global_telepathy()
	set category = "Jirachi"
	set name = "Global Telepathy"
	set desc = "Send telepathic message to all organic creatures on the station."

	if(star_form == 0)
		src << "You can use that power only in Star Form!"
		return
	if(!checkuse())		return

	var/msg = sanitize(input("Message:", text("Enter the text you wish to appear to everyone:"))) as text

	if (!msg)
		return

	for(var/mob/living/P in world)
		if(istype(P, /mob/living/silicon))
			continue
		P << "\blue <b><i>You hear echoing, powerful voice in your head...</i></b> \italic \bold [msg]"
	for(var/mob/observer/G in player_list)
		G << "\bold GLOBAL TELEPATHY: [msg]"
	log_say("Global Telepathy: [key_name(usr)] : [msg]")
	src << {"\blue You project "[msg]" into mind of every living creature"}


/mob/living/simple_animal/jirachi/verb/showe()
	set category = "Jirachi"
	set name = "Show Energy Points"
	src << "\bold ENERGY: [energy]/[max_energy]"


//Resurrection


/mob/living/simple_animal/jirachi/proc/starlight()
	set category = "Jirachi"
	set name = "Starlight"
	set desc = "Use all of your power to revive selected target"

	if(star_form == 0)
		src << "You can use that power only in Star Form!"
		return

	if(processing == 1)
		src << "\red I can't use my abilities while healing, hibernating or hypnotizing! "
		return


	var/list/choices = list()
	for(var/mob/living/carbon/human/C in view(1,src))
		if(C.stat == 2)
			choices += C
	var/mob/living/carbon/human/M = input(src,"Who do you wish to revive?") in null|choices
	if(HUSK in M.mutations)
		src << "\red Even my power useless here..."	//I dont want it to revive changeling victims.
		return
	if((!M.ckey) || (!M.client))
		src << "\red There is no soul in that creature, so I can't revive it."
		return
	if((M.species.flags & NO_SCAN) && !(M.species.flags & IS_PLANT))
		src << "\red I can't revive that creature, for some reason..."
		return
	if(M == null || M.stat !=2)
		src << "There is no dead creatures near me"
		return
	if(health <= round((max_energy - energy)/10, 10))
		if(!stat && alert("My energy is too low to revive that creature, and thus I must use my own life to ressurect it. Do I want to sacrifice myself, but save this creature?",,"Yes","No") == "No")
			return
	src << "\blue \bold I start focusing all of my power and channel it through [M] body, as it start to breathe again..."
	M << "\blue <b>You suddenly feel great power channeling through your body, regenerating your vitals. Your heart beat again, your vision becomes clear, as you realized that you were revived and brig back again with the power of Jirachi!</b>"
	for(var/mob/Q in viewers(src, null))
		if((Q.client && !( Q.blinded ) && (Q != src)))
			Q << "\blue \bold [src] body starts to sparkle with energy. It then raises it's hands up into the air as blinding white light starts to shine upon [M] body. After a moment [M] stands up, alive..."
	M.revive()
	M.reagents.clear_reagents()
	M.restore_blood()
	M.jitteriness = 0
	M.eye_blurry +=20
	health -= round((max_energy - energy)/20,10)
	energy = 0


//Shockwave


/mob/living/simple_animal/jirachi/proc/shockwave()
	set category = "Jirachi"
	set name = "Light Shockwave(350)"
	set desc = "Release light energy to stun everybody around"

	if(!checkuse(350,used_shock,30))		return

	if(star_form == 0)
		src << "You can use that power only in Star Form!"
		return

	for(var/mob/living/M in oview(7,src))
		if(!M.lying)
			M.adjustFireLoss(35-5*get_dist(M,src))
			M.Weaken(27-2*get_dist(M, src))		//Stun time depends on distance
			M << "\red You have been knocked down from your feet!"

	var/list/atoms = list()
	if(isturf(src))
		atoms = view(src.loc,5)	//Everything in 5-tile radius from Jirachi...
	else
		atoms = oview(src.loc,5)

	for(var/atom/movable/A in atoms)
		if(A.anchored) continue
		spawn(0)
			var/iter = 6-get_dist(A, src)		//..will be scattered away from him!
			for(var/i=0 to iter)
				step_away(A,src)
				sleep(2)

	for(var/mob/K in viewers(src, null))
		if((K.client && !( K.blinded )))
			K << "\red <b>[src] claps with it's hands, creating powerful shockwave!</b>"

	energy=max(energy-350,0)
	used_shock = world.time



//It deflects projectiles while in S-form
/mob/living/simple_animal/jirachi/bullet_act(var/obj/item/projectile/P)
	if(istype(P, /obj/item/projectile))
		if(star_form == 1)
			visible_message("<span class='danger'>[src] shields itself from the [P.name]!</span>", \
							"<span class='userdanger'>[src] shields itself from the [P.name]!</span>")
			var/new_x = P.starting.x + pick(0, 0, -1, 1, -2, 2, -2, 2, -2, 2, -3, 3, -3, 3)
			var/new_y = P.starting.y + pick(0, 0, -1, 1, -2, 2, -2, 2, -2, 2, -3, 3, -3, 3)
			var/turf/curloc = get_turf(src)

					// redirect the projectile
			P.original = locate(new_x, new_y, P.z)
			P.loc = get_turf(src)
			P.starting = curloc
			P.current = curloc
			P.firer = src
			P.shot_from = src
			P.yo = new_y - curloc.y
			P.xo = new_x - curloc.x

			return -1

	return (..(P))



/mob/living/simple_animal/jirachi/Stat()
	..()

	statpanel("Status")
	if (client.statpanel == "Status")
		if(istype(src,/mob/living/simple_animal/jirachi))
			stat(null, "Energy: [energy]/[max_energy]")
	if(emergency_shuttle)
		var/eta_status = emergency_shuttle.get_status_panel_eta()
		if(eta_status)
			stat(null, eta_status)



////////////////////////////////////////ARTIFACT////////////////////////////////////////



/obj/item/device/jirachistone
	name = "Glowing Stone"
	icon = 'icons/mob/jirachi.dmi'
	icon_state = "stone"
	item_state = "stone"
	w_class = 2
	throw_speed = 4
	throw_range = 10
	origin_tech = "powerstorage=6;materials=6;biotech=5;bluespace=5;magnets=5"
	var/searching = 0
	var/list/candidates=list()

	attack_self(mob/user as mob)
		for(var/mob/living/simple_animal/jirachi/K in mob_list)
			if(K)
				user << "\red Stone flickers for a moment, than fades dark."
				return
		if(searching == 0).
			user << "\blue The stone begins to flicker with light!"
			icon_state = "stone"
			src.searching = 1
			spawn(50)
			src.request_player()
			spawn(600)
				src.searching = 0
				if(!candidates.len)		user << "\red The stone stops flickering..."
				else
					var/client/C = pick(candidates)
					for(var/mob/living/P in view(7,get_turf(src.loc)))
						flick("e_flash", P.flash_eyes)
						P << "\red \b Stone starts to glow very brightly, as it starts to transform into some kind of creature..."


					var/mob/living/simple_animal/jirachi = new /mob/living/simple_animal/jirachi
					jirachi.loc = get_turf(src)
					jirachi.key = C.key
					dead_mob_list -= C
					jirachi << "\blue <i><b>Strange feeling...</b></i>"
					jirachi << "\blue <i><b>I feel energy pulsating from every inch of my body</b></i>"
					jirachi << "\blue <i><b>Star power begins to emerge from me, breaking my involucre</b></i>"
					jirachi << "\blue <i><b>My crystalline shell brokens, as I opened my eyes...</b></i>"
					jirachi << ""
					jirachi << "<b>You are now playing as Jirachi - the Child Of The Star!</b> Jirachi is the creature, born by means of Light, Life and Star powers. It is kind to all living beings. That means you ought to protect ordinary crew members, wizards, traitors, aliens, changelings, Syndicate Operatives and others from killing each other. <b><font color=red>Do no harm! Jirachi can't stand pain or suffering of any living creature. Try to use your offensive abilities as little as possible</font></b> In short - you are adorable but very powerful creature, which loves everybody. Also remember, that fire is best friend for you(and the worst enemy for the most other creatures). Being on fire is the other than Hybernation method to pretty rapidly regenerate your health and energy. More information how to RP as Jirachi can be found here: http://sovietstation.ru/index.php?showtopic=4246 Have fun!"
					jirachi << "<b>Hotkeys:</b> Middle Click on tile - blink on that tile (100 energy), Shift+Click on a mob - Teleport that mob, Ctrl+Click on a tile - Create a forcewall on that tile, Alt+Click on a human - Stun"
					qdel(src)

/obj/item/device/jirachistone/proc/request_player()
	for(var/mob/observer/O in player_list)
		if(O.client)
			question(O.client)


/obj/item/device/jirachistone/proc/question(var/client/E)
	spawn(0)
		if(!E)
			return
		var/response = alert(E, "It looks like xenoarcheologists found and activated ancient artifact, which summons mythical creature...Would you like to play as it?", "Jirachi request", "Yes", "No")
		if(!E || 0 == searching || !src)
			return
		for(var/mob/living/simple_animal/jirachi/J in mob_list)
			if(J)
				return
		if(response == "Yes")
			E << "\blue You have been added to the list of candidates!"
			src.candidates+=E
