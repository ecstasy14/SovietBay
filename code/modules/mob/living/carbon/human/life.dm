//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:32

//NOTE: Breathing happens once per FOUR TICKS, unless the last breath fails. In which case it happens once per ONE TICK! So oxyloss healing is done once per 4 ticks while oxyloss damage is applied once per tick!
#define HUMAN_MAX_OXYLOSS 1 //Defines how much oxyloss humans can get per tick. A tile with no air at all (such as space) applies this value, otherwise it's a percentage of it.

#define HUMAN_CRIT_TIME_CUSHION (10 MINUTES) //approximate time limit to stabilize someone in crit
#define HUMAN_CRIT_HEALTH_CUSHION (config.health_threshold_crit - config.health_threshold_dead)

//The amount of damage you'll get when in critical condition. We want this to be a HUMAN_CRIT_TIME_CUSHION long deal.
//There are HUMAN_CRIT_HEALTH_CUSHION hp to get through, so (HUMAN_CRIT_HEALTH_CUSHION/HUMAN_CRIT_TIME_CUSHION) per tick.
//Breaths however only happen once every MOB_BREATH_DELAY life ticks. The delay between life ticks is set by the mob process.
#define HUMAN_CRIT_MAX_OXYLOSS ( MOB_BREATH_DELAY * process_schedule_interval("mob") * (HUMAN_CRIT_HEALTH_CUSHION/HUMAN_CRIT_TIME_CUSHION) )

#define HEAT_DAMAGE_LEVEL_1 2 //Amount of damage applied when your body temperature just passes the 360.15k safety point
#define HEAT_DAMAGE_LEVEL_2 4 //Amount of damage applied when your body temperature passes the 400K point
#define HEAT_DAMAGE_LEVEL_3 8 //Amount of damage applied when your body temperature passes the 1000K point

#define COLD_DAMAGE_LEVEL_1 0.5 //Amount of damage applied when your body temperature just passes the 260.15k safety point
#define COLD_DAMAGE_LEVEL_2 1.5 //Amount of damage applied when your body temperature passes the 200K point
#define COLD_DAMAGE_LEVEL_3 3 //Amount of damage applied when your body temperature passes the 120K point

//Note that gas heat damage is only applied once every FOUR ticks.
#define HEAT_GAS_DAMAGE_LEVEL_1 2 //Amount of damage applied when the current breath's temperature just passes the 360.15k safety point
#define HEAT_GAS_DAMAGE_LEVEL_2 4 //Amount of damage applied when the current breath's temperature passes the 400K point
#define HEAT_GAS_DAMAGE_LEVEL_3 8 //Amount of damage applied when the current breath's temperature passes the 1000K point

#define COLD_GAS_DAMAGE_LEVEL_1 0.5 //Amount of damage applied when the current breath's temperature just passes the 260.15k safety point
#define COLD_GAS_DAMAGE_LEVEL_2 1.5 //Amount of damage applied when the current breath's temperature passes the 200K point
#define COLD_GAS_DAMAGE_LEVEL_3 3 //Amount of damage applied when the current breath's temperature passes the 120K point

#define RADIATION_SPEED_COEFFICIENT 0.1

/mob/living/carbon/human
	var/oxygen_alert = 0
	var/phoron_alert = 0
	var/co2_alert = 0
	var/fire_alert = 0
	var/pressure_alert = 0
	var/temperature_alert = 0
	var/in_stasis = 0
	var/heartbeat = 0

/mob/living/carbon/human/Life()
	set invisibility = 0
	set background = BACKGROUND_ENABLED

	if (transforming)
		return

	fire_alert = 0 //Reset this here, because both breathe() and handle_environment() have a chance to set it.

	//TODO: seperate this out
	// update the current life tick, can be used to e.g. only do something every 4 ticks
	life_tick++

	// This is not an ideal place for this but it will do for now.
	if(wearing_rig && wearing_rig.offline)
		wearing_rig = null

	..()

	if(life_tick%30==15)
		hud_updateflag = 1022

	voice = GetVoice()

	//No need to update all of these procs if the guy is dead.
	if(stat != DEAD && !in_stasis)
		//Updates the number of stored chemicals for powers
		handle_changeling()

		//Organs and blood
		handle_organs()
		handle_blood()
		stabilize_body_temperature() //Body temperature adjusts itself (self-regulation)

		handle_shock()

		handle_pain()

		handle_medical_side_effects()

		if(!client)
			species.handle_npc(src)


	if(!handle_some_updates())
		return											//We go ahead and process them 5 times for HUD images and other stuff though.

	//Update our name based on whether our face is obscured/disfigured
	name = get_visible_name()

/mob/living/carbon/human/proc/handle_some_updates()
	if(life_tick > 5 && timeofdeath && (timeofdeath < 5 || world.time - timeofdeath > 6000))	//We are long dead, or we're junk mobs spawned like the clowns on the clown shuttle
		return 0
	return 1

/mob/living/carbon/human/breathe()
	if(!in_stasis)
		..()
	if(mind && mind.vampire)
		handle_vampire()
// Calculate how vulnerable the human is to under- and overpressure.
// Returns 0 (equals 0 %) if sealed in an undamaged suit, 1 if unprotected (equals 100%).
// Suitdamage can modifiy this in 10% steps.
/mob/living/carbon/human/proc/get_pressure_weakness()

	var/pressure_adjustment_coefficient = 1 // Assume no protection at first.

	if(wear_suit && (wear_suit.item_flags & STOPPRESSUREDAMAGE) && head && (head.item_flags & STOPPRESSUREDAMAGE)) // Complete set of pressure-proof suit worn, assume fully sealed.
		pressure_adjustment_coefficient = 0

		// Handles breaches in your space suit. 10 suit damage equals a 100% loss of pressure protection.
		if(istype(wear_suit,/obj/item/clothing/suit/space))
			var/obj/item/clothing/suit/space/S = wear_suit
			if(S.can_breach && S.damage)
				pressure_adjustment_coefficient += S.damage * 0.1

	pressure_adjustment_coefficient = min(1,max(pressure_adjustment_coefficient,0)) // So it isn't less than 0 or larger than 1.

	return pressure_adjustment_coefficient

