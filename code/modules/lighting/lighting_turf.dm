/turf
	var/list/affecting_lights
	var/atom/movable/lighting_overlay/lighting_overlay

/turf/proc/reconsider_lights()
	for(var/datum/light_source/L in affecting_lights)
		L.vis_update()

/turf/proc/lighting_clear_overlays()
	if(lighting_overlay)
		qdel(lighting_overlay)

/turf/proc/lighting_build_overlays()
	if(!lighting_overlay)
		var/area/A = loc
		if(A.lighting_use_dynamic)
			var/atom/movable/lighting_overlay/O = PoolOrNew(/atom/movable/lighting_overlay, src)
			lighting_overlay = O

	//Make the light sources recalculate us so the lighting overlay updates immediately
	for(var/datum/light_source/L in affecting_lights)
		L.calc_turf(src)

/turf/set_opacity(new_opacity)
	if(opacity != new_opacity)
		opacity = new_opacity
		src.reconsider_lights()

// Used to get a scaled lumcount.
/turf/proc/get_lumcount(var/minlum = 0, var/maxlum = 1)
	if(!lighting_overlay) //We're not dynamic, whatever, return 50% lighting.
		return 0.5

	var/totallums = 0
	if(lighting_overlay.lum_r) totallums += lighting_overlay.lum_r
	if(lighting_overlay.lum_b) totallums += lighting_overlay.lum_b
	if(lighting_overlay.lum_g) totallums += lighting_overlay.lum_g
	if(totallums)
		totallums /= 3 // Get the average between the 3 spectrums
	else
		return 0
	totallums = (totallums - minlum) / (maxlum - minlum)

	return Clamp(totallums, 0, 1)

/turf/Entered(atom/movable/obj)
	. = ..()
	if(obj && obj.opacity)
		reconsider_lights()

/turf/Exited(atom/movable/obj)
	. = ..()
	if(obj && obj.opacity)
		reconsider_lights()