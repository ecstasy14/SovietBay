//Food
/datum/job/bartender
	title = "Bartender"
	department = "Civilian"
	department_flag = CIV
	faction = "Station"
	total_positions = 1
	spawn_positions = 1
	supervisors = "the head of personnel"
	selection_color = "#515151"
	access = list(access_hydroponics, access_bar, access_kitchen)
	minimal_access = list(access_bar)
	outfit_type = /decl/hierarchy/outfit/job/service/bartender

/datum/job/chef
	title = "Chef"
	department = "Civilian"
	department_flag = CIV
	faction = "Station"
	total_positions = 2
	spawn_positions = 2
	supervisors = "the head of personnel"
	selection_color = "#515151"
	access = list(access_hydroponics, access_bar, access_kitchen)
	minimal_access = list(access_kitchen)
	alt_titles = list("Cook")
	outfit_type = /decl/hierarchy/outfit/job/service/chef

/datum/job/hydro
	title = "Gardener"
	department = "Civilian"
	department_flag = CIV
	faction = "Station"
	total_positions = 2
	spawn_positions = 1
	supervisors = "the head of personnel"
	selection_color = "#515151"
	access = list(access_hydroponics, access_bar, access_kitchen)
	minimal_access = list(access_hydroponics)
	alt_titles = list("Hydroponicist")
	outfit_type = /decl/hierarchy/outfit/job/service/gardener

//Cargo
/datum/job/qm
	title = "Quartermaster"
	department = "Cargo"
	department_flag = CIV|CRG
	faction = "Station"
	total_positions = 1
	spawn_positions = 1
	supervisors = "the head of personnel"
	selection_color = "#515151"
	economic_modifier = 5
	access = list(access_maint_tunnels, access_mailsorting, access_cargo, access_cargo_bot, access_qm, access_mining, access_mining_station)
	minimal_access = list(access_maint_tunnels, access_mailsorting, access_cargo, access_cargo_bot, access_qm, access_mining, access_mining_station)

	ideal_character_age = 40
	outfit_type = /decl/hierarchy/outfit/job/cargo/qm

/datum/job/cargo_tech
	title = "Cargo Technician"
	department = "Cargo"
	department_flag = CIV|CRG
	faction = "Station"
	total_positions = 2
	spawn_positions = 2
	supervisors = "the quartermaster and the head of personnel"
	selection_color = "#515151"
	access = list(access_maint_tunnels, access_mailsorting, access_cargo, access_cargo_bot, access_qm, access_mining, access_mining_station)
	minimal_access = list(access_maint_tunnels, access_cargo, access_cargo_bot, access_mailsorting)
	outfit_type = /decl/hierarchy/outfit/job/cargo/cargo_tech

/datum/job/mining
	title = "Shaft Miner"
	department = "Cargo"
	department_flag = CIV
	faction = "Station"
	total_positions = 3
	spawn_positions = 3
	supervisors = "the quartermaster and the head of personnel"
	selection_color = "#515151"
	economic_modifier = 5
	access = list(access_maint_tunnels, access_mailsorting, access_cargo, access_cargo_bot, access_qm, access_mining, access_mining_station)
	minimal_access = list(access_mining, access_mining_station, access_mailsorting)
	alt_titles = list("Drill Technician","Prospector")
	outfit_type = /decl/hierarchy/outfit/job/cargo/mining