// Calculate how much of the enviroment pressure-difference affects the human.
/mob/living/carbon/human/calculate_affecting_pressure(var/pressure)
	var/pressure_difference

	// First get the absolute pressure difference.
	if(pressure < ONE_ATMOSPHERE) // We are in an underpressure.
		pressure_difference = ONE_ATMOSPHERE - pressure

	else //We are in an overpressure or standard atmosphere.
		pressure_difference = pressure - ONE_ATMOSPHERE

	if(pressure_difference < 5) // If the difference is small, don't bother calculating the fraction.
		pressure_difference = 0

	else
		// Otherwise calculate how much of that absolute pressure difference affects us, can be 0 to 1 (equals 0% to 100%).
		// This is our relative difference.
		pressure_difference *= get_pressure_weakness()

	// The difference is always positive to avoid extra calculations.
	// Apply the relative difference on a standard atmosphere to get the final result.
	// The return value will be the adjusted_pressure of the human that is the basis of pressure warnings and damage.
	if(pressure < ONE_ATMOSPHERE)
		return ONE_ATMOSPHERE - pressure_difference
	else
		return ONE_ATMOSPHERE + pressure_difference

/mob/living/carbon/human/handle_disabilities()
	..()
	//Vision
	var/obj/item/organ/vision
	if(species.vision_organ)
		vision = internal_organs_by_name[species.vision_organ]

	if(!species.vision_organ) // Presumably if a species has no vision organs, they see via some other means.
		eye_blind =  0
		blinded =    0
		eye_blurry = 0
	else if(!vision || (vision && vision.is_broken()))   // Vision organs cut out or broken? Permablind.
		eye_blind =  1
		blinded =    1
		eye_blurry = 1
	else
		//blindness
		if(!(sdisabilities & BLIND))
			if(equipment_tint_total >= TINT_BLIND)	// Covered eyes, heal faster
				eye_blurry = max(eye_blurry-2, 0)

	if (disabilities & EPILEPSY)
		if ((prob(1) && paralysis < 1))
			src << "\red You have a seizure!"
			for(var/mob/O in viewers(src, null))
				if(O == src)
					continue
				O.show_message(text("<span class='danger'>[src] starts having a seizure!</span>"), 1)
			Paralyse(10)
			make_jittery(1000)
	if (disabilities & COUGHING)
		if ((prob(5) && paralysis <= 1))
			drop_item()
			spawn( 0 )
				emote("cough")
				return
	if (disabilities & TOURETTES)
		if ((prob(10) && paralysis <= 1))
			Stun(10)
			spawn( 0 )
				switch(rand(1, 3))
					if(1)
						emote("twitch")
					if(2 to 3)
						say("[prob(50) ? ";" : ""][pick("SHIT", "PISS", "FUCK", "CUNT", "COCKSUCKER", "MOTHERFUCKER", "TITS")]")
				make_jittery(100)
				return
	if (disabilities & NERVOUS)
		if (prob(10))
			stuttering = max(10, stuttering)

	if(stat != DEAD)
		var/rn = rand(0, 200)
		if(getBrainLoss() >= 5)
			if(0 <= rn && rn <= 3)
				custom_pain("Your head feels numb and painful.")
		if(getBrainLoss() >= 15)
			if(4 <= rn && rn <= 6) if(eye_blurry <= 0)
				src << "<span class='warning'>It becomes hard to see for some reason.</span>"
				eye_blurry = 10
		if(getBrainLoss() >= 35)
			if(7 <= rn && rn <= 9) if(get_active_hand())
				src << "<span class='danger'>Your hand won't respond properly, you drop what you're holding!</span>"
				drop_item()
		if(getBrainLoss() >= 45)
			if(10 <= rn && rn <= 12)
				if(prob(50))
					src << "<span class='danger'>You suddenly black out!</span>"
					Paralyse(10)
				else if(!lying)
					src << "<span class='danger'>Your legs won't respond properly, you fall down!</span>"
					Weaken(10)



/mob/living/carbon/human/handle_mutations_and_radiation()
	if(in_stasis)
		return

	if(getFireLoss())
		if((COLD_RESISTANCE in mutations) || (prob(1)))
			heal_organ_damage(0,1)

	// DNA2 - Gene processing.
	// The HULK stuff that was here is now in the hulk gene.
	for(var/datum/dna/gene/gene in dna_genes)
		if(!gene.block)
			continue
		if(gene.is_active(src))
			gene.OnMobLife(src)

	radiation = Clamp(radiation,0,100)

	if (radiation)
		var/obj/item/organ/diona/nutrients/rad_organ = locate() in internal_organs
		if(rad_organ && !rad_organ.is_broken())
			var/rads = radiation/25
			radiation -= rads
			nutrition += rads
			adjustBruteLoss(-(rads))
			adjustFireLoss(-(rads))
			adjustOxyLoss(-(rads))
			adjustToxLoss(-(rads))
			updatehealth()
			return

		var/damage = 0
		radiation -= 1 * RADIATION_SPEED_COEFFICIENT
		if(prob(25))
			damage = 1

		if (radiation > 50)
			damage = 1
			radiation -= 1 * RADIATION_SPEED_COEFFICIENT
			if(prob(5) && prob(100 * RADIATION_SPEED_COEFFICIENT))
				radiation -= 5 * RADIATION_SPEED_COEFFICIENT
				src << "<span class='warning'>You feel weak.</span>"
				Weaken(3)
				if(!lying)
					emote("collapse")
			if(prob(5) && prob(100 * RADIATION_SPEED_COEFFICIENT) && species.get_bodytype() == "Human") //apes go bald
				if((h_style != "Bald" || f_style != "Shaved" ))
					src << "<span class='warning'>Your hair falls out.</span>"
					h_style = "Bald"
					f_style = "Shaved"
					update_hair()

		if (radiation > 75)
			radiation -= 1 * RADIATION_SPEED_COEFFICIENT
			damage = 3
			if(prob(5))
				take_overall_damage(0, 5 * RADIATION_SPEED_COEFFICIENT, used_weapon = "Radiation Burns")
			if(prob(1))
				src << "<span class='warning'>You feel strange!</span>"
				adjustCloneLoss(5 * RADIATION_SPEED_COEFFICIENT)
				emote("gasp")

		if(damage)
			damage *= species.radiation_mod
			adjustToxLoss(damage * RADIATION_SPEED_COEFFICIENT)
			updatehealth()
			if(organs.len)
				var/obj/item/organ/external/O = pick(organs)
				if(istype(O)) O.add_autopsy_data("Radiation Poisoning", damage)

	/** breathing **/

/mob/living/carbon/human/handle_chemical_smoke(var/datum/gas_mixture/environment)
	if(wear_mask && (wear_mask.item_flags & BLOCK_GAS_SMOKE_EFFECT))
		return
	if(glasses && (glasses.item_flags & BLOCK_GAS_SMOKE_EFFECT))
		return
	if(head && (head.item_flags & BLOCK_GAS_SMOKE_EFFECT))
		return
	..()

