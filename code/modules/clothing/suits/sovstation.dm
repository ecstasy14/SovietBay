/*
Там, где мечты становятся явью.
Расположение спрайтов Советской Станции.
*/

// Раздел Хоса
// Шинель Хоса. Основа - labcoat

/obj/item/clothing/suit/armor/hoscoat
	name = "Formal Greatcoat"
	desc = "A formal suit, that could be good for HoS, or not."
	var/base_icon_state = "formalcoat"
	var/open=1
	item_state = "jensencoat"
	blood_overlay_type = "coat"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS
	armor = list(melee = 65, bullet = 30, laser = 50, energy = 10, bomb = 25, bio = 0, rad = 0)

	update_icon()
		if(open)
			icon_state="[base_icon_state]_open"
		else
			icon_state="[base_icon_state]"

	verb/toggle()
		set name = "Toggle Greatcoat Buttons"
		set category = "Object"
		set src in usr

		if(!usr.canmove || usr.stat || usr.restrained())
			return 0

		if(open)
			usr << "You button up the greatcoat."
		else
			usr << "You unbutton the greatcoat."
		open=!open
		update_icon()
		usr.update_inv_wear_suit()

/obj/item/clothing/suit/armor/hoscoat/New()
	. = ..()
	update_icon()

//Формальная одежда

/obj/item/clothing/under/rank/head_of_security/hosformal
	desc = "You never asked for anything that stylish."
	name = "head of security's formal uniform"
	icon_state = "hosformal"
	item_state = "hos"
	worn_state = "hosformal"
	siemens_coefficient = 0.6

//Фуражки Хоса

/obj/item/clothing/head/helmet/HoS/formal
	name = "head of security's formal cap"
	desc = "Looks nice and cool, show officer who is their BOSS!"
	icon_state = "hosformalhat"
	siemens_coefficient = 0.6

/obj/item/clothing/head/helmet/HoS/formal2
	name = "head of security's enchanced cap"
	desc = "This hat looks brutal. Seems have been taken from old russian officers."
	icon_state = "hat-hos"
	siemens_coefficient = 0.6


//Коммисарская одежда. Украдено с Анимуса, спасибо за кражу.


/obj/item/clothing/head/helmet/commisarcap
	name = "commisar's cap"
	desc = "A cap of fear and madness."
	icon_state = "comcap"
	flags_inv = 0

/obj/item/clothing/suit/armor/commisarcoat
	name = "commisar's coat"
	desc = "A greatcoat enchanced with a special alloy for some protection and style, looks more brutal."
	icon_state = "commissarcoat"
	item_state = "hos"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS
	armor = list(melee = 65, bullet = 30, laser = 50, energy = 10, bomb = 25, bio = 0, rad = 0)
	siemens_coefficient = 0.6

//Феска. Специально для Kirillwars.

/obj/item/clothing/head/fez
	name = "Fez"
	desc = "Cool looking fez. You see a text under 'KWARS'."
	icon_state = "feska"
	siemens_coefficient = 0.9

// Военная одежда.

/obj/item/clothing/suit/armor/vest/military
	name = "military armor"
	desc = "An armored vest that protects against some damage. Belongs to Solar Republic, government type of armor."
	icon_state = "M03"
	item_state = "armor"

/obj/item/clothing/under/olivecamouflage
	name = "olive jumpsuit"
	desc = "An olive jumpsuit, that have Solar Republic mark."
	icon_state = "bdu_olive"
	item_state = "bl_suit"
	worn_state = "bdu_olive"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS|ARMS
	siemens_coefficient = 0.6

/obj/item/clothing/head/helmet/military
	name = "military helmet"
	desc = "An olive colored helmet. Belongs to Solar Republic, government type of armor."
	icon_state = "m10hlm"
	item_state = "helmet"
	armor = list(melee = 80, bullet = 45, laser = 35 ,energy = 35, bomb = 10, bio = 2, rad = 0)
	flags_inv = HIDEEARS
	siemens_coefficient = 0.7

/obj/item/clothing/suit/armor/militarycoat
	name = "military coat"
	desc = "Olive-colored coat that have armored plates. Belongs to Solar Republic, government type of armor."
	icon_state = "milcoat"
	item_state = "hos"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS
	armor = list(melee = 65, bullet = 30, laser = 50, energy = 10, bomb = 25, bio = 0, rad = 0)
	siemens_coefficient = 0.6

