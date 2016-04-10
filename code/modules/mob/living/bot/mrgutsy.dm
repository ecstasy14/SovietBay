//----------------------------------------------------------------------
/mob/living/bot/mrgutsy
//----------------------------------------------------------------------
	name = "Mr. Gutsy"
	icon = 'icons/obj/mrgutsy.dmi'
	desc = "This robot is wonderful. I hope."
	icon_state = "mrgutsy"
	maxHealth = 100
	health = 100
	req_one_access = list(access_security, access_forensics_lockers)
	botcard_access = list(access_security, access_sec_doors, access_forensics_lockers, access_morgue, access_maint_tunnels)
//----------------------------------------------------------------------
	var/mob/target
//----------------------------------------------------------------------
	var/idcheck = 0 // If true, arrests for having weapons without authorization.
	var/check_records = 0 // If true, arrests people without a record.
	var/check_arrest = 1 // If true, arrests people who are set to arrest.
	var/arrest_type = 0 // If true, doesn't handcuff. You monster.
	var/declare_arrests = 0 // If true, announces arrests over sechuds.
	var/auto_patrol = 0 // If true, patrols on its own
//----------------------------------------------------------------------
	var/mode = 0
#define mrgutsy_IDLE 		0		// idle
#define mrgutsy_HUNT 		1		// found target, hunting
#define mrgutsy_ARREST		2		// arresting target
#define mrgutsy_START_PATROL	3		// start patrol
#define mrgutsy_WAIT_PATROL	4		// waiting for signals
#define mrgutsy_PATROL		5		// patrolling
#define mrgutsy_SUMMON		6		// summoned by PDA
	var/is_attacking = 0
	var/is_ranged = 0
	var/awaiting_surrender = 0
//----------------------------------------------------------------------
	var/obj/mrgutsy_listener/listener = null
	var/beacon_freq = 1445			// Navigation beacon frequency
	var/control_freq = BOT_FREQ		// Bot control frequency
	var/list/path = list()
	var/frustration = 0
	var/turf/patrol_target = null	// This is where we are headed
	var/closest_dist				// Used to find the closest beakon
	var/destination = "__nearest__"	// This is the current beacon's ID
	var/next_destination = "__nearest__"	// This is the next beacon's ID
	var/nearest_beacon				// Tag of the beakon that we assume to be the closest one
//----------------------------------------------------------------------
	var/bot_version = 1.6
	var/list/threat_found_sounds = new('sound/voice/bcriminal.ogg', 'sound/voice/bjustice.ogg', 'sound/voice/bfreeze.ogg')
	var/list/preparing_arrest_sounds = new('sound/voice/bgod.ogg', 'sound/voice/biamthelaw.ogg', 'sound/voice/bsecureday.ogg', 'sound/voice/bradio.ogg', 'sound/voice/binsult.ogg', 'sound/voice/bcreep.ogg')
//----------------------------------------------------------------------
/mob/living/bot/mrgutsy/New()
	..()
	listener = new /obj/mrgutsy_listener(src)
	listener.mrgutsy = src
//----------------------------------------------------------------------
	spawn(5) // Since beepsky is made on the start... this delay is necessary
		if(radio_controller)
			//radio_controller.add_object(listener, control_freq, filter = RADIO_secbot)
			radio_controller.add_object(listener, beacon_freq, filter = RADIO_NAVBEACONS)
//----------------------------------------------------------------------
/mob/living/bot/mrgutsy/turn_off()
	..()
	target = null
	frustration = 0
	mode = mrgutsy_IDLE
//----------------------------------------------------------------------
/mob/living/bot/mrgutsy/update_icons()
	if(on && is_attacking)
		icon_state = "mrgutsy-roll"
	else
		icon_state = "mrgutsy"
	if(on)
		set_light(2, 1, "#FF6A00")
	else
		set_light(0)