/mob/living/carbon/human/handle_post_breath(datum/gas_mixture/breath)
	..()
	//spread some viruses while we are at it
	if(breath && virus2.len > 0 && prob(10))
		for(var/mob/living/carbon/M in view(1,src))
			src.spread_disease_to(M)


/mob/living/carbon/human/get_breath_from_internal(volume_needed=BREATH_VOLUME)
	if(internal)

		var/obj/item/weapon/tank/rig_supply
		if(istype(back,/obj/item/weapon/rig))
			var/obj/item/weapon/rig/rig = back
			if(!rig.offline && (rig.air_supply && internal == rig.air_supply))
				rig_supply = rig.air_supply

		if (!rig_supply && (!contents.Find(internal) || !((wear_mask && (wear_mask.item_flags & AIRTIGHT)) || (head && (head.item_flags & AIRTIGHT)))))
			internal = null

		if(internal)
			return internal.remove_air_volume(volume_needed)
		else if(internals)
			internals.icon_state = "internal0"
	return null

/mob/living/carbon/human/handle_breath(datum/gas_mixture/breath)
	if(status_flags & GODMODE)
		return

	var/obj/item/organ/lungs/L = internal_organs_by_name["lungs"]
	if(!L && species.has_organ["lungs"])
		failed_last_breath = 1
	else
		failed_last_breath = L.handle_breath(breath) //if breath is null or vacuum, the lungs will handle it for us

	if(failed_last_breath)
		if(prob(20))
			emote("gasp")
		if(health > config.health_threshold_crit)
			adjustOxyLoss(HUMAN_MAX_OXYLOSS)
		else
			adjustOxyLoss(HUMAN_CRIT_MAX_OXYLOSS)

		oxygen_alert = max(oxygen_alert, 1)
		return 0
	return 1

/mob/living/carbon/human/handle_environment(datum/gas_mixture/environment)
	if(!environment)
		return

	//Stuff like the xenomorph's plasma regen happens here.
	species.handle_environment_special(src)

	//Moved pressure calculations here for use in skip-processing check.
	var/pressure = environment.return_pressure()
	var/adjusted_pressure = calculate_affecting_pressure(pressure)

	//Check for contaminants before anything else because we don't want to skip it.
	for(var/g in environment.gas)
		if(gas_data.flags[g] & XGM_GAS_CONTAMINANT && environment.gas[g] > gas_data.overlay_limit[g] + 1)
			pl_effects()
			break

	if(istype(get_turf(src), /turf/space))
		//Don't bother if the temperature drop is less than 0.1 anyways. Hopefully BYOND is smart enough to turn this constant expression into a constant
		if(bodytemperature > (0.1 * HUMAN_HEAT_CAPACITY/(HUMAN_EXPOSED_SURFACE_AREA*STEFAN_BOLTZMANN_CONSTANT))**(1/4) + COSMIC_RADIATION_TEMPERATURE)
			//Thermal radiation into space
			var/heat_loss = HUMAN_EXPOSED_SURFACE_AREA * STEFAN_BOLTZMANN_CONSTANT * ((bodytemperature - COSMIC_RADIATION_TEMPERATURE)**4)
			var/temperature_loss = heat_loss/HUMAN_HEAT_CAPACITY
			bodytemperature -= temperature_loss
	else
		var/loc_temp = T0C
		if(istype(loc, /obj/mecha))
			var/obj/mecha/M = loc
			loc_temp =  M.return_temperature()
		else if(istype(loc, /obj/machinery/atmospherics/unary/cryo_cell))
			loc_temp = loc:air_contents.temperature
		else
			loc_temp = environment.temperature

		if(adjusted_pressure < species.warning_high_pressure && adjusted_pressure > species.warning_low_pressure && abs(loc_temp - bodytemperature) < 20 && bodytemperature < species.heat_level_1 && bodytemperature > species.cold_level_1)
			pressure_alert = 0
			return // Temperatures are within normal ranges, fuck all this processing. ~Ccomp

		//Body temperature adjusts depending on surrounding atmosphere based on your thermal protection (convection)
		var/temp_adj = 0
		if(loc_temp < bodytemperature)			//Place is colder than we are
			var/thermal_protection = get_cold_protection(loc_temp) //This returns a 0 - 1 value, which corresponds to the percentage of protection based on what you're wearing and what you're exposed to.
			if(thermal_protection < 1)
				temp_adj = (1-thermal_protection) * ((loc_temp - bodytemperature) / BODYTEMP_COLD_DIVISOR)	//this will be negative
		else if (loc_temp > bodytemperature)			//Place is hotter than we are
			var/thermal_protection = get_heat_protection(loc_temp) //This returns a 0 - 1 value, which corresponds to the percentage of protection based on what you're wearing and what you're exposed to.
			if(thermal_protection < 1)
				temp_adj = (1-thermal_protection) * ((loc_temp - bodytemperature) / BODYTEMP_HEAT_DIVISOR)

		//Use heat transfer as proportional to the gas density. However, we only care about the relative density vs standard 101 kPa/20 C air. Therefore we can use mole ratios
		var/relative_density = environment.total_moles / MOLES_CELLSTANDARD
		bodytemperature += between(BODYTEMP_COOLING_MAX, temp_adj*relative_density, BODYTEMP_HEATING_MAX)

	// +/- 50 degrees from 310.15K is the 'safe' zone, where no damage is dealt.
	if(bodytemperature >= species.heat_level_1)
		//Body temperature is too hot.
		fire_alert = max(fire_alert, 1)
		if(status_flags & GODMODE)	return 1	//godmode
		var/burn_dam = 0
		if(bodytemperature < species.heat_level_2)
			burn_dam = HEAT_DAMAGE_LEVEL_1
		else if(bodytemperature < species.heat_level_3)
			burn_dam = HEAT_DAMAGE_LEVEL_2
		else
			burn_dam = HEAT_DAMAGE_LEVEL_3
		take_overall_damage(burn=burn_dam, used_weapon = "High Body Temperature")
		fire_alert = max(fire_alert, 2)

	else if(bodytemperature <= species.cold_level_1)
		fire_alert = max(fire_alert, 1)
		if(status_flags & GODMODE)	return 1	//godmode

		if(!istype(loc, /obj/machinery/atmospherics/unary/cryo_cell))
			var/burn_dam = 0
			if(bodytemperature > species.cold_level_2)
				burn_dam = COLD_DAMAGE_LEVEL_1
			else if(bodytemperature > species.cold_level_3)
				burn_dam = COLD_DAMAGE_LEVEL_2
			else
				burn_dam = COLD_DAMAGE_LEVEL_3
			take_overall_damage(burn=burn_dam, used_weapon = "Low Body Temperature")
			fire_alert = max(fire_alert, 1)

	// Account for massive pressure differences.  Done by Polymorph
	// Made it possible to actually have something that can protect against high pressure... Done by Errorage. Polymorph now has an axe sticking from his head for his previous hardcoded nonsense!
	if(status_flags & GODMODE)	return 1	//godmode

	if(adjusted_pressure >= species.hazard_high_pressure)
		var/pressure_damage = min( ( (adjusted_pressure / species.hazard_high_pressure) -1 )*PRESSURE_DAMAGE_COEFFICIENT , MAX_HIGH_PRESSURE_DAMAGE)
		take_overall_damage(brute=pressure_damage, used_weapon = "High Pressure")
		pressure_alert = 2
	else if(adjusted_pressure >= species.warning_high_pressure)
		pressure_alert = 1
	else if(adjusted_pressure >= species.warning_low_pressure)
		pressure_alert = 0
	else if(adjusted_pressure >= species.hazard_low_pressure)
		pressure_alert = -1
	else
		take_overall_damage(brute=LOW_PRESSURE_DAMAGE, used_weapon = "Low Pressure")
		if(getOxyLoss() < 55) // 11 OxyLoss per 4 ticks when wearing internals;    unconsciousness in 16 ticks, roughly half a minute
			adjustOxyLoss(4)  // 16 OxyLoss per 4 ticks when no internals present; unconsciousness in 13 ticks, roughly twenty seconds
		pressure_alert = -2

	return