/obj/item/clothing/head/helmet/olivehelmet
	name = "olive-colored helmet"
	desc = "An olive colored helmet. Have a red star on front side."
	icon_state = "helmet_sum"
	item_state = "helmet"
	armor = list(melee = 80, bullet = 45, laser = 35 ,energy = 35, bomb = 10, bio = 2, rad = 0)
	flags_inv = HIDEEARS
	siemens_coefficient = 0.7

/obj/item/clothing/head/helmet/ushankahelmet
	name = "Ushanka"
	desc = "An ushanka. Have armored plates."
	icon_state = "shapka_win"
	item_state = "helmet"
	armor = list(melee = 80, bullet = 45, laser = 35 ,energy = 35, bomb = 10, bio = 2, rad = 0)
	flags_inv = HIDEEARS
	siemens_coefficient = 0.7


// Одежда спецвойск Солнечной Республики

/obj/item/clothing/suit/armor/vest/earthgov
	name = "enchanced helmet"
	desc = "An armored helmet that protects against some damage. This one have Earth interface, seems belongs to Solar Republic."
	icon_state = "earthgov-armor"
	item_state = "armor"

/obj/item/clothing/head/helmet/earthgov
	name = "military helmet"
	desc = "An armored helmet that protects againts some damage. This one have Earth interface, seems belongs to Solar Republic."
	icon_state = "earthgov-helmet"
	item_state = "helmet"
	armor = list(melee = 80, bullet = 45, laser = 35 ,energy = 35, bomb = 10, bio = 2, rad = 0)
	flags_inv = HIDEEARS
	siemens_coefficient = 0.7

/obj/item/clothing/gloves/earthgov
	name = "enchanced gloves"
	desc = "An armored gloves that protects against some damage. They have Earth mark, seems belongs to Solar Republic."
	icon_state = "earthgov-gloves"
	item_state = "swat_gl"
	siemens_coefficient = 0
	permeability_coefficient = 0.05
	cold_protection = HANDS
	heat_protection = HANDS

/obj/item/clothing/shoes/earthgov
	name = "enchanced boots"
	desc = "An armored boots that protects against some damage. They have Earth mark, seems belongs to Solar Republic."
	icon_state = "earthgov_boots"
	armor = list(melee = 80, bullet = 60, laser = 50,energy = 25, bomb = 50, bio = 10, rad = 0)
	flags = NOSLIP
	siemens_coefficient = 0.6

/obj/item/clothing/under/earthgov
	desc = "It's a jumpsuit worn by solar government representives."
	name = "Earth Military jumpsuit"
	icon_state = "earthgov_uniform"
	item_state = "bl_suit"
	worn_state = "earthgov_uniform"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS|ARMS
	siemens_coefficient = 0.6


// Звёздные войны: Война Смоллгеев

/obj/item/clothing/suit/armor/vader
	name = "dark-colored suit"
	desc = "A bulky, heavy-duty piece of black armor. Peace is a lie, there is only passion."
	icon_state = "vader"
	item_state = "death_commando_suit"
	w_class = 4
	gas_transfer_coefficient = 0.01
	permeability_coefficient = 0.02
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS|FEET|ARMS
	allowed = list(/obj/item/weapon/tank/emergency_oxygen, /obj/item/device/flashlight,/obj/item/weapon/gun/energy, /obj/item/weapon/gun/projectile, /obj/item/ammo_casing, /obj/item/weapon/melee/baton,/obj/item/weapon/handcuffs,/obj/item/weapon/tank/emergency_nitrogen,/obj/item/weapon/melee/energy/sword/red)
	slowdown = 1.5
	armor = list(melee = 65, bullet = 50, laser = 50, energy = 25, bomb = 50, bio = 100, rad = 50)
	flags_inv = HIDEGLOVES|HIDESHOES|HIDEJUMPSUIT
	cold_protection = UPPER_TORSO | LOWER_TORSO | LEGS | FEET | ARMS | HANDS
	siemens_coefficient = 0.7

/obj/item/clothing/head/helmet/space/vader
	name = "dark-colored vader"
	icon_state = "vaderhelm"
	item_state = "helmet"
	desc = "A special helmet designed for work in a hazardous, low-pressure environment. Through passion, I gain strength.."
	flags_inv = HIDEFACE
	permeability_coefficient = 0.01
	armor = list(melee = 65, bullet = 50, laser = 50,energy = 25, bomb = 50, bio = 100, rad = 50)

/obj/item/clothing/head/helmet/space/rig/clonesoldier
	name = "white helmet"
	desc = "A special helmet designed for work in a hazardous low pressure environment. Vode An."
	icon_state = "clonehlm"
	species_restricted = list("exclude","Vox")
	armor = list(melee = 60, bullet = 10, laser = 30, energy = 5, bomb = 45, bio = 100, rad = 10)
	siemens_coefficient = 0.7

