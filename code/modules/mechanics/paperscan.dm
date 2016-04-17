/obj/item/mechcomp/paperscan
	name = "paper scanner"
	desc = "Papers, please."

	icon_state = "comp_pscan"

	above = 1

	var/del_paper = 0

/obj/item/mechcomp/paperscan/attackby(var/obj/item/weapon/W as obj, var/mob/user as mob)
	..()
	if(!istype(W,/obj/item/weapon/paper))
		return
	if(!ready)
		return

	var/obj/item/weapon/paper/doc = W

	ready = 0
	spawn(30)
		ready = 1
	flick(icon_state+"_active",src)

	var/to_send = sanitize(doc.info)

	handler.sendSignal(to_send)

	if(del_paper)
		qdel(W)

/obj/item/mechcomp/paperscan/afterattack(atom/target as turf, mob/user as mob)
	if(get_dist(src, target) == 1)
		if(isturf(target) && target.density)
			user.drop_item()
			src.loc = target
			anchored = 1

/obj/item/mechcomp/paperscan/get_settings(var/source)
	var/dat = "<B>Paper scanner settings:</B><BR>"
	dat += "Paper consumption mode : <A href='?src=\ref[source];paper_action=set_del'>[del_paper ? "true" : "false"]</A><BR>"
	return dat

/obj/item/mechcomp/paperscan/set_settings(href, href_list, user)
	if(href_list["paper_action"])
		switch(href_list["paper_action"])
			if("set_del")
				del_paper = !del_paper

		return MT_REFRESH