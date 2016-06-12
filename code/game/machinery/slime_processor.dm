/obj/machinery/slime_processor
	name = "Slime Processor"
	desc = "An industrial grinder used to process slimes. Keep hands clear of intake area while operating."
	icon = 'icons/obj/kitchen.dmi'
	icon_state = "processor"
	layer = 2.9
	density = 1
	anchored = 1
	var/processing = 0
	use_power = 1
	idle_power_usage = 5
	active_power_usage = 50
	var/mob/living/carbon/slime/picked_slime = null




/obj/machinery/slime_processor/process()
	..()
	if(processing || !picked_slime)
		return
	playsound(src.loc, 'sound/machines/blender.ogg', 50, 1)
	processing = 1
	icon_state = "processor1"
	picked_slime.icon_state = "[picked_slime.colour] baby slime dead-nocore"
	for(var/i = 0, i <= 50, i++)
		sleep(1)
		pixel_x = rand(-2,2)
		pixel_y = rand(-2,2)
	processing = 0
	picked_slime.cores = 0
	pixel_x = initial(pixel_x)
	pixel_y = initial(pixel_y)
	icon_state = initial(icon_state)
	if(prob(90))
		new picked_slime.coretype(picked_slime.loc)
	for(var/atom/movable/O in contents)
		O.Move(get_turf(src))
	picked_slime = initial(picked_slime)



/obj/machinery/slime_processor/attackby(var/obj/item/weapon/grab/O as obj, mob/user as mob)
	if(!picked_slime)
		if(istype(O.affecting, /mob/living/carbon))
			if(O.affecting.stat)
				if(istype(O.affecting, /mob/living/carbon/slime))
					var/mob/living/carbon/slime/SL = O.affecting
					if(SL.cores <= 0) return
					picked_slime = O.affecting
					O.affecting.loc = src
					user << "You place [O.affecting] in [src]."
					qdel(O)
				else
					user << "You can't place [O.affecting] in [src]."
			else
				user << "You can't place [O.affecting] in [src]."



