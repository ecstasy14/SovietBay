/obj/item/weapon/vape
	name = "Vape Machine"
	desc = "The new age begins."
	icon = 'icons/obj/vape.dmi'
	icon_state = "parilka"
	slot_flags = SLOT_BELT
	w_class = 3.0
	var/datum/effect/effect/system/smoke_spread/bad/smoke

/obj/item/weapon/vape/attack_self(mob/user as mob)
 	smoke = new /datum/effect/effect/system/smoke_spread()
 	playsound(src.loc, 'sound/effects/smoke.ogg', 50, 1, -3)
 	smoke.set_up(5, 0, get_turf(src))
 	sleep(10)
 	smoke.start()