/datum/job/artist
	title = "Artist"
	department = "Civilian"
	department_flag = CIV
	faction = "Station"
	total_positions = 3
	spawn_positions = 3
	supervisors = "the head of personnel"
	selection_color = "#dddddd"
	access = list(access_theatre, access_maint_tunnels)
	minimal_access = list(access_theatre, access_maint_tunnels)
	alt_titles = list("Clown","Mime","Musician","Guitarist","Stand-Up Comic")

	equip(var/mob/living/carbon/human/H)
		H.equip_to_slot_or_del(new /obj/item/device/radio/headset/headset_service(H), slot_l_ear)
		if(H.mind.role_alt_title && H.mind.role_alt_title == "Clown")
			H.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/clown(H), slot_back)
			H.equip_to_slot_or_del(new /obj/item/weapon/storage/box/survival(H.back), slot_in_backpack)
		else
			switch(H.backbag)
				if(2) H.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack(H), slot_back)
				if(3) H.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/satchel_norm(H), slot_back)
				if(4) H.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/satchel(H), slot_back)
			if(H.backbag == 1)
				H.equip_to_slot_or_del(new /obj/item/weapon/storage/box/survival(H), slot_r_hand)
			else
				H.equip_to_slot_or_del(new /obj/item/weapon/storage/box/survival(H.back), slot_in_backpack)
		if (H.mind.role_alt_title)
			switch(H.mind.role_alt_title)
				if("Clown")
					H.mutations.Add(CLUMSY)
					H.equip_to_slot_or_del(new /obj/item/clothing/under/rank/clown(H), slot_w_uniform)
					H.equip_to_slot_or_del(new /obj/item/clothing/shoes/clown_shoes(H), slot_shoes)
					H.equip_to_slot_or_del(new /obj/item/device/pda/clown(H), slot_belt)
					H.equip_to_slot_or_del(new /obj/item/clothing/mask/gas/clown_hat(H), slot_wear_mask)
					H.equip_to_slot_or_del(new /obj/item/weapon/bananapeel(H), slot_in_backpack)
					H.equip_to_slot_or_del(new /obj/item/weapon/bikehorn(H), slot_in_backpack)
					H.equip_to_slot_or_del(new /obj/item/weapon/stamp/clown(H), slot_in_backpack)
					H.equip_to_slot_or_del(new /obj/item/weapon/pen/crayon/rainbow(H), slot_in_backpack)
					H.equip_to_slot_or_del(new /obj/item/weapon/storage/fancy/crayons(H), slot_in_backpack)
					H.equip_to_slot_or_del(new /obj/item/toy/waterflower(H), slot_in_backpack)
				if("Mime")
					H.equip_to_slot_or_del(new /obj/item/clothing/under/mime(H), slot_w_uniform)
					H.equip_to_slot_or_del(new /obj/item/clothing/shoes/black(H), slot_shoes)
					H.equip_to_slot_or_del(new /obj/item/device/pda/mime(H), slot_belt)
					H.equip_to_slot_or_del(new /obj/item/clothing/gloves/white(H), slot_gloves)
					H.equip_to_slot_or_del(new /obj/item/clothing/mask/gas/mime(H), slot_wear_mask)
					H.equip_to_slot_or_del(new /obj/item/clothing/head/beret(H), slot_head)
					H.equip_to_slot_or_del(new /obj/item/clothing/suit/suspenders(H), slot_wear_suit)
					if(H.backbag == 1)
						H.equip_to_slot_or_del(new /obj/item/weapon/pen/crayon/mime(H), slot_l_store)
						H.equip_to_slot_or_del(new /obj/item/weapon/reagent_containers/food/drinks/bottle/bottleofnothing(H), slot_l_hand)
					else
						H.equip_to_slot_or_del(new /obj/item/weapon/pen/crayon/mime(H), slot_in_backpack)
						H.equip_to_slot_or_del(new /obj/item/weapon/reagent_containers/food/drinks/bottle/bottleofnothing(H), slot_in_backpack)
					H.verbs += /client/proc/mimespeak
					H.verbs += /client/proc/mimewall
					H.mind.special_verbs += /client/proc/mimespeak
					H.mind.special_verbs += /client/proc/mimewall
					H.miming = 1
				if("Musician")
					H.equip_to_slot_or_del(new /obj/item/device/violin(H), slot_l_hand)
				if("Guitarist")
					H.equip_to_slot_or_del(new /obj/item/device/guitar(H), slot_l_hand)
		H.equip_to_slot_or_del(new /obj/item/clothing/shoes/black(H), slot_shoes)
		if(H.gender == "male")
			H.equip_to_slot_or_del(new /obj/item/clothing/under/assistantformal(H), slot_w_uniform)
		else
			H.equip_to_slot_or_del(new /obj/item/clothing/under/blackjumpskirt(H), slot_w_uniform)
		return 1



/datum/job/janitor
	title = "Janitor"
	department = "Civilian"
	department_flag = CIV
	faction = "Station"
	total_positions = 1
	spawn_positions = 1
	supervisors = "the head of personnel"
	selection_color = "#515151"
	access = list(access_janitor, access_maint_tunnels, access_engine, access_research, access_sec_doors, access_medical)
	minimal_access = list(access_janitor, access_maint_tunnels, access_engine, access_research, access_sec_doors, access_medical)
	outfit_type = /decl/hierarchy/outfit/job/service/janitor

//More or less assistants
/datum/job/librarian
	title = "Librarian"
	department = "Civilian"
	department_flag = CIV
	faction = "Station"
	total_positions = 1
	spawn_positions = 1
	supervisors = "the head of personnel"
	selection_color = "#515151"
	access = list(access_library, access_maint_tunnels)
	minimal_access = list(access_library)
	alt_titles = list("Journalist")
	outfit_type = /decl/hierarchy/outfit/job/librarian

/datum/job/lawyer
	title = "Internal Affairs Agent"
	department = "Civilian"
	department_flag = CIV
	faction = "Station"
	total_positions = 2
	spawn_positions = 2
	supervisors = "company officials and Corporate Regulations"
	selection_color = "#515151"
	economic_modifier = 7
	access = list(access_lawyer, access_sec_doors, access_maint_tunnels, access_heads)
	minimal_access = list(access_lawyer, access_sec_doors, access_heads)
	minimal_player_age = 10
	outfit_type = /decl/hierarchy/outfit/job/internal_affairs_agent

/datum/job/lawyer/equip(var/mob/living/carbon/human/H)
	. = ..()
	if(.)
		H.implant_loyalty(H)
