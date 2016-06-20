/turf/simulated/floor/proc/can_crawl_self(var/mob/user)
	if (!user)
		return 0
	if(!Adjacent(user))
		return 0
	if (user.restrained() || user.buckled)
		return 0
	if (user.stat || user.paralysis || user.sleeping || !user.lying)
		return 0
	if (issilicon(user))
		return 0
	return 1

/turf/simulated/floor/proc/turf_is_crowded()
	for(var/obj/O in contents)
		if(O && O.density)
			return O
	return 0

/turf/simulated/floor/MouseDrop_T(mob/living/carbon/human/target, mob/living/carbon/human/user)
	var/mob/living/carbon/human/H = user
	if(istype(H) && can_crawl_self(H) && target == user)
		do_crawl(H)
	else
		return ..()

/turf/simulated/floor/proc/do_crawl(var/mob/living/carbon/human/user)

	if(!do_after(user,rand(40,60),src,0,0,(INCAPACITATION_RESTRAINED|INCAPACITATION_BUCKLED_PARTIALLY|INCAPACITATION_STUNNED)))
		return
	if(!can_crawl_self(user))
		return
	if(!istype(user.organs_by_name["l_arm"],/obj/item/organ/external/arm) || !istype(user.organs_by_name["r_arm"],/obj/item/organ/external/arm))
		return

	user.becrawling = 1
	for(var/obj/structure/table/O in contents)
		if(O.turf_is_crowded()) return
		usr.forceMove(src)
		user.layer = O.layer - 0.001
		user.visible_message("<span class='warning'>\The [user] crawl under \the [O]!</span>")
		return

	usr.Move(src,pick(1,2,4,8))

mob/living/carbon/human
	var/becrawling = 0
	Move()
		..()
		if(becrawling && usr.layer != MOB_LAYER)
			usr.layer = MOB_LAYER
			becrawling = 0


/obj/structure/table/MouseDrop_T(mob/target, mob/user)
	var/mob/living/carbon/human/H = user
	var/turf/simulated/floor/F = get_turf(src)
	if(istype(H) && istype(F) && target == user && F.can_crawl_self(H))
		usr.visible_message("<span class='warning'>\The [user] starts crawling under \the [src]!</span>")
		F.do_crawl(H)
	else
		return ..()

mob/living/carbon/human/lay_down()
	..()
	if(becrawling && (usr.layer != MOB_LAYER))
		for(var/turf/simulated/floor/F in view(1))
			if(!F.turf_is_crowded() && F.can_crawl_self(src))
				Move(F,pick(1,2,4,8))
				return