/mob/living/carbon/human/proc/stabilize_body_temperature()
	if (species.passive_temp_gain) // We produce heat naturally.
		bodytemperature += species.passive_temp_gain
	if (species.body_temperature == null)
		return //this species doesn't have metabolic thermoregulation

	var/body_temperature_difference = species.body_temperature - bodytemperature

	if (abs(body_temperature_difference) < 0.5)
		return //fuck this precision
	if (on_fire)
		return //too busy for pesky metabolic regulation

	if(bodytemperature < species.cold_level_1) //260.15 is 310.15 - 50, the temperature where you start to feel effects.
		if(nutrition >= 2) //If we are very, very cold we'll use up quite a bit of nutriment to heat us up.
			nutrition -= 2
		var/recovery_amt = max((body_temperature_difference / BODYTEMP_AUTORECOVERY_DIVISOR), BODYTEMP_AUTORECOVERY_MINIMUM)
		//world << "Cold. Difference = [body_temperature_difference]. Recovering [recovery_amt]"
//				log_debug("Cold. Difference = [body_temperature_difference]. Recovering [recovery_amt]")
		bodytemperature += recovery_amt
	else if(species.cold_level_1 <= bodytemperature && bodytemperature <= species.heat_level_1)
		var/recovery_amt = body_temperature_difference / BODYTEMP_AUTORECOVERY_DIVISOR
		//world << "Norm. Difference = [body_temperature_difference]. Recovering [recovery_amt]"
//				log_debug("Norm. Difference = [body_temperature_difference]. Recovering [recovery_amt]")
		bodytemperature += recovery_amt
	else if(bodytemperature > species.heat_level_1) //360.15 is 310.15 + 50, the temperature where you start to feel effects.
		//We totally need a sweat system cause it totally makes sense...~
		var/recovery_amt = min((body_temperature_difference / BODYTEMP_AUTORECOVERY_DIVISOR), -BODYTEMP_AUTORECOVERY_MINIMUM)	//We're dealing with negative numbers
		//world << "Hot. Difference = [body_temperature_difference]. Recovering [recovery_amt]"
//				log_debug("Hot. Difference = [body_temperature_difference]. Recovering [recovery_amt]")
		bodytemperature += recovery_amt

	//This proc returns a number made up of the flags for body parts which you are protected on. (such as HEAD, UPPER_TORSO, LOWER_TORSO, etc. See setup.dm for the full list)
/mob/living/carbon/human/proc/get_heat_protection_flags(temperature) //Temperature is the temperature you're being exposed to.
	. = 0
	//Handle normal clothing
	for(var/obj/item/clothing/C in list(head,wear_suit,w_uniform,shoes,gloves,wear_mask))
		if(C)
			if(C.max_heat_protection_temperature && C.max_heat_protection_temperature >= temperature)
				. |= C.heat_protection

//See proc/get_heat_protection_flags(temperature) for the description of this proc.
/mob/living/carbon/human/proc/get_cold_protection_flags(temperature)
	. = 0
	//Handle normal clothing
	for(var/obj/item/clothing/C in list(head,wear_suit,w_uniform,shoes,gloves,wear_mask))
		if(C)
			if(C.min_cold_protection_temperature && C.min_cold_protection_temperature <= temperature)
				. |= C.cold_protection

/mob/living/carbon/human/get_heat_protection(temperature) //Temperature is the temperature you're being exposed to.
	var/thermal_protection_flags = get_heat_protection_flags(temperature)
	return get_thermal_protection(thermal_protection_flags)

/mob/living/carbon/human/get_cold_protection(temperature)
	if(COLD_RESISTANCE in mutations)
		return 1 //Fully protected from the cold.

	temperature = max(temperature, 2.7) //There is an occasional bug where the temperature is miscalculated in ares with a small amount of gas on them, so this is necessary to ensure that that bug does not affect this calculation. Space's temperature is 2.7K and most suits that are intended to protect against any cold, protect down to 2.0K.
	var/thermal_protection_flags = get_cold_protection_flags(temperature)
	return get_thermal_protection(thermal_protection_flags)