//----------------------------------------------------------------------
/mob/living/bot/mrgutsy/attack_hand(var/mob/user)
	user.set_machine(src)
	var/dat
	dat += "<TT><B>Automatic Security Unit v[bot_version]</B></TT><BR><BR>"
	dat += "Status: <A href='?src=\ref[src];power=1'>[on ? "On" : "Off"]</A><BR>"
	dat += "Behaviour controls are [locked ? "locked" : "unlocked"]<BR>"
	dat += "Maintenance panel is [open ? "opened" : "closed"]"
	if(!locked || issilicon(usr) || usr == src)
		dat += "<BR>Check for Weapon Authorization: <A href='?src=\ref[src];operation=idcheck'>[idcheck ? "Yes" : "No"]</A><BR>"
		dat += "Check Security Records: <A href='?src=\ref[src];operation=ignorerec'>[check_records ? "Yes" : "No"]</A><BR>"
		dat += "Check Arrest Status: <A href='?src=\ref[src];operation=ignorearr'>[check_arrest ? "Yes" : "No"]</A><BR>"
		dat += "Operating Mode: <A href='?src=\ref[src];operation=switchmode'>[arrest_type ? "Detain" : "Arrest"]</A><BR>"
		dat += "Report Arrests: <A href='?src=\ref[src];operation=declarearrests'>[declare_arrests ? "Yes" : "No"]</A><BR>"
		dat += "Auto Patrol: <A href='?src=\ref[src];operation=patrol'>[auto_patrol ? "On" : "Off"]</A><BR>"
	if(istype(user, /mob/living/silicon/ai))
		dat += "<BR><A href='?src=\ref[src];operation=ai_assume'>Assume AI control</A>"
	user << browse("<HEAD><TITLE>Securitron v[bot_version] controls</TITLE></HEAD>[dat]", "window=autosec")
	onclose(user, "autosec")
	return

/mob/living/bot/mrgutsy/Topic(href, href_list)
	if(..())
		return

	usr.set_machine(src)
	add_fingerprint(usr)

	if((href_list["power"]) && (access_scanner.allowed(usr)))
		if(on)
			turn_off()
		else
			turn_on()
		return

	switch(href_list["operation"])
		if("idcheck")
			idcheck = !idcheck
		if("ignorerec")
			check_records = !check_records
		if("ignorearr")
			check_arrest = !check_arrest
		if("switchmode")
			arrest_type = !arrest_type
		if("patrol")
			auto_patrol = !auto_patrol
			mode = mrgutsy_IDLE
		if("declarearrests")
			declare_arrests = !declare_arrests
		if("ai_assume")
			if(istype(usr, /mob/living/silicon/ai))
				var/mob/living/silicon/ai/AI = usr
				assume_ai(AI)
	attack_hand(usr)

/mob/living/bot/mrgutsy/attackby(var/obj/item/O, var/mob/user)
	var/curhealth = health
	..()
	if(health < curhealth)
		target = user
		awaiting_surrender = 5
		mode = mrgutsy_HUNT

