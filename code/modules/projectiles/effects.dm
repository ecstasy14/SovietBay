/obj/effect/projectile
	icon = 'icons/effects/projectiles.dmi'
	icon_state = "bolt"
	layer = LIGHTING_LAYER+0.1

/obj/effect/projectile/New(var/turf/location)
	if(istype(location))
		loc = location


/obj/effect/projectile/proc/set_transform(var/matrix/M)
	if(istype(M))
		transform = M

/obj/effect/projectile/proc/activate(var/kill_delay = 5)
	spawn(kill_delay)
		qdel(src)	//see effect_system.dm - sets loc to null and lets GC handle removing these effects
	return

//----------------------------
// Laser beam
//----------------------------
/obj/effect/projectile/laser/tracer
	icon_state = "beam"
	New()
		set_light(l_range = 2, l_power = 1, l_color = COLOR_RED)
		..()

/obj/effect/projectile/laser/muzzle
	icon_state = "muzzle_laser"
	New()
		set_light(l_range = 2, l_power = 1, l_color = COLOR_RED)
		..()

/obj/effect/projectile/laser/impact
	icon_state = "impact_laser"
	New()
		set_light(l_range = 2, l_power = 1, l_color = COLOR_RED)
		..()
//----------------------------
// Blue laser beam
//----------------------------
/obj/effect/projectile/laser_blue/tracer
	icon_state = "beam_blue"
	New()
		set_light(l_range = 2, l_power = 1, l_color = "#0000FF")
		..()

/obj/effect/projectile/laser_blue/muzzle
	icon_state = "muzzle_blue"
	New()
		set_light(l_range = 2, l_power = 1, l_color = "#0000FF")
		..()

/obj/effect/projectile/laser_blue/impact
	icon_state = "impact_blue"
	New()
		set_light(l_range = 2, l_power = 1, l_color = "#0000FF")
		..()

//----------------------------
// Omni laser beam
//----------------------------
/obj/effect/projectile/laser_omni/tracer
	icon_state = "beam_omni"
	New()
		set_light(l_range = 2, l_power = 1, l_color = "#00FF00")
		..()

/obj/effect/projectile/laser_omni/muzzle
	icon_state = "muzzle_omni"
	New()
		set_light(l_range = 2, l_power = 1, l_color = "#00FF00")
		..()

/obj/effect/projectile/laser_omni/impact
	icon_state = "impact_omni"
	New()
		set_light(l_range = 2, l_power = 1, l_color = "#00FF00")
		..()

//----------------------------
// Xray laser beam
//----------------------------
/obj/effect/projectile/xray/tracer
	icon_state = "xray"
	New()
		set_light(l_range = 2, l_power = 1, l_color = "#00FF00")
		..()

/obj/effect/projectile/xray/muzzle
	icon_state = "muzzle_xray"
	New()
		set_light(l_range = 2, l_power = 1, l_color = "#00FF00")
		..()

/obj/effect/projectile/xray/impact
	icon_state = "impact_xray"
	New()
		set_light(l_range = 2, l_power = 1, l_color = "#00FF00")
		..()

//----------------------------
// Heavy laser beam
//----------------------------
/obj/effect/projectile/laser_heavy/tracer
	icon_state = "beam_heavy"
	New()
		set_light(l_range = 2, l_power = 1, l_color = COLOR_RED)
		..()

/obj/effect/projectile/laser_heavy/muzzle
	icon_state = "muzzle_beam_heavy"
	New()
		set_light(l_range = 2, l_power = 1, l_color = COLOR_RED)
		..()

/obj/effect/projectile/laser_heavy/impact
	icon_state = "impact_beam_heavy"
	New()
		set_light(l_range = 2, l_power = 1, l_color = COLOR_RED)
		..()

//----------------------------
// Pulse laser beam
//----------------------------
/obj/effect/projectile/laser_pulse/tracer
	icon_state = "u_laser"
	New()
		set_light(l_range = 2, l_power = 1, l_color = "#0000FF")
		..()

/obj/effect/projectile/laser_pulse/muzzle
	icon_state = "muzzle_u_laser"
	New()
		set_light(l_range = 2, l_power = 1, l_color = "#0000FF")
		..()

/obj/effect/projectile/laser_pulse/impact
	icon_state = "impact_u_laser"
	New()
		set_light(l_range = 2, l_power = 1, l_color = "#0000FF")
		..()

//----------------------------
// Pulse muzzle effect only
//----------------------------
/obj/effect/projectile/pulse/muzzle
	icon_state = "muzzle_pulse"
	New()
		set_light(l_range = 2, l_power = 1, l_color = "#0000FF")
		..()

//----------------------------
// Emitter beam
//----------------------------
/obj/effect/projectile/emitter/tracer
	icon_state = "emitter"
	New()
		set_light(l_range = 2, l_power = 1, l_color = "#64FF64")
		..()

/obj/effect/projectile/emitter/muzzle
	icon_state = "muzzle_emitter"
	New()
		set_light(l_range = 2, l_power = 1, l_color = "#64FF64")
		..()

/obj/effect/projectile/emitter/impact
	icon_state = "impact_emitter"
	New()
		set_light(l_range = 2, l_power = 1, l_color = "#64FF64")
		..()

//----------------------------
// Stun beam
//----------------------------
/obj/effect/projectile/stun/tracer
	icon_state = "stun"
	New()
		set_light(l_range = 2, l_power = 1, l_color = "#FFFFA0")
		..()

/obj/effect/projectile/stun/muzzle
	icon_state = "muzzle_stun"
	New()
		set_light(l_range = 2, l_power = 1, l_color = "#FFFFA0")
		..()

/obj/effect/projectile/stun/impact
	icon_state = "impact_stun"
	New()
		set_light(l_range = 2, l_power = 1, l_color = "#FFFFA0")
		..()

//----------------------------
// Bullet
//----------------------------
/obj/effect/projectile/bullet/muzzle
	icon_state = "muzzle_bullet"
	New()
		set_light(l_range = 3, l_power = 2, l_color = "#FFFF78")
		..()