/mob/living/carbon/human/proc/get_thermal_protection(var/flags)
	.=0
	if(flags)
		if(flags & HEAD)
			. += THERMAL_PROTECTION_HEAD
		if(flags & UPPER_TORSO)
			. += THERMAL_PROTECTION_UPPER_TORSO
		if(flags & LOWER_TORSO)
			. += THERMAL_PROTECTION_LOWER_TORSO
		if(flags & LEG_LEFT)
			. += THERMAL_PROTECTION_LEG_LEFT
		if(flags & LEG_RIGHT)
			. += THERMAL_PROTECTION_LEG_RIGHT
		if(flags & FOOT_LEFT)
			. += THERMAL_PROTECTION_FOOT_LEFT
		if(flags & FOOT_RIGHT)
			. += THERMAL_PROTECTION_FOOT_RIGHT
		if(flags & ARM_LEFT)
			. += THERMAL_PROTECTION_ARM_LEFT
		if(flags & ARM_RIGHT)
			. += THERMAL_PROTECTION_ARM_RIGHT
		if(flags & HAND_LEFT)
			. += THERMAL_PROTECTION_HAND_LEFT
		if(flags & HAND_RIGHT)
			. += THERMAL_PROTECTION_HAND_RIGHT
	return min(1,.)

/mob/living/carbon/human/handle_chemicals_in_body()
	if(in_stasis)
		return

	if(reagents)
		chem_effects.Cut()
		analgesic = 0

		if(touching) touching.metabolize()
		if(ingested) ingested.metabolize()
		if(bloodstr) bloodstr.metabolize()

		if(CE_PAINKILLER in chem_effects)
			analgesic = chem_effects[CE_PAINKILLER]

		var/total_phoronloss = 0
		for(var/obj/item/I in src)
			if(I.contaminated)
				total_phoronloss += vsc.plc.CONTAMINATION_LOSS
		if(!(status_flags & GODMODE)) adjustToxLoss(total_phoronloss)

	if(status_flags & GODMODE)	return 0	//godmode

	var/obj/item/organ/diona/node/light_organ = locate() in internal_organs
	if(light_organ && !light_organ.is_broken())
		var/light_amount = 0 //how much light there is in the place, affects receiving nutrition and healing
		if(isturf(loc)) //else, there's considered to be no light
			var/turf/T = loc
			var/atom/movable/lighting_overlay/L = locate(/atom/movable/lighting_overlay) in T
			if(L)
				light_amount = min(10,L.lum_r + L.lum_g + L.lum_b) - 2 //hardcapped so it's not abused by having a ton of flashlights
			else
				light_amount =  1
		nutrition += light_amount
		traumatic_shock -= light_amount

		if(species.flags & IS_PLANT)
			if(nutrition > 450)
				nutrition = 450
			if(light_amount >= 3) //if there's enough light, heal
				adjustBruteLoss(-(round(light_amount/2)))
				adjustFireLoss(-(round(light_amount/2)))
				adjustToxLoss(-(light_amount))
				adjustOxyLoss(-(light_amount))
				//TODO: heal wounds, heal broken limbs.

	if(species.light_dam)
		var/light_amount = 0
		if(isturf(loc))
			var/turf/T = loc
			var/atom/movable/lighting_overlay/L = locate(/atom/movable/lighting_overlay) in T
			if(L)
				light_amount = L.lum_r + L.lum_g + L.lum_b //hardcapped so it's not abused by having a ton of flashlights
			else
				light_amount =  10
		if(light_amount > species.light_dam) //if there's enough light, start dying
			take_overall_damage(1,1)
		else //heal in the dark
			heal_overall_damage(1,1)

	// nutrition decrease
	if (nutrition > 0 && stat != 2)
		nutrition = max (0, nutrition - species.hunger_factor)

	if(species.flags & IS_PLANT && (!light_organ || light_organ.is_broken()))
		if(nutrition < 200)
			take_overall_damage(2,0)

			//traumatic_shock is updated every tick, incrementing that is pointless - shock_stage is the counter.
			//Not that it matters much for diona, who have NO_PAIN.
			shock_stage++

	// TODO: stomach and bloodstream organ.
	handle_trace_chems()

	updatehealth()

	return //TODO: DEFERRED

//DO NOT CALL handle_statuses() from this proc, it's called from living/Life() as long as this returns a true value.
/mob/living/carbon/human/handle_regular_status_updates()
	if(!handle_some_updates())
		return 0

	if(status_flags & GODMODE)	return 0

	//SSD check, if a logged player is awake put them back to sleep!
	if(species.show_ssd && !client && !teleop)
		Sleeping(2)
	if(stat == DEAD)	//DEAD. BROWN BREAD. SWIMMING WITH THE SPESS CARP
		blinded = 1
		silent = 0
	else				//ALIVE. LIGHTS ARE ON
		updatehealth()	//TODO

		if(health <= config.health_threshold_dead || (species.has_organ["brain"] && !has_brain()))
			death()
			blinded = 1
			silent = 0
			return 1

		//UNCONSCIOUS. NO-ONE IS HOME
		if((getOxyLoss() > (species.total_health/2)) || (health <= config.health_threshold_crit))
			Paralyse(3)

		if(hallucination)
			if(hallucination >= 20)
				if(prob(3))
					fake_attack(src)
				if(!handling_hal)
					spawn handle_hallucinations() //The not boring kind!
				if(client && prob(5))
					client.dir = pick(2,4,8)
					spawn(rand(20,50))
						client.dir = 1

			hallucination = max(0, hallucination - 2)
		else
			for(var/atom/a in hallucinations)
				qdel(a)

			if(halloss >= species.total_health)
				src << "<span class='warning'>[species.halloss_message_self]</span>"
				src.visible_message("<B>[src]</B> [species.halloss_message].")
				Paralyse(10)
				setHalLoss(species.total_health-1)

		if(paralysis || sleeping)
			blinded = 1
			stat = UNCONSCIOUS
			animate_tail_reset()
			adjustHalLoss(-3)

			if(sleeping)
				handle_dreams()
				if (mind)
					//Are they SSD? If so we'll keep them asleep but work off some of that sleep var in case of stoxin or similar.
					if(client || sleeping > 3)
						AdjustSleeping(-1)
				if( prob(2) && health && !hal_crit )
					spawn(0)
						emote("snore")
			if(mind)
				if(mind.vampire)
					if(istype(loc, /obj/structure/closet/coffin))
						adjustBruteLoss(-1)
						adjustFireLoss(-1)
						adjustToxLoss(-1)
		//CONSCIOUS
		else
			stat = CONSCIOUS

		// Check everything else.

		//Periodically double-check embedded_flag
		if(embedded_flag && !(life_tick % 10))
			if(!embedded_needs_process())
				embedded_flag = 0

		//Ears
		if(sdisabilities & DEAF)	//disabled-deaf, doesn't get better on its own
			ear_deaf = max(ear_deaf, 1)
		else if(ear_deaf)			//deafness, heals slowly over time
			ear_deaf = max(ear_deaf-1, 0)
		else if(istype(l_ear, /obj/item/clothing/ears/earmuffs) || istype(r_ear, /obj/item/clothing/ears/earmuffs))	//resting your ears with earmuffs heals ear damage faster
			ear_damage = max(ear_damage-0.15, 0)
			ear_deaf = max(ear_deaf, 1)
		else if(ear_damage < 25)	//ear damage heals slowly under this threshold. otherwise you'll need earmuffs
			ear_damage = max(ear_damage-0.05, 0)

		//Resting
		if(resting)
			dizziness = max(0, dizziness - 15)
			jitteriness = max(0, jitteriness - 15)
			adjustHalLoss(-3)
		else
			dizziness = max(0, dizziness - 3)
			jitteriness = max(0, jitteriness - 3)
			adjustHalLoss(-1)

		if (drowsyness > 0)
			drowsyness = max(0, drowsyness-1)
			eye_blurry = max(2, eye_blurry)
			if (prob(5))
				sleeping += 1
				Paralyse(5)

		confused = max(0, confused - 1)

		// If you're dirty, your gloves will become dirty, too.
		if(gloves && germ_level > gloves.germ_level && prob(10))
			gloves.germ_level += 1

	return 1