/mob/living/bot/mrgutsy/Life()
	..()
	if(!on)
		return
	if(client)
		return

	if(!target)
		scan_view()

	if(!locked && (mode == mrgutsy_START_PATROL || mode == mrgutsy_PATROL)) // Stop running away when we set you up
		mode = mrgutsy_IDLE

	switch(mode)
		if(mrgutsy_IDLE)
			if(auto_patrol && locked)
				mode = mrgutsy_START_PATROL
			return

		if(mrgutsy_HUNT) // Target is in the view or has been recently - chase it
			if(frustration > 7)
				target = null
				frustration = 0
				awaiting_surrender = 0
				mode = mrgutsy_IDLE
				return
			if(target)
				var/threat = check_threat(target)
				if(threat < 4) // Re-evaluate in case they dropped the weapon or something
					target = null
					frustration = 0
					awaiting_surrender = 0
					mode = mrgutsy_IDLE
					return
				if(!(target in view(7, src)))
					++frustration
				if(Adjacent(target))
					mode = mrgutsy_ARREST
					return
				else
					if(is_ranged)
						RangedAttack(target)
					else
						step_towards(src, target) // Melee bots chase a bit faster
					spawn(8)
						if(!Adjacent(target))
							step_towards(src, target)
					spawn(16)
						if(!Adjacent(target))
							step_towards(src, target)

		if(mrgutsy_ARREST) // Target is next to us - attack it
			if(!target)
				mode = mrgutsy_IDLE
			if(!Adjacent(target))
				awaiting_surrender = 5 // I'm done playing nice
				mode = mrgutsy_HUNT
				return
			var/threat = check_threat(target)
			if(threat < 4)
				target = null
				awaiting_surrender = 0
				frustration = 0
				mode = mrgutsy_IDLE
				return
			if(awaiting_surrender < 5 && ishuman(target) && !target.lying)
				if(awaiting_surrender == 0)
					say("Down on the floor, [target]! You have five seconds to comply.")
				++awaiting_surrender
			else
				UnarmedAttack(target)
			if(ishuman(target) && declare_arrests)
				var/area/location = get_area(src)
				broadcast_security_hud_message("[src] is [arrest_type ? "detaining" : "arresting"] a level [check_threat(target)] suspect <b>[target]</b> in <b>[location]</b>.", src)
			return

		if(mrgutsy_START_PATROL)
			if(path.len && patrol_target)
				mode = mrgutsy_PATROL
				return
			else if(patrol_target)
				spawn(0)
					calc_path()
					if(!path.len)
						patrol_target = null
						mode = mrgutsy_IDLE
					else
						mode = mrgutsy_PATROL
			if(!patrol_target)
				if(next_destination)
					find_next_target()
				else
					find_patrol_target()
					say("Engaging patrol mode.")
				mode = mrgutsy_WAIT_PATROL
			return

		if(mrgutsy_WAIT_PATROL)
			if(patrol_target)
				mode = mrgutsy_START_PATROL
			else
				++frustration
				if(frustration > 120)
					frustration = 0
					mode = mrgutsy_IDLE

		if(mrgutsy_PATROL)
			patrol_step()
			spawn(10)
				patrol_step()
			return

		if(mrgutsy_SUMMON)
			patrol_step()
			spawn(8)
				patrol_step()
			spawn(16)
				patrol_step()
			return

/mob/living/bot/mrgutsy/UnarmedAttack(var/mob/M, var/proximity)
	if(!..())
		return

	if(!istype(M))
		return

	if(istype(M, /mob/living/carbon))
		var/mob/living/carbon/C = M
		var/cuff = 1
		if(istype(C, /mob/living/carbon/human))
			var/mob/living/carbon/human/H = C
			if(istype(H.back, /obj/item/weapon/rig) && istype(H.gloves,/obj/item/clothing/gloves/rig))
				cuff = 0
		if(!C.lying || C.handcuffed || arrest_type)
			cuff = 0
		if(!cuff)
			C.stun_effect_act(10, 30, null)
			playsound(loc, 'sound/weapons/Egloves.ogg', 50, 1, -1)
			do_attack_animation(C)
			is_attacking = 1
			update_icons()
			spawn(2)
				is_attacking = 0
				update_icons()
			visible_message("<span class='warning'>[C] was prodded by [src] with a stun baton!</span>")
		else
			playsound(loc, 'sound/weapons/handcuffs.ogg', 30, 1, -2)
			visible_message("<span class='warning'>[src] is trying to put handcuffs on [C]!</span>")
			if(do_mob(src, C, 60))
				if(!C.handcuffed)
					C.handcuffed = new /obj/item/weapon/handcuffs(C)
					C.update_inv_handcuffed()
				if(preparing_arrest_sounds.len)
					playsound(loc, pick(preparing_arrest_sounds), 50, 0)
	else if(istype(M, /mob/living/simple_animal))
		var/mob/living/simple_animal/S = M
		S.AdjustStunned(10)
		S.adjustBruteLoss(15)
		do_attack_animation(M)
		playsound(loc, "swing_hit", 50, 1, -1)
		is_attacking = 1
		update_icons()
		spawn(2)
			is_attacking = 0
			update_icons()
		visible_message("<span class='warning'>[M] was beaten by [src] with a stun baton!</span>")

/mob/living/bot/mrgutsy/explode()
	visible_message("<span class='warning'>[src] blows apart!</span>")
	var/turf/Tsec = get_turf(src)

	var/obj/item/weapon/mrgutsy_assembly/Sa = new /obj/item/weapon/mrgutsy_assembly(Tsec)
	Sa.build_step = 1
	Sa.overlays += image('icons/obj/aibots.dmi', "hs_hole")
	Sa.created_name = name
	new /obj/item/device/assembly/prox_sensor(Tsec)
	new /obj/item/weapon/melee/baton(Tsec)
	if(prob(50))
		new /obj/item/robot_parts/l_arm(Tsec)

	var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
	s.set_up(3, 1, src)
	s.start()

	new /obj/effect/decal/cleanable/blood/oil(Tsec)
	qdel(src)