/obj/item/clothing/suit/space/rig/clonesoldier
	icon_state = "clonesld"
	name = "white hardsuit"
	desc = "A special suit that protects against hazardous low pressure environments. Vode An."
	species_restricted = list("exclude","Vox")
	armor = list(melee = 60, bullet = 10, laser = 30, energy = 5, bomb = 45, bio = 100, rad = 10)
	allowed = list(/obj/item/weapon/gun,/obj/item/device/flashlight,/obj/item/weapon/tank,/obj/item/weapon/melee/baton)
	siemens_coefficient = 0.7

// Викторианская эпоха

/obj/item/clothing/suit/redcoat
	name = "Redcoat Suit"
	desc = "True royal suit. God, save the King/Queen."
	icon_state = "redcoat_suit"

/obj/item/clothing/head/redcoathat
	name = "Redcoat Tricorne"
	desc = "True royal hat. God, save the King/Queen."
	icon_state = "redcoat-head"

/obj/item/clothing/head/bearskins
	name = "Bearskins Hat"
	desc = "Popular hat, worned by disciplined royal guards only."
	icon_state = "queen"

/obj/item/clothing/suit/cape
	name = "Cape"
	desc = "Executive cape from old England"
	icon_state = "tea_suit"

/obj/item/clothing/under/musketeer
	desc = "It's a uniform worned by russian musketeers in XIX century."
	name = "musketeer uniform"
	icon_state = "musketeer_uniform"
	item_state = "bl_suit"
	worn_state = "musketeer_uniform"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS|ARMS
	siemens_coefficient = 0.6

/obj/item/clothing/head/musketeer
	name = "Hussar hat"
	desc = "Russian hussar hat, approved by Tsar."
	icon_state = "gusarhat"

// Одежда гражданской обороны

/obj/item/clothing/under/metrocop
	desc = "Strange jumpsuit, seems have many injecting ports and implants."
	name = "armored jumpsuit"
	icon_state = "mpfuni"
	item_state = "bl_suit"
	worn_state = "mpfuni"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS|ARMS
	siemens_coefficient = 0.6

/obj/item/clothing/mask/gas/metrocop
	name = "\improper armored mask"
	desc = "Strange mask, looks can change voice."
	icon_state = "mpfmask"
	siemens_coefficient = 0.7

// Барни!

/obj/item/clothing/suit/armor/vest/blackmesa
	name = "blue armor"
	desc = "Blue armor, have a strange symbol on front side - Lambda"
	icon_state = "bluevest"
	item_state = "armor"

/obj/item/clothing/head/helmet/blackmesa
	name = "Blue helmet"
	desc = "Just a simple blue helmet."
	icon_state = "bluehelmet"
	item_state = "helmet"
	armor = list(melee = 80, bullet = 45, laser = 35 ,energy = 35, bomb = 10, bio = 2, rad = 0)
	flags_inv = HIDEEARS
	siemens_coefficient = 0.7

/obj/item/clothing/under/blackmesa
	name = "blue security jumpsuit"
	desc = "Strange jumpsuit, there is no mark of NanoTrasen. Lambda sign at the front"
	icon_state = "blueuni"
	item_state = "bl_suit"
	worn_state = "blueuni"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS|ARMS
	siemens_coefficient = 0.6

// Llegoman clothes

/obj/item/clothing/under/leeunder
	name = "casual uniform with jacket"
	desc = "Good looking uniform with jacket. You see a label 'Made by Rorschash Ind.'."
	icon_state = "lee_short1"
	item_state = "bl_suit"
	worn_state = "lee_short1"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS|ARMS
	siemens_coefficient = 0.6

/obj/item/clothing/under/leeunder2
	name = "casual uniform"
	desc = "Good looking uniform. You see a label 'Made by Rorschash Ind.'."
	icon_state = "lee_short2"
	item_state = "bl_suit"
	worn_state = "lee_short2"

/obj/item/clothing/under/ajaxunder
	name = "ajax uniform"
	desc = "Black half-uniform. You see a label 'Made by Rorschash Ind.'."
	icon_state = "ajax_wear"
	item_state = "bl_suit"
	worn_state = "ajax_wear"

/obj/item/clothing/suit/leejacket
	name = "Black Jacket"
	desc = "Black Jacket. You see a label 'Made by Rorschash Ind.'."
	icon_state = "leejacket"
	item_state = "bl_suit"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS
	siemens_coefficient = 0.6