/mob/living/carbon/human/handle_regular_hud_updates()
	if(hud_updateflag) // update our mob's hud overlays, AKA what others see flaoting above our head
		handle_hud_list()

	// now handle what we see on our screen

	if(!..())
		return

	if(stat != DEAD)
		if(stat == UNCONSCIOUS && health <= 0)
			//Critical damage passage overlay
			var/severity = 0
			switch(health)
				if(-20 to -10)			severity = 1
				if(-30 to -20)			severity = 2
				if(-40 to -30)			severity = 3
				if(-50 to -40)			severity = 4
				if(-60 to -50)			severity = 5
				if(-70 to -60)			severity = 6
				if(-80 to -70)			severity = 7
				if(-90 to -80)			severity = 8
				if(-95 to -90)			severity = 9
				if(-INFINITY to -95)	severity = 10
			overlay_fullscreen("crit", /obj/screen/fullscreen/crit, severity)
		else
			clear_fullscreen("crit")
			//Oxygen damage overlay
			if(oxyloss)
				var/severity = 0
				switch(oxyloss)
					if(10 to 20)		severity = 1
					if(20 to 25)		severity = 2
					if(25 to 30)		severity = 3
					if(30 to 35)		severity = 4
					if(35 to 40)		severity = 5
					if(40 to 45)		severity = 6
					if(45 to INFINITY)	severity = 7
				overlay_fullscreen("oxy", /obj/screen/fullscreen/oxy, severity)
			else
				clear_fullscreen("oxy")

		//Fire and Brute damage overlay (BSSR)
		var/hurtdamage = src.getBruteLoss() + src.getFireLoss() + damageoverlaytemp
		damageoverlaytemp = 0 // We do this so we can detect if someone hits us or not.
		if(hurtdamage)
			var/severity = 0
			switch(hurtdamage)
				if(10 to 25)		severity = 1
				if(25 to 40)		severity = 2
				if(40 to 55)		severity = 3
				if(55 to 70)		severity = 4
				if(70 to 85)		severity = 5
				if(85 to INFINITY)	severity = 6
			overlay_fullscreen("brute", /obj/screen/fullscreen/brute, severity)
		else
			clear_fullscreen("brute")

		if(healths)
			if (analgesic > 100)
				healths.icon_state = "health_numb"
			else
				switch(hal_screwyhud)
					if(1)	healths.icon_state = "health6"
					if(2)	healths.icon_state = "health7"
					else
						// Generate a by-limb health display.
						healths.icon_state = "blank"
						healths.overlays = null

						var/no_damage = 1
						var/trauma_val = 0 // Used in calculating softcrit/hardcrit indicators.
						if(!(species.flags & NO_PAIN))
							trauma_val = max(traumatic_shock,halloss)/species.total_health
						var/limb_trauma_val = trauma_val*0.3
						// Collect and apply the images all at once to avoid appearance churn.
						var/list/health_images = list()
						for(var/obj/item/organ/external/E in organs)
							if(no_damage && (E.brute_dam || E.burn_dam))
								no_damage = 0
							health_images += E.get_damage_hud_image(limb_trauma_val)

						// Apply a fire overlay if we're burning.
						if(on_fire)
							health_images += image('icons/mob/screen1_health.dmi',"burning")

						// Show a general pain/crit indicator if needed.
						if(trauma_val)
							if(!(species.flags & NO_PAIN))
								if(trauma_val > 0.7)
									health_images += image('icons/mob/screen1_health.dmi',"softcrit")
								if(trauma_val >= 1)
									health_images += image('icons/mob/screen1_health.dmi',"hardcrit")
						else if(no_damage)
							health_images += image('icons/mob/screen1_health.dmi',"fullhealth")

						healths.overlays += health_images

		if(nutrition_icon)
			switch(nutrition)
				if(450 to INFINITY)				nutrition_icon.icon_state = "nutrition0"
				if(350 to 450)					nutrition_icon.icon_state = "nutrition1"
				if(250 to 350)					nutrition_icon.icon_state = "nutrition2"
				if(150 to 250)					nutrition_icon.icon_state = "nutrition3"
				else							nutrition_icon.icon_state = "nutrition4"

		if(pressure)
			pressure.icon_state = "pressure[pressure_alert]"
		if(toxin)
			if(hal_screwyhud == 4 || phoron_alert)	toxin.icon_state = "tox1"
			else									toxin.icon_state = "tox0"
		if(oxygen)
			if(hal_screwyhud == 3 || oxygen_alert)	oxygen.icon_state = "oxy1"
			else									oxygen.icon_state = "oxy0"
		if(fire)
			if(fire_alert)							fire.icon_state = "fire[fire_alert]" //fire_alert is either 0 if no alert, 1 for cold and 2 for heat.
			else									fire.icon_state = "fire0"

		if(bodytemp)
			if (!species)
				switch(bodytemperature) //310.055 optimal body temp
					if(370 to INFINITY)		bodytemp.icon_state = "temp4"
					if(350 to 370)			bodytemp.icon_state = "temp3"
					if(335 to 350)			bodytemp.icon_state = "temp2"
					if(320 to 335)			bodytemp.icon_state = "temp1"
					if(300 to 320)			bodytemp.icon_state = "temp0"
					if(295 to 300)			bodytemp.icon_state = "temp-1"
					if(280 to 295)			bodytemp.icon_state = "temp-2"
					if(260 to 280)			bodytemp.icon_state = "temp-3"
					else					bodytemp.icon_state = "temp-4"
			else
				//TODO: precalculate all of this stuff when the species datum is created
				var/base_temperature = species.body_temperature
				if(base_temperature == null) //some species don't have a set metabolic temperature
					base_temperature = (species.heat_level_1 + species.cold_level_1)/2

				var/temp_step
				if (bodytemperature >= base_temperature)
					temp_step = (species.heat_level_1 - base_temperature)/4

					if (bodytemperature >= species.heat_level_1)
						bodytemp.icon_state = "temp4"
					else if (bodytemperature >= base_temperature + temp_step*3)
						bodytemp.icon_state = "temp3"
					else if (bodytemperature >= base_temperature + temp_step*2)
						bodytemp.icon_state = "temp2"
					else if (bodytemperature >= base_temperature + temp_step*1)
						bodytemp.icon_state = "temp1"
					else
						bodytemp.icon_state = "temp0"

				else if (bodytemperature < base_temperature)
					temp_step = (base_temperature - species.cold_level_1)/4

					if (bodytemperature <= species.cold_level_1)
						bodytemp.icon_state = "temp-4"
					else if (bodytemperature <= base_temperature - temp_step*3)
						bodytemp.icon_state = "temp-3"
					else if (bodytemperature <= base_temperature - temp_step*2)
						bodytemp.icon_state = "temp-2"
					else if (bodytemperature <= base_temperature - temp_step*1)
						bodytemp.icon_state = "temp-1"
					else
						bodytemp.icon_state = "temp0"
	return 1