/mob/living/bot/mrgutsy/proc/scan_view()
	for(var/mob/living/M in view(7, src))
		if(M.invisibility >= INVISIBILITY_LEVEL_ONE)
			continue
		if(M.stat)
			continue

		var/threat = check_threat(M)

		if(threat >= 4)
			target = M
			say("Level [threat] infraction alert!")
			custom_emote(1, "points at [M.name]!")
			mode = mrgutsy_HUNT
			break
	return

/mob/living/bot/mrgutsy/proc/calc_path(var/turf/avoid = null)
	path = AStar(loc, patrol_target, /turf/proc/CardinalTurfsWithAccess, /turf/proc/Distance, 0, 120, id=botcard, exclude=avoid)
	if(!path)
		path = list()

/mob/living/bot/mrgutsy/proc/check_threat(var/mob/living/M)
	if(!M || !istype(M) || M.stat || src == M)
		return 0

	if(emagged)
		return 10

	return M.assess_perp(access_scanner, 0, idcheck, check_records, check_arrest)

/mob/living/bot/mrgutsy/proc/patrol_step()
	if(loc == patrol_target)
		patrol_target = null
		path = list()
		mode = mrgutsy_IDLE
		return

	if(path.len && patrol_target)
		var/turf/next = path[1]
		if(loc == next)
			path -= next
			return
		var/moved = step_towards(src, next)
		if(moved)
			path -= next
			frustration = 0
		else
			++frustration
			if(frustration > 5) // Make a new path
				mode = mrgutsy_START_PATROL
		return
	else
		mode = mrgutsy_START_PATROL

/mob/living/bot/mrgutsy/proc/find_patrol_target()
	send_status()
	nearest_beacon = null
	next_destination = "__nearest__"
	listener.post_signal(beacon_freq, "findbeacon", "patrol")

/mob/living/bot/mrgutsy/proc/find_next_target()
	send_status()
	nearest_beacon = null
	listener.post_signal(beacon_freq, "findbeacon", "patrol")

/mob/living/bot/mrgutsy/proc/send_status()
	var/list/kv = list(
	"type" = "mrgutsy",
	"name" = name,
	"loca" = get_area(loc),
	"mode" = mode
	)
	listener.post_signal_multiple(control_freq, kv)

/obj/mrgutsy_listener
	var/mob/living/bot/mrgutsy/mrgutsy = null

/obj/mrgutsy_listener/proc/post_signal(var/freq, var/key, var/value) // send a radio signal with a single data key/value pair
	post_signal_multiple(freq, list("[key]" = value))

/obj/mrgutsy_listener/proc/post_signal_multiple(var/freq, var/list/keyval) // send a radio signal with multiple data key/values
	var/datum/radio_frequency/frequency = radio_controller.return_frequency(freq)
	if(!frequency)
		return

	var/datum/signal/signal = new()
	signal.source = mrgutsy
	signal.transmission_method = 1
	signal.data = keyval.Copy()

	if(signal.data["findbeacon"])
		frequency.post_signal(mrgutsy, signal, filter = RADIO_NAVBEACONS)
	else if(signal.data["type"] == "mrgutsy")
		//frequency.post_signal(secbot, signal, filter = RADIO_secbot)
	else
		//frequency.post_signal(secbot, signal)