/obj/item/clothing/suit/warvest
	name = "Red Jacket"
	desc = "Red Jacket. You see a label 'Made by Rorschash Ind.'."
	var/base_icon_state = "warvest"
	var/open =1
	blood_overlay_type = "armor"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO

	update_icon()
		if(open)
			icon_state="[base_icon_state]_open"
		else
			icon_state="[base_icon_state]"

	verb/toggle()
		set name = "Toggle Red Jacket Buttons"
		set category = "Object"
		set src in usr

		if(!usr.canmove || usr.stat || usr.restrained())
			return 0

		if(open)
			usr << "You button up the jacket."
		else
			usr << "You unbutton the jacket."
		open=!open
		update_icon()
		usr.update_inv_wear_suit()

/obj/item/clothing/suit/warvest/New()
	. = ..()
	update_icon()


// Прочее

/obj/item/clothing/mask/gas/joker
	name = "joker mask"
	desc = "Why so serious?"
	icon_state = "jokermask"
	siemens_coefficient = 0.7

// Перенос с VG

// Sov-Nazi Rigs

/obj/item/clothing/head/helmet/space/rig/nazi
	name = "nazi hardhelmet"
	desc = "This is the face of das vaterland's top elite. Gas or energy are your only escapes."
	item_state = "rig0-nazi"
	icon_state = "rig0-nazi"
	species_restricted = list("exclude","Vox")//GAS THE VOX
	armor = list(melee = 40, bullet = 30, laser = 30, energy = 15, bomb = 35, bio = 100, rad = 20)

/obj/item/clothing/suit/space/rig/nazi
	name = "nazi hardsuit"
	desc = "The attire of a true krieger. All shall fall, and only das vaterland will remain."
	item_state = "rig-nazi"
	icon_state = "rig-nazi"
	slowdown = 1
	species_restricted = list("exclude","Vox")//GAS THE VOX
	armor = list(melee = 40, bullet = 30, laser = 30, energy = 15, bomb = 35, bio = 100, rad = 20)
	allowed = list(/obj/item/weapon/gun,/obj/item/device/flashlight,/obj/item/weapon/tank,/obj/item/weapon/melee/)

/obj/item/clothing/head/helmet/space/rig/soviet
	name = "soviet hardhelmet"
	desc = "Crafted with the pride of the proletariat. The vengeful gaze of the visor roots out all fascists and capitalists."
	item_state = "rig0-soviet"
	icon_state = "rig0-soviet"
	species_restricted = list("exclude","Vox")//HET
	armor = list(melee = 40, bullet = 30, laser = 30, energy = 15, bomb = 35, bio = 100, rad = 20)

/obj/item/clothing/suit/space/rig/soviet
	name = "soviet hardsuit"
	desc = "Crafted with the pride of the proletariat. The last thing the enemy sees is the bottom of this armor's boot."
	item_state = "rig-soviet"
	icon_state = "rig-soviet"
	slowdown = 1
	species_restricted = list("exclude","Vox")//HET
	armor = list(melee = 40, bullet = 30, laser = 30, energy = 15, bomb = 35, bio = 100, rad = 20)
	allowed = list(/obj/item/weapon/gun,/obj/item/device/flashlight,/obj/item/weapon/tank,/obj/item/weapon/melee/)

// Sov-Nazi Rigs

// Nazi Wearings

/obj/item/clothing/head/stalhelm
	name = "Stalhelm"
	desc = "Ein Helm, um die Nazi-Interesse an fremden Raumstationen zu sichern."
	icon_state = "stalhelm"
	item_state = "stalhelm"
	flags_inv = HIDEEARS

/obj/item/clothing/head/panzer
	name = "Panzer Cap"
	desc = "Ein Hut passen nur fьr die grцЯten Tanks."
	icon_state = "panzercap"
	item_state = "panzercap"

/obj/item/clothing/head/naziofficer
	name = "Officer Cap"
	desc = "Ein Hut von Offizieren in der Nazi-Partei getragen."
	icon_state = "officercap"
	item_state = "officercap"
	flags_inv = HIDEEARS

/obj/item/clothing/under/officeruniform
	name = "officer's uniform"
	desc = "Bestraft die Juden fur ihre Verbrechen."
	icon_state = "officeruniform"
	item_state = "officeruniform"
	worn_state = "officeruniform"

/obj/item/clothing/under/soldieruniform
	name = "soldier's uniform"
	desc = "Bestraft die Verbundeten fur ihren Widerstand."
	icon_state = "soldieruniform"
	item_state = "soldieruniform"
	worn_state = "soldieruniform"

