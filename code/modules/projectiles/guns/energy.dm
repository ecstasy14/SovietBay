/obj/item/weapon/gun/energy
	name = "energy gun"
	desc = "A basic energy-based gun."
	icon_state = "energy"
	fire_sound = 'sound/weapons/Taser.ogg'
	fire_sound_text = "laser blast"

	var/obj/item/weapon/cell/power_supply //What type of power cell this uses
	var/charge_cost = 200 //How much energy is needed to fire.
	var/max_shots = 10 //Determines the capacity of the weapon's power cell. Specifying a cell_type overrides this value.
	var/cell_type = /obj/item/weapon/cell/device/laser/high
	var/projectile_type = /obj/item/projectile/beam/practice
	var/modifystate
	var/charge_meter = 1	//if set, the icon state will be chosen based on the current charge

	//self-recharging
	var/self_recharge = 0	//if set, the weapon will recharge itself
	var/use_external_power = 0 //if set, the weapon will look for an external power source to draw from, otherwise it recharges magically
	var/recharge_time = 4
	var/charge_tick = 0
/obj/item/weapon/gun/energy/switch_firemodes()
	. = ..()
	if(.)
		update_icon()

/obj/item/weapon/gun/energy/emp_act(severity)
	..()
	update_icon()

/obj/item/weapon/gun/energy/New()
	..()
	if(cell_type)
		power_supply = new cell_type(src)
	else
		power_supply = new /obj/item/weapon/cell/device/variable(src, max_shots*charge_cost)
	if(self_recharge)
		processing_objects.Add(src)
	update_icon()

/obj/item/weapon/gun/energy/Destroy()
	if(self_recharge)
		processing_objects.Remove(src)
	..()

/obj/item/weapon/gun/energy/process()
	if(self_recharge) //Every [recharge_time] ticks, recharge a shot for the cyborg
		charge_tick++
		if(charge_tick < recharge_time) return 0
		charge_tick = 0

		if(!power_supply || power_supply.charge >= power_supply.maxcharge)
			return 0 // check if we actually need to recharge

		if(use_external_power)
			var/obj/item/weapon/cell/external = get_external_power_supply()
			if(!external || !external.use(charge_cost)) //Take power from the borg...
				return 0

		power_supply.give(charge_cost) //... to recharge the shot
		update_icon()
	return 1

/obj/item/weapon/gun/energy/consume_next_projectile()
	if(!power_supply) return null
	if(!ispath(projectile_type)) return null
	if(!power_supply.checked_use(charge_cost)) return null
	return new projectile_type(src)

/obj/item/weapon/gun/energy/proc/get_external_power_supply()
	if(isrobot(src.loc))
		var/mob/living/silicon/robot/R = src.loc
		return R.cell
	if(istype(src.loc, /obj/item/rig_module))
		var/obj/item/rig_module/module = src.loc
		if(module.holder && module.holder.wearer)
			var/mob/living/carbon/human/H = module.holder.wearer
			if(istype(H) && H.back)
				var/obj/item/weapon/rig/suit = H.back
				if(istype(suit))
					return suit.cell
	return null

/obj/item/weapon/gun/energy/examine(mob/user)
	..(user)
	var/shots_remaining = round(power_supply.charge / charge_cost)
	user << "Has [shots_remaining] shot\s remaining."
	return

/obj/item/weapon/gun/energy/update_icon()
	..()
	if(charge_meter)
		var/ratio = power_supply.charge / power_supply.maxcharge

		//make sure that rounding down will not give us the empty state even if we have charge for a shot left.
		if(power_supply.charge < charge_cost)
			ratio = 0
		else
			ratio = max(round(ratio, 0.25) * 100, 25)

		if(modifystate)
			icon_state = "[modifystate][ratio]"
		else
			icon_state = "[initial(icon_state)][ratio]"

/////////////////////////////////////////////////////////////////////////////////////////////////////////

/obj/item/weapon/gun/energy/proc/unload_battery(mob/user)
	if(istype(src, /obj/item/weapon/gun/energy/gun/nuclear))	return 1
	if(istype(src, /obj/item/weapon/gun/energy/staff))			return 1
	if(istype(src, /obj/item/weapon/gun/energy/meteorgun))		return 1
	if(istype(src, /obj/item/weapon/gun/energy/temperature))	return 1
	if(istype(src, /obj/item/weapon/gun/energy/crossbow))		return 1
	if(istype(src, /obj/item/weapon/gun/energy/chameleon))		return 1

	if(power_supply)
		if(charge_cost > power_supply.charge)
			power_supply.charge = 0
		user.put_in_hands(power_supply)
		user.visible_message("[user] removes [power_supply] from [src].", "<span class='notice'>You remove [power_supply] from [src].</span>")
		power_supply.update_icon()
		power_supply = null
	else
		user << "<span class='warning'>[src] is empty.</span>"
	if(!modifystate)
		icon_state = "[initial(icon_state)]0"
	else
		icon_state = "[modifystate]0"
	update_twohanding()
	return 0
/////////////////////////////////////////////////////////////////////////////////

/obj/item/weapon/gun/energy/proc/load_battery(var/obj/item/A, mob/user)
	if(istype(A, /obj/item/weapon/cell/device/laser))
		var/obj/item/weapon/cell/device/laser/AM = A
		if(power_supply)
			user << "<span class='warning'>[src] already has a battery loaded.</span>"
			return
		user.remove_from_mob(AM)
		AM.loc = src
		power_supply = AM
		user.visible_message("[user] inserts [AM] into [src].", "<span class='notice'>You insert [AM] into [src].</span>")
		update_icon()
/////////////////////////////////////////////////////////////////////////////////

/obj/item/weapon/gun/energy/verb/eject_battery(mob/user as mob in view(0))
	set category = null
	set src in view(0)
	set name = "Eject battery"
	if(unload_battery(user))
		user << "<span class='warning'>Unable to eject battery.</span>"


/obj/item/weapon/gun/energy/attackby(var/obj/item/A as obj, mob/user as mob)
	load_battery(A, user)
