/obj/item/mechcomp/payment
	name = "payment terminal"
	desc = "All the money in this world can't buy your love... Just kidding."

	icon_state = "comp_money"

	above = 1

	var/current_sum = 0
	var/eject_all = 1
	var/price = 0

	var/thanks = "Thank you for trusting us!"
	var/change = "Here's your change!"

/obj/item/mechcomp/payment/New()
	..()
	handler.addInput("eject money", "eject")

/obj/item/mechcomp/payment/proc/eject(var/signal)
	if(current_sum <= 0)
		return
	if(signal != handler.trigger_signal)
		return

	var/sum = 0
	if(eject_all)
		sum = current_sum
	else
		sum = round(text2num(signal))

	spawn_money(sum, loc)
	current_sum -= sum

	playsound(src, 'sound/machines/chime.ogg', 50, 1)

/obj/item/mechcomp/payment/attackby(var/obj/item/weapon/W as obj, var/mob/user as mob)
	..()
	if(istype(W, /obj/item/weapon/spacecash))
		var/obj/item/weapon/spacecash/moolah = W
		if(moolah.worth >= price)
			flick(icon_state+"_active", src)
			user.show_message("<span class='game say'><span class='name'>\The [src]</span> [pick("bleeps","beeps", "screeches")], \"[thanks]\"</span>",2)

			if(prob(50))
				playsound(loc, 'sound/items/polaroid1.ogg', 50, 1)
			else
				playsound(loc, 'sound/items/polaroid2.ogg', 50, 1)
			moolah.worth -= price
			current_sum += price

			moolah.update_icon()

			if(moolah.worth == 0)
				qdel(moolah)
			else
				user.show_message("<span class='game say'><span class='name'>\The [src]</span> [pick("bleeps","beeps", "screeches")], \"[change]\"</span>",2)

			handler.sendSignal()

/obj/item/mechcomp/payment/afterattack(atom/target as turf, mob/user as mob)
	if(get_dist(src, target) == 1)
		if(isturf(target) && target.density)
			user.drop_item()
			src.loc = target
			anchored = 1

/obj/item/mechcomp/payment/examine(var/mob/user)
	..(user)
	user << "Current price : [price]"

/obj/item/mechcomp/payment/get_settings(var/source)
	var/dat = "<B>Payment terminal settings:</B><BR>"
	dat += "Price : <A href='?src=\ref[source];pay_action=set_price'>[price]</A><BR>"
	dat += "Eject all money : <A href='?src=\ref[source];pay_action=set_eject'>[eject_all ? "true" : "false"]</A><BR>"
	dat += "Thanks string : <A href='?src=\ref[source];pay_action=set_thanks'>[thanks]</A><BR>"
	dat += "Change string : <A href='?src=\ref[source];pay_action=set_change'>[change]</A><BR>"
	dat += "<HR>"
	dat += "Current money storage : [current_sum]<BR>"
	return dat

/obj/item/mechcomp/payment/set_settings(href, href_list, user)
	if(href_list["pay_action"])
		switch(href_list["pay_action"])
			if("set_price")
				price = input(user, "Enter new price:", "Set price") as num
				price = max(price, 1)
				price = min(price, 1000000)
			if("set_eject")
				eject_all = !eject_all
			if("set_thanks")
				thanks = inputText(user, "Enter new thanks string:", "Set thanks string")
			if("set_change")
				change = inputText(user, "Enter new change string:", "Set change string")

		return MT_REFRESH