/obj/item/clothing/suit/officercoat
	name = "Officer's Coat"
	desc = "Ein Mantel gemacht, um die Juden zu bestrafen."
	icon_state = "officersuit"
	item_state = "officersuit"

/obj/item/clothing/suit/soldiercoat
	name = "Soldier's Coat"
	desc = "Ein Mantel gemacht, um die Verbьndeten zu zerstцren."
	icon_state = "soldiersuit"
	item_state = "soldiersuit"

// Nazi Wearings

// Death Squad Rig

/obj/item/clothing/head/helmet/space/rig/deathsquad
	name = "deathsquad helmet"
	desc = "That's not red paint. That's real blood."
	icon_state = "rig0-deathsquad"
	item_state = "rig0-deathsquad"
	armor = list(melee = 65, bullet = 55, laser = 35,energy = 20, bomb = 40, bio = 100, rad = 60)
	siemens_coefficient = 0.2
	species_restricted = list("exclude","Vox")

/obj/item/clothing/suit/space/rig/deathsquad
	name = "deathsquad suit"
	desc = "A heavily armored suit that protects against a lot of things. Used in special operations."
	icon_state = "rig-deathsquad"
	item_state = "rig-deathsquad"
	allowed = list(/obj/item/weapon/gun,/obj/item/ammo_casing,/obj/item/weapon/melee/baton,/obj/item/weapon/handcuffs,/obj/item/weapon/tank/emergency_oxygen,/obj/item/weapon/tank/emergency_nitrogen,/obj/item/weapon/pinpointer,/obj/item/weapon/shield/energy,/obj/item/weapon/plastique,/obj/item/weapon/disk/nuclear)
	armor = list(melee = 80, bullet = 60, laser = 50,energy = 25, bomb = 60, bio = 100, rad = 60)
	siemens_coefficient = 0.5
	species_restricted = list("exclude","Vox")

// Death Squad Rig

// Batman Suit

/obj/item/clothing/head/batman
	name = "bathelmet"
	desc = "No one cares who you are until you put on the mask."
	icon_state = "bmhead"
	item_state = "bmhead"
	flags_inv = HIDEEARS|HIDEEYES|HIDEFACE

/obj/item/clothing/gloves/batmangloves
	desc = "Used for handling all things bat related."
	name = "batgloves"
	icon_state = "bmgloves"
	item_state = "bmgloves"

/obj/item/clothing/under/batmansuit
	name = "batsuit"
	desc = "You are the night."
	icon_state = "bmuniform"
	worn_state = "bmuniform"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO

/obj/item/clothing/shoes/jackboots/batmanboots
	name = "batboots"
	desc = "Criminal stomping boots for fighting crime and looking good."

// Batman Suit

// Roman Suit

/obj/item/clothing/head/helmet/roman
	name = "roman helmet"
	desc = "An ancient helmet made of bronze and leather."
	armor = list(melee = 20, bullet = 0, laser = 20, energy = 10, bomb = 10, bio = 0, rad = 0)
	icon_state = "roman"
	item_state = "roman"

/obj/item/clothing/head/helmet/roman/legionaire
	name = "roman legionaire helmet"
	desc = "An ancient helmet made of bronze and leather. Has a red crest on top of it."
	armor = list(melee = 25, bullet = 0, laser = 25, energy = 10, bomb = 10, bio = 0, rad = 0)
	icon_state = "roman_c"
	item_state = "roman_c"

/obj/item/clothing/under/roman
	name = "roman armor"
	desc = "An ancient Roman armor. Made of metallic strips and leather straps."
	icon_state = "roman"
	item_state = "armor"
	worn_state = "roman"
	armor = list(melee = 25, bullet = 0, laser = 25, energy = 10, bomb = 10, bio = 0, rad = 0)

/obj/item/clothing/shoes/roman
	name = "roman sandals"
	desc = "Sandals with buckled leather straps on it."
	icon_state = "roman"
	item_state = "roman"

// Roman Suit

// Russian Furr Wearings

/obj/item/clothing/suit/russofurcoat
	name = "russian fur coat"
	desc = "Let the land do the fighting for you."
	icon_state = "russofurcoat"
	item_state = "russofurcoat"
	allowed = list(/obj/item/weapon/gun)

/obj/item/clothing/head/russofurhat
	name = "russian fur hat"
	desc = "Russian winter got you down? Maybe your enemy, but not you!"
	icon_state = "russofurhat"
	item_state = "russofurhat"
	flags_inv = HIDEEARS