/obj/mrgutsy_listener/receive_signal(datum/signal/signal)
	if(!mrgutsy || !mrgutsy.on)
		return

	var/recv = signal.data["command"]
	if(recv == "bot_status")
		mrgutsy.send_status()
		return

	if(signal.data["active"] == mrgutsy)
		switch(recv)
			if("stop")
				mrgutsy.mode = mrgutsy_IDLE
				mrgutsy.auto_patrol = 0
				return

			if("go")
				mrgutsy.mode = mrgutsy_IDLE
				mrgutsy.auto_patrol = 1
				return

			if("summon")
				mrgutsy.patrol_target = signal.data["target"]
				mrgutsy.next_destination = mrgutsy.destination
				mrgutsy.destination = null
				//mrgutsy.awaiting_beacon = 0
				mrgutsy.mode = mrgutsy_SUMMON
				mrgutsy.calc_path()
				mrgutsy.say("Responding.")
				return

	recv = signal.data["beacon"]
	var/valid = signal.data["patrol"]
	if(!recv || !valid)
		return

	if(recv == mrgutsy.next_destination) // This beacon is our target
		mrgutsy.destination = mrgutsy.next_destination
		mrgutsy.patrol_target = signal.source.loc
		mrgutsy.next_destination = signal.data["next_patrol"]
	else if(mrgutsy.next_destination == "__nearest__")
		var/dist = get_dist(mrgutsy, signal.source.loc)
		if(dist <= 1)
			return

		if(mrgutsy.nearest_beacon)
			if(dist < mrgutsy.closest_dist)
				mrgutsy.nearest_beacon = recv
				mrgutsy.patrol_target = mrgutsy.nearest_beacon
				mrgutsy.next_destination = signal.data["next_patrol"]
				mrgutsy.closest_dist = dist
				return
		else
			mrgutsy.nearest_beacon = recv
			mrgutsy.patrol_target = mrgutsy.nearest_beacon
			mrgutsy.next_destination = signal.data["next_patrol"]
			mrgutsy.closest_dist = dist
//----------------------------------------------------------------------
// Mr. Gutsy Construction //--------------------------------------------
//----------------------------------------------------------------------
/obj/item/weapon/flame/lighter/zippo/attackby(var/obj/item/device/assembly/signaler/S, mob/user as mob)
	..()
	if(!issignaler(S))
		..()
		return

	if(type != /obj/item/weapon/flame/lighter/zippo)
		return

	if(S.secured)
		qdel(S)
		var/obj/item/weapon/mrgutsy_assembly/A = new /obj/item/weapon/mrgutsy_assembly
		user.put_in_hands(A)
		user << "You add the signaler to the zippo."
		user.drop_from_inventory(src)
		qdel(src)
	else
		return

/obj/item/weapon/mrgutsy_assembly
	name = "Mr. Gutsyes head"
	desc = "Some sort of bizarre assembly."
	icon = 'icons/obj/aibots.dmi'
	icon_state = "mrgutsy_signaler"
	item_state = "helmet"
	var/build_step = 0
	var/created_name = "Mister Gutsy"

/obj/item/weapon/mrgutsy_assembly/attackby(var/obj/item/O, var/mob/user)
	..()
	if(istype(O, /obj/item/weapon/weldingtool) && !build_step)
		var/obj/item/weapon/weldingtool/WT = O
		if(WT.remove_fuel(0, user))
			build_step = 1
			overlays += image('icons/obj/aibots.dmi', "hs_hole")
			user << "You weld a hole in \the [src]."

	else if(isprox(O) && (build_step == 1))
		user.drop_item()
		build_step = 2
		user << "You add \the [O] to [src]."
		overlays += image('icons/obj/aibots.dmi', "eyes-mrgutsy")
		name = "helmet/signaler/prox sensor assembly"
		qdel(O)

	else if((istype(O, /obj/item/robot_parts/l_arm) || istype(O, /obj/item/robot_parts/r_arm)) && build_step == 2)
		user.drop_item()
		build_step = 3
		user << "You add \the [O] to [src]."
		name = "helmet/signaler/prox sensor/robot arm assembly"
		overlays += image('icons/obj/aibots.dmi', "hs_arm")
		qdel(O)

	else if(istype(O, /obj/item/weapon/melee/baton) && build_step == 3)
		user.drop_item()
		user << "You complete the Mr. Gutsy! War never changes."
		var/mob/living/bot/mrgutsy/S = new /mob/living/bot/mrgutsy(get_turf(src))
		S.name = created_name
		qdel(O)
		qdel(src)

	else if(istype(O, /obj/item/weapon/pen))
		var/t = sanitizeSafe(input(user, "Enter new robot name", name, created_name), MAX_NAME_LEN)
		if(!t)
			return
		if(!in_range(src, usr) && loc != usr)
			return
		created_name = t
//----------------------------------------------------------------------
// End of file mrgutsy.dm //--------------------------------------------
//----------------------------------------------------------------------