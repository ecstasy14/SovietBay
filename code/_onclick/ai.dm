/*
	AI ClickOn()

	Note currently ai restrained() returns 0 in all cases,
	therefore restrained code has been removed

	The AI can double click to move the camera (this was already true but is cleaner),
	or double click a mob to track them.

	Note that AI have no need for the adjacency proc, and so this proc is a lot cleaner.
*/
/mob/living/silicon/ai/DblClickOn(var/atom/A, params)
	if(client.buildmode) // comes after object.Click to allow buildmode gui objects to be clicked
		build_click(src, client.buildmode, params, A)
		return

	if(control_disabled || stat) return

	if(ismob(A))
		ai_actual_track(A)
	else
		A.move_camera_by_click()


/mob/living/silicon/ai/ClickOn(var/atom/A, params)
	if(world.time <= next_click)
		return
	next_click = world.time + 1

	if(client.buildmode) // comes after object.Click to allow buildmode gui objects to be clicked
		build_click(src, client.buildmode, params, A)
		return

	if(stat)
		return

	var/list/modifiers = params2list(params)
	if(modifiers["shift"] && modifiers["ctrl"])
		CtrlShiftClickOn(A)
		return
	if(modifiers["middle"])
		MiddleClickOn(A)
		return
	if(modifiers["shift"])
		ShiftClickOn(A)
		return
	if(modifiers["alt"]) // alt and alt-gr (rightalt)
		AltClickOn(A)
		return
	if(modifiers["ctrl"])
		CtrlClickOn(A)
		return

	face_atom(A) // change direction to face what you clicked on

	if(control_disabled || !canClick())
		return

	if(multitool_mode && isobj(A))
		var/obj/O = A
		var/datum/extension/interactive/multitool/MT = get_extension(O, /datum/extension/interactive/multitool)
		if(MT)
			MT.interact(aiMulti, src)
			return

	if(aiCamera.in_camera_mode)
		aiCamera.camera_mode_off()
		aiCamera.captureimage(A, usr)
		return

	/*
		AI restrained() currently does nothing
	if(restrained())
		RestrainedClickOn(A)
	else
	*/
	A.add_hiddenprint(src)
	A.attack_ai(src)

/*
	AI has no need for the UnarmedAttack() and RangedAttack() procs,
	because the AI code is not generic;	attack_ai() is used instead.
	The below is only really for safety, or you can alter the way
	it functions and re-insert it above.
*/
/mob/living/silicon/ai/UnarmedAttack(atom/A)
	A.attack_ai(src)
/mob/living/silicon/ai/RangedAttack(atom/A)
	A.attack_ai(src)

/atom/proc/attack_ai(mob/user as mob)
	return

/*
	Since the AI handles shift, ctrl, and alt-click differently
	than anything else in the game, atoms have separate procs
	for AI shift, ctrl, and alt clicking.
*/

/mob/living/silicon/ai/ShiftClickOn(var/atom/A)
	if(!control_disabled && A.AIShiftClick(src))
		return
	..()

/mob/living/silicon/ai/CtrlClickOn(var/atom/A)
	if(!control_disabled && A.AICtrlClick(src))
		return
	..()

/mob/living/silicon/ai/AltClickOn(var/atom/A)
	if(!control_disabled && A.AIAltClick(src))
		return
	..()

/mob/living/silicon/ai/MiddleClickOn(var/atom/A)
	if(!control_disabled && A.AIMiddleClick(src))
		return
	..()

/*
	The following criminally helpful code is just the previous code cleaned up;
	I have no idea why it was in atoms.dm instead of respective files.
*/

/atom/proc/AICtrlShiftClick()
	return

/atom/proc/AIShiftClick(var/mob/living/silicon/ai/user)
	if(user.scanning)
		return
	user.scanning = 1
	spawn(100)
		user.scanning = 0
	user << "<span class='warning'>Scanning Object...</span>"
	sleep (20)
	if(!istype(src,/mob) || isrobot(src))
		sleep (30)
		src.examine(user)
		return
	if(!ishuman(src))
		user << "<span class='danger'>Unknown Life Form.</span>"
		return
	var/mob/living/carbon/human/H = src
	var/datum/data/record/rec = null
	for(var/datum/data/record/t in data_core.general)
		if(t.fields["name"] == H.name)
			rec = t
			break
	var/text
	if(rec)
		text += "The object identified as <span class='info'>[H.name]</span>, As <span class='notice'>[rec.fields["rank"]]</span>.\n"
	else
		text += "<span class='warning'>Object not identified as crew member.</span>\n"
	if(ishuman(H))
		text += "<a href='?src=\ref[user];mdatabase=[H.name]'>Look at medical data base.</a>\n"
		text += "<a href='?src=\ref[user];sdatabase=[H.name]'>Look at security data base.</a>\n"
	text += "<a href='?src=\ref[user];fullscan=\ref[H]'>Full Scan.</a>"
	text = sanitize_local(text)
	user << text



/obj/machinery/door/airlock/AIShiftClick()  // Opens and closes doors!
	if(density)
		Topic(src, list("command"="open", "activate" = "1"))
	else
		Topic(src, list("command"="open", "activate" = "0"))
	return 1

/atom/proc/AICtrlClick()
	return

/obj/machinery/door/airlock/AICtrlClick() // Bolts doors
	if(locked)
		Topic(src, list("command"="bolts", "activate" = "0"))
	else
		Topic(src, list("command"="bolts", "activate" = "1"))
	return 1

/obj/machinery/power/apc/AICtrlClick() // turns off/on APCs.
	Topic(src, list("breaker"="1"))
	return 1

/obj/machinery/turretid/AICtrlClick() //turns off/on Turrets
	Topic(src, list("command"="enable", "value"="[!enabled]"))
	return 1

/atom/proc/AIAltClick(var/atom/A)
	return AltClick(A)

/obj/machinery/door/airlock/AIAltClick() // Electrifies doors.
	if(!electrified_until)
		// permanent shock
		Topic(src, list("command"="electrify_permanently", "activate" = "1"))
	else
		// disable/6 is not in Topic; disable/5 disables both temporary and permanent shock
		Topic(src, list("command"="electrify_permanently", "activate" = "0"))
	return 1

/obj/machinery/turretid/AIAltClick() //toggles lethal on turrets
	Topic(src, list("command"="lethal", "value"="[!lethal]"))
	return 1

/atom/proc/AIMiddleClick(var/mob/living/silicon/user)
	return 0

/obj/machinery/door/airlock/AIMiddleClick() // Toggles door bolt lights.

	if(..())
		return

	if(!src.lights)
		Topic(src, list("command"="lights", "activate" = "1"))
	else
		Topic(src, list("command"="lights", "activate" = "0"))
	return 1

//
// Override AdjacentQuick for AltClicking
//

/mob/living/silicon/ai/TurfAdjacent(var/turf/T)
	return (cameranet && cameranet.is_turf_visible(T))

/mob/living/silicon/ai/face_atom(var/atom/A)
	if(eyeobj)
		eyeobj.face_atom(A)