/mob/living/carbon/human/handle_random_events()
	if(in_stasis)
		return

	// Puke if toxloss is too high
	if(!stat)
		if (getToxLoss() >= 45 && nutrition > 20)
			vomit()

	//0.1% chance of playing a scary sound to someone who's in complete darkness
	if(isturf(loc) && rand(1,1000) == 1)
		var/turf/T = loc
		var/atom/movable/lighting_overlay/L = locate(/atom/movable/lighting_overlay) in T
		if(L && L.lum_r + L.lum_g + L.lum_b == 0)
			playsound_local(src,pick(scarySounds),50, 1, -1)

/mob/living/carbon/human/handle_stomach()
	spawn(0)
		for(var/mob/living/M in stomach_contents)
			if(M.loc != src)
				stomach_contents.Remove(M)
				continue
			if(iscarbon(M)|| isanimal(M))
				if(M.stat == 2)
					M.death(1)
					stomach_contents.Remove(M)
					qdel(M)
					continue
				if(air_master.current_cycle%3==1)
					if(!(M.status_flags & GODMODE))
						M.adjustBruteLoss(5)
					nutrition += 10

/mob/living/carbon/human/proc/handle_changeling()
	if(mind && mind.changeling)
		mind.changeling.regenerate()

/mob/living/carbon/human/handle_shock()
	..()
	if(status_flags & GODMODE)	return 0	//godmode
	if(species && species.flags & NO_PAIN)
		shock_stage = 0
		return

	if(health < config.health_threshold_softcrit)// health 0 makes you immediately collapse
		shock_stage = max(shock_stage, 61)

	if(traumatic_shock >= 80)
		shock_stage += 1
	else if(health < config.health_threshold_softcrit)
		shock_stage = max(shock_stage, 61)
	else
		shock_stage = min(shock_stage, 160)
		shock_stage = max(shock_stage-1, 0)
		return

	if(shock_stage == 10)
		src << "<span class='danger'>[pick("It hurts so much", "You really need some painkillers", "Dear god, the pain")]!</span>"

	if(shock_stage >= 30)
		if(shock_stage == 30) emote("me",1,"is having trouble keeping their eyes open.")
		eye_blurry = max(2, eye_blurry)
		stuttering = max(stuttering, 5)

	if(shock_stage == 40)
		src << "<span class='danger'>[pick("The pain is excruciating", "Please, just end the pain", "Your whole body is going numb")]!</span>"

	if (shock_stage >= 60)
		if(shock_stage == 60) emote("me",1,"'s body becomes limp.")
		if (prob(2))
			src << "<span class='danger'>[pick("The pain is excruciating", "Please, just end the pain", "Your whole body is going numb")]!</span>"
			Weaken(20)

	if(shock_stage >= 80)
		if (prob(5))
			src << "<span class='danger'>[pick("The pain is excruciating", "Please, just end the pain", "Your whole body is going numb")]!</span>"
			Weaken(20)

	if(shock_stage >= 120)
		if (prob(2))
			src << "<span class='danger'>[pick("You black out", "You feel like you could die any moment now", "You're about to lose consciousness")]!</span>"
			Paralyse(5)

	if(shock_stage == 150)
		emote("me",1,"can no longer stand, collapsing!")
		Weaken(20)

	if(shock_stage >= 150)
		Weaken(20)

/*
	Called by life(), instead of having the individual hud items update icons each tick and check for status changes
	we only set those statuses and icons upon changes.  Then those HUD items will simply add those pre-made images.
	This proc below is only called when those HUD elements need to change as determined by the mobs hud_updateflag.
*/