// Russian Furr Wearings

// Russian Bydlo Garments

/obj/item/clothing/under/squatter_outfit
	name = "slav squatter tracksuit"
	desc = "Cyka blyat."
	icon_state = "squatteroutfit"
	item_state = "squatteroutfit"
	worn_state = "squatteroutfir"

/obj/item/clothing/under/russobluecamooutfit
	name = "russian blue camo"
	desc = "Drop and give me dvadtsat!"
	icon_state = "russobluecamo"
	item_state = "russobluecamo"
	worn_state = "russobluecamo"

// Russian Bydlo Garments

// Custom-Items Garments

// Llego_Man007

/obj/item/clothing/gloves/hobbs
	name = "brown gloves"
	desc = "It seems to be ballistic."
	icon_state = "hobbsgloves"
	item_state = "browngloves"

/obj/item/clothing/under/hobbs
	name = "brown shirt"
	desc = "Is this what a 100 million buys? It wasnt that hard to find you, Toretto."
	icon_state = "hobbs"
	item_state = "lb_suit"
	worn_state = "hobbs"

/obj/item/clothing/suit/armor/bulletproof/hobbs
	name = "Special Bulletproof Vest"
	desc = "A vest that excels in protecting the wearer against high-velocity solid projectiles. Made by Hobb. Inc."
	icon_state = "hobbsarmor"
	item_state = "armor"
	blood_overlay_type = "armor"
	armor = list(melee = 10, bullet = 50, laser = 10, energy = 10, bomb = 0, bio = 0, rad = 0)

//Llego_Man007

//Kosteg

/obj/item/clothing/under/eisenhorn
	name = "white suit with waistcoat"
	desc = "It doesn't look inquisitorial."
	icon_state = "eisenhorn"
	item_state = "sl_suit"
	worn_state = "eisenhorn"

/obj/item/clothing/suit/eisenhorn
	name = "blue coat"
	desc = "It is looking inquisitorial."
	icon_state = "eisenhornsuit"
	item_state = "suit-command"

//Kosteg

//Mint

/obj/item/clothing/mask/bandana/mint
	name = "black bandana"
	desc = "From BSX with love."
	icon_state = "mintbandana"

//Mint

/obj/item/clothing/mask/happy
	name = "Happiest Mask"
	desc = "<span class=warning>\"I'm happy! I'M HAPPY! SEE! I SAID I'M HAPPY PLEASE DON'T\"<span>"
	icon_state = "happiest"
	item_state = "happiest"
	flags_inv = HIDEFACE
	w_class = 2
	siemens_coefficient = 3.0
	gas_transfer_coefficient = 0.90
	unacidable = 1
/*
/obj/item/clothing/mask/happy/equipped(M as mob, wear_mask)
	var/mob/living/carbon/human/H = M
	if(!istype(H)) return
	if(H.wear_mask == src)
		flick("happiest_flash", src)
		H << "<span class='sinister'>Your thoughts are bombarded by incessant laughter.</span>"
		H << sound('sound/effects/hellclown.ogg')
		canremove = 0

/obj/item/clothing/mask/happy/attack_hand(mob/user as mob)
	if(user.wear_mask == src)
		user << "<span class='sinister'>It won't come off.</span>"
		flick("happiest_flash", src)
	else
		..()

/obj/item/clothing/mask/happy/pickup(mob/user as mob)
	flick("happiest_flash", src)
	user << "<span class=warning>\b The mask's eyesockets briefly flash with a foreboding red glare.</span>"

/obj/item/clothing/mask/happy/OnMobLife(var/mob/living/carbon/human/wearer)
	var/mob/living/carbon/human/W = wearer
	if(W.wear_mask == src)
		RaiseShade(W)
	if(prob(5))
		switch(pick(1,2,3))
			if(1)
				W.say(pick("I'M SO HAPPY!", "SMILE!", "ISN'T EVERYTHING SO WONDERFUL?", "EVERYONE SHOULD SMILE!"))
			if(2)
				var/list/laughtypes = list("funny", "disturbing", "creepy", "horrid", "bloodcurdling", "freaky", "scary", "childish", "deranged", "airy", "snorting")
				var/laughtype = pick(laughtypes)
				W.visible_message("[W] makes \a [laughtype] laugh.")
			if(3)
				W.emote(pick("laugh", "chuckle", "giggle", "grin", "smile"))

/obj/item/clothing/mask/happy/OnMobDeath(var/mob/living/carbon/human/wearer)
	var/mob/living/carbon/human/W = wearer
	W.visible_message("<span class=warning>The mask lets go of [W]'s corpse.</span>")
	W.drop_from_inventory(src)
	flick("happiest_flash", src)
	canremove = 1

/obj/item/clothing/mask/happy/proc/RaiseShade(var/mob/living/carbon/human/H)
	for(var/mob/living/carbon/human/M in view(4, H))
		if(!M) return
		if(M.stat != 2) continue
		if(M.client == null) continue
		flick("happiest_flash", src)
		var/mob/living/simple_animal/shade/S = new /mob/living/simple_animal/shade( M.loc )
		S.name = "Shade of [M.real_name]"
		S.real_name = "Shade of [M.real_name]"
		if (M.client)
			M.client.mob = S
		S.cancel_camera()
		flick("happiest_flash", src)
		H << "<span class='sinister'>Oh joy! [M.real_name]'s decided to join the party!</span>"
		S << "<span class='sinister'>You have been given form by the power of the happiest mask! Go forth and cause joyful chaos for [H.real_name]!</span>"
*/

/obj/item/clothing/mask/chapmask
	name = "venetian mask"
	desc = "A plain porcelain mask that covers the entire face. Standard attire for particularly unspeakable religions. The eyes are wide shut."
	icon_state = "chapmask"
	item_state = "chapmask"
	flags_inv = HIDEFACE
	w_class = 2
	gas_transfer_coefficient = 0.90

/obj/item/clothing/shoes/kneesocks
	name = "kneesocks"
	desc = "A pair of girly knee-high socks"
	icon_state = "kneesock"
	item_state = "kneesock"

/obj/item/clothing/suit/blackjacket
	name = "black coat"
	desc = "An executive black coat. Seems to be made from real leather."
	icon_state = "blackleather"

// Camo

/obj/item/clothing/under/greycamo
	name = "grey camouflage"
	desc = "Military grade."
	icon_state = "greycamo"
	item_state = "gy_suit"
	worn_state = "greycamo"

/obj/item/clothing/under/bluecamo
	name = "dark-blue camouflage"
	desc = "Military grade."
	icon_state = "bluecamo"
	item_state = "b_suit"
	worn_state = "bluecamo"

/obj/item/clothing/under/greencamo
	name = "dark-green camouflage"
	desc = "Military grade."
	icon_state = "greencamo"
	worn_state = "greencamo"

// Camo

// Captain

/obj/item/clothing/under/rank/captain/fancy
	name = "fancy captain uniform"
	desc = "Luxury white captain uniform"
	icon_state = "caplux"
	item_state = "w_suit"
	worn_state = "caplux"

/obj/item/clothing/under/rank/captain/casual
	name = "worn captain uniform"
	desc = "Good looking uniform made for using it everyday."
	icon_state = "casualcap"
	item_state = "b_suit"
	worn_state = "casualcap"

// Captain

// Security Uni-2

/obj/item/clothing/under/rank/security3
	name = "security officer's jumpsuit"
	desc = "It's made of a slightly sturdier material than standard jumpsuits, to allow for robust protection."
	icon_state = "secuni3"
	item_state = "r_suit"
	worn_state = "secuni3"

/obj/item/clothing/under/rank/warden2
	name = "warden's jumpsuit"
	desc = "It's made of a slightly sturdier material than standard jumpsuits, to allow for more robust protection. It has the word Warden written on the shoulders."
	icon_state = "warden2"
	item_state = "r_suit"
	worn_state = "warden2"

/obj/item/clothing/under/rank/hos2
	name = "head of security's uniform"
	desc = "It's a jumpsuit worn by those few with the dedication to achieve the position of Head of Security. It has additional armor to protect the wearer."
	icon_state = "hos2"
	item_state = "r_suit"
	worn_state = "hos2"

// Security Uni-2

// Fancy Suits

/obj/item/clothing/under/fancyred
	name = "fancy suit"
	desc = "Luxury suit with red tie."
	icon_state = "fancysuitred"
	item_state = "ro_suit"
	worn_state = "fancysuitred"

/obj/item/clothing/under/fancyblue
	name = "fancy suit"
	desc = "Luxury suit with blue tie."
	icon_state = "fancysuitblue"
	item_state = "ro_suit"
	worn_state = "fancysuitblue"

// Fancy Suits

// Dresses

/obj/item/clothing/under/reddress
	name = "fancy dress"
	desc = "Luxury red dress."
	icon_state = "reddress"
	item_state = "r_suit"
	worn_state = "reddress"

