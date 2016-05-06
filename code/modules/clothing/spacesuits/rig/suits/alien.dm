/obj/item/weapon/rig/unathi
	name = "NT breacher chassis control module"
	desc = "A cheap NT knock-off of an Unathi battle-rig. Looks like a fish, moves like a fish, steers like a cow."
	suit_type = "NT breacher"
	icon_state = "breacher_rig_cheap"
	armor = list(melee = 60, bullet = 60, laser = 60, energy = 60, bomb = 70, bio = 100, rad = 50)
	emp_protection = -20
	online_slowdown = 6
	offline_slowdown = 10
	vision_restriction = 1
	offline_vision_restriction = 2

	chest_type = /obj/item/clothing/suit/space/rig
	helm_type = /obj/item/clothing/head/helmet/space/rig/unathi
	boot_type = /obj/item/clothing/shoes/magboots/rig/unathi

/obj/item/weapon/rig/unathi/fancy
	name = "breacher chassis control module"
	desc = "An authentic Unathi breacher chassis. Huge, bulky and absurdly heavy. It must be like wearing a tank."
	suit_type = "breacher chassis"
	icon_state = "breacher_rig"
	armor = list(melee = 90, bullet = 90, laser = 90, energy = 90, bomb = 90, bio = 100, rad = 80) //Takes TEN TIMES as much damage to stop someone in a breacher. In exchange, it's slow.
	vision_restriction = 0

/obj/item/clothing/head/helmet/space/rig/unathi
	species_restricted = list("Unathi")
	force = 5
	sharp = 1 //poking people with the horn

/obj/item/clothing/suit/space/rig/unathi
	species_restricted = list("Unathi")

/obj/item/clothing/shoes/magboots/rig/unathi
	species_restricted = list("Unathi")

/obj/item/weapon/rig/resomi
	name = "NT resomi hardsuit"
	desc = "A cheap small NT rig for Resomi."
	suit_type = "NT resomi hardsuit"
	icon_state = "resomi_rig"
	item_state = "resomi_rig"
	armor = list(melee = 40, bullet = 5, laser = 20, energy = 5, bomb = 35, bio = 100, rad = 20) //default
	online_slowdown = 0
	offline_slowdown = 6

	chest_type = /obj/item/clothing/suit/space/rig/resomi
	helm_type = /obj/item/clothing/head/helmet/space/rig/resomi
	boot_type = /obj/item/clothing/shoes/magboots/rig/resomi
	glove_type = /obj/item/clothing/gloves/rig/resomi

/obj/item/weapon/rig/resomi/combat
	name = "resomi hardsuit"
	desc = "An authentic Resomi combat rig. Small, spectacular and extrimely quick."
	suit_type = "resomi hardsuit"
	armor = list(melee = 60, bullet = 50, laser = 40, energy = 20, bomb = 50, bio = 100, rad = 100)
	online_slowdown = 0
	offline_slowdown = 1

/obj/item/clothing/suit/space/rig/resomi
	species_restricted = list("Resomi")
	sprite_sheets = list("Resomi" = 'icons/mob/species/resomi/suit.dmi')

/obj/item/clothing/head/helmet/space/rig/resomi
	species_restricted = list("Resomi")
	sprite_sheets = list("Resomi" = 'icons/mob/species/resomi/helmet.dmi')

/obj/item/clothing/shoes/magboots/rig/resomi
	species_restricted = list("Resomi")

/obj/item/clothing/gloves/rig/resomi
	species_restricted = list("Resomi")