/mob/living/carbon/human/proc/handle_hud_list()
	if (BITTEST(hud_updateflag, HEALTH_HUD))
		var/image/holder = hud_list[HEALTH_HUD]
		if(stat == DEAD)
			holder.icon_state = "-100" 	// X_X
		else
			holder.icon_state = RoundHealth((health-config.health_threshold_crit)/(maxHealth-config.health_threshold_crit)*100)
		hud_list[HEALTH_HUD] = holder

	if (BITTEST(hud_updateflag, LIFE_HUD))
		var/image/holder = hud_list[LIFE_HUD]
		if(stat == DEAD)
			holder.icon_state = "huddead"
		else
			holder.icon_state = "hudhealthy"
		hud_list[LIFE_HUD] = holder

	if (BITTEST(hud_updateflag, STATUS_HUD))
		var/foundVirus = 0
		for (var/ID in virus2)
			if (ID in virusDB)
				foundVirus = 1
				break

		var/image/holder = hud_list[STATUS_HUD]
		if(stat == DEAD)
			holder.icon_state = "huddead"
		else if(status_flags & XENO_HOST)
			holder.icon_state = "hudxeno"
		else if(foundVirus)
			holder.icon_state = "hudill"
		else if(has_brain_worms())
			var/mob/living/simple_animal/borer/B = has_brain_worms()
			if(B.controlling)
				holder.icon_state = "hudbrainworm"
			else
				holder.icon_state = "hudhealthy"
		else
			holder.icon_state = "hudhealthy"

		var/image/holder2 = hud_list[STATUS_HUD_OOC]
		if(stat == DEAD)
			holder2.icon_state = "huddead"
		else if(status_flags & XENO_HOST)
			holder2.icon_state = "hudxeno"
		else if(has_brain_worms())
			holder2.icon_state = "hudbrainworm"
		else if(virus2.len)
			holder2.icon_state = "hudill"
		else
			holder2.icon_state = "hudhealthy"

		hud_list[STATUS_HUD] = holder
		hud_list[STATUS_HUD_OOC] = holder2

	if (BITTEST(hud_updateflag, ID_HUD))
		var/image/holder = hud_list[ID_HUD]
		if(wear_id)
			var/obj/item/weapon/card/id/I = wear_id.GetID()
			if(I)
				holder.icon_state = "hud[ckey(I.GetJobName())]"
			else
				holder.icon_state = "hudunknown"
		else
			holder.icon_state = "hudunknown"


		hud_list[ID_HUD] = holder

	if (BITTEST(hud_updateflag, WANTED_HUD))
		var/image/holder = hud_list[WANTED_HUD]
		holder.icon_state = "hudblank"
		var/perpname = name
		if(wear_id)
			var/obj/item/weapon/card/id/I = wear_id.GetID()
			if(I)
				perpname = I.registered_name

		for(var/datum/data/record/E in data_core.general)
			if(E.fields["name"] == perpname)
				for (var/datum/data/record/R in data_core.security)
					if((R.fields["id"] == E.fields["id"]) && (R.fields["criminal"] == "*Arrest*"))
						holder.icon_state = "hudwanted"
						break
					else if((R.fields["id"] == E.fields["id"]) && (R.fields["criminal"] == "Incarcerated"))
						holder.icon_state = "hudprisoner"
						break
					else if((R.fields["id"] == E.fields["id"]) && (R.fields["criminal"] == "Parolled"))
						holder.icon_state = "hudparolled"
						break
					else if((R.fields["id"] == E.fields["id"]) && (R.fields["criminal"] == "Released"))
						holder.icon_state = "hudreleased"
						break
		hud_list[WANTED_HUD] = holder

	if (  BITTEST(hud_updateflag, IMPLOYAL_HUD) \
	   || BITTEST(hud_updateflag,  IMPCHEM_HUD) \
	   || BITTEST(hud_updateflag, IMPTRACK_HUD))

		var/image/holder1 = hud_list[IMPTRACK_HUD]
		var/image/holder2 = hud_list[IMPLOYAL_HUD]
		var/image/holder3 = hud_list[IMPCHEM_HUD]

		holder1.icon_state = "hudblank"
		holder2.icon_state = "hudblank"
		holder3.icon_state = "hudblank"

		for(var/obj/item/weapon/implant/I in src)
			if(I.implanted)
				if(istype(I,/obj/item/weapon/implant/tracking))
					holder1.icon_state = "hud_imp_tracking"
				if(istype(I,/obj/item/weapon/implant/loyalty))
					holder2.icon_state = "hud_imp_loyal"
				if(istype(I,/obj/item/weapon/implant/chem))
					holder3.icon_state = "hud_imp_chem"

		hud_list[IMPTRACK_HUD] = holder1
		hud_list[IMPLOYAL_HUD] = holder2
		hud_list[IMPCHEM_HUD]  = holder3

	if (BITTEST(hud_updateflag, SPECIALROLE_HUD))
		var/image/holder = hud_list[SPECIALROLE_HUD]
		holder.icon_state = "hudblank"
		if(mind && mind.special_role)
			if(hud_icon_reference[mind.special_role])
				holder.icon_state = hud_icon_reference[mind.special_role]
			else
				holder.icon_state = "hudsyndicate"
			hud_list[SPECIALROLE_HUD] = holder
	hud_updateflag = 0

/mob/living/carbon/human/handle_stunned()
	if(species.flags & NO_PAIN) //This should be it's own flag, not NO_PAIN
		stunned = 0
		return 0
	return ..()

/mob/living/carbon/human/handle_fire()
	if(..())
		return

	var/burn_temperature = fire_burn_temperature()
	var/thermal_protection = get_heat_protection(burn_temperature)

	if (thermal_protection < 1 && bodytemperature < burn_temperature)
		bodytemperature += round(BODYTEMP_HEATING_MAX*(1-thermal_protection), 1)

/mob/living/carbon/human/rejuvenate()
	restore_blood()
	..()

/mob/living/carbon/human/handle_vision()
	if(client)
		client.screen.Remove(global_hud.blurry, global_hud.druggy, global_hud.vimpaired, global_hud.darkMask, global_hud.nvg, global_hud.thermal, global_hud.meson, global_hud.science)
	if(machine)
		var/viewflags = machine.check_eye(src)
		if(viewflags < 0)
			reset_view(null, 0)
		else if(viewflags)
			sight |= viewflags
	else if(eyeobj)
		if(eyeobj.owner != src)
			reset_view(null)
	else
		var/isRemoteObserve = 0
		if((mRemote in mutations) && remoteview_target)
			if(remoteview_target.stat==CONSCIOUS)
				isRemoteObserve = 1
		if(!isRemoteObserve && client && !client.adminobs)
			remoteview_target = null
			reset_view(null, 0)

	update_equipment_vision()
	species.handle_vision(src)

/mob/living/carbon/human/update_sight()
	..()
	if(stat == DEAD)
		return
	if(mind && mind.vampire)
		if((VAMP_VISION in mind.vampire.powers) && !(VAMP_FULL in mind.vampire.powers))
			sight |= SEE_MOBS
		if((VAMP_FULL in mind.vampire.powers))
			sight |= SEE_TURFS|SEE_MOBS|SEE_OBJS
			see_in_dark = 8
			//see_invisible = SEE_INVISIBLE_OBSERVER_NOLIGHTING

	if(mind && mind.vampire)
		if((VAMP_VISION in mind.vampire.powers) && !(VAMP_FULL in mind.vampire.powers))
			sight |= SEE_MOBS
		if((VAMP_FULL in mind.vampire.powers))
			sight |= SEE_TURFS|SEE_MOBS|SEE_OBJS
			see_in_dark = 8
			//see_invisible = SEE_INVISIBLE_OBSERVER_NOLIGHTING

	if(XRAY in mutations)
		sight |= SEE_TURFS|SEE_MOBS|SEE_OBJS