/obj/item/clothing/under/blackdress
	name = "fancy dress"
	desc = "Luxury black dress."
	icon_state = "blackdress"
	item_state = "bl_suit"
	worn_state = "blackdress"

// Dresses

// Special CentComm Suits

/obj/item/clothing/under/rank/centcom/luxury
	name = "officer's suit"
	desc = "Gold trim on space-black cloth, this uniform displays the rank of Captain."
	icon_state = "officersuit2"
	item_state = "bl_suit"
	worn_state = "officersuit2"

/obj/item/clothing/under/rank/centcom/luxury2
	name = "officer's suit"
	desc = "Gold trim on space-black cloth, this uniform displays the rank of Captain."
	icon_state = "officersuit3"
	item_state = "bl_suit"
	worn_state = "officersuit3"

// Special CentComm Suits

/obj/item/clothing/under/det/forensics
	name = "white suit"
	desc = "White suit with blue tie. Gold badge with signs on it - 1247."
	icon_state = "forensicsuit"
	item_state = "br_suit"
	worn_state = "forensicsuit"

/obj/item/clothing/under/wintersuit
	name = "labcoat suit"
	desc = "Special white labcoat suit."
	icon_state = "labcoatsuit"
	item_state = "w_suit"
	worn_state = "labcoatsuit"


// King

/obj/item/clothing/under/king
	name = "medieval clothes"
	desc = "Hodor?"
	icon_state = "kinglux"
	worn_state = "kinglux"

/obj/item/clothing/suit/kingcoat
	name = "medieval coat"
	desc = "Hodor?"
	icon_state = "kingcoat"

/obj/item/clothing/shoes/king
	name = "medieval boots"
	desc = "It seems they belong to the old age."
	icon_state = "kingshoes"

/obj/item/clothing/head/crown
	name = "golden crown"
	desc = "Glory to the King!"
	icon_state = "crown"

// King

// Lunasmen

/obj/item/clothing/under/lunasmen
	name = "white suit"
	desc = "Usual white suit."
	icon_state = "lunassuit"
	item_state = "ba_suit"

/obj/item/clothing/mask/lunasmen
	name = "white mask"
	desc = "Strange white mask."
	icon_state = "lunasmask"

// Lunasmen

// Maidsuit

/obj/item/clothing/under/maid1
	name = "Maid suit"
	desc = "Is it from that old island country located in East?"
	icon_state = "maids1"
	item_state = "ba_suit"
	worn_state = "maids1"

/obj/item/clothing/under/maid2
	name = "Maid suit"
	desc = "Is it from that old island country located in East? Red tie is attached to it."
	icon_state = "maids2"
	item_state = "ba_suit"
	worn_state = "maids2"

// Maidsuit

/obj/item/clothing/under/militarysuit
	name = "Military suit"
	desc = "Military grade."
	icon_state = "milsuit"

// Marine Armor

/obj/item/clothing/suit/armor/marine
	name = "Marine Armor"
	desc = "A suit of armor with heavy padding to protect against damage. However, they seems to be not heavy at all. Military grade."
	icon_state = "marinearmor"
	item_state = "swat_suit"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS|ARMS
	armor = list(melee = 50, bullet = 50, laser = 50, energy = 50, bomb = 25, bio = 10, rad = 10)
	flags_inv = HIDEJUMPSUIT
	siemens_coefficient = 0.5

/obj/item/clothing/head/helmet/marine
	name = "Marine Helmet"
	desc = "It's a helmet specifically designed to protect against any attacks. Military grade."
	icon_state = "marinehelmet"
	body_parts_covered = HEAD
	armor = list(melee = 50, bullet = 50, laser = 50, energy = 50, bomb = 25, bio = 10, rad = 10)
	flags_inv = HIDEEARS
	siemens_coefficient = 0.7

// Marine Armor

/obj/item/clothing/suit/sovietcoat
	name = "black coat"
	desc = "Black coat made of hard leather. You didn't find any sign of companies on it."
	icon_state = "sovietcoat"
	item_state = "bl_suit"
	flags_inv = HIDEJUMPSUIT

/obj/item/clothing/suit/germancoat
	name = "grey coat"
	desc = "Grey coat with strange marks inside it."
	icon_state = "germancoat"
	item_state = "bl_suit"
	flags_inv = HIDEJUMPSUIT

/obj/item/clothing/mask/gas/security
	name = "\improper security mask"
	desc = "A close-fitting tactical mask that can be connected to an air supply."
	icon_state = "secmask"
	siemens_coefficient = 0.7
	body_parts_covered = FACE|EYES