#define GENERAL_STOCK 30
#define SPECIAL_STOCK 20

/obj/machinery/vending/mechcomp
	name = "MechComps dispenser"
	desc = "Go haywire."
	products = list(	/obj/item/mechcomp/andcomp = GENERAL_STOCK,
						/obj/item/mechcomp/button = GENERAL_STOCK,
						/obj/item/mechcomp/check = GENERAL_STOCK,
						/obj/item/mechcomp/delaycomp = GENERAL_STOCK,
						/obj/item/mechcomp/graviton = GENERAL_STOCK,
						/obj/item/mechcomp/handscanner = GENERAL_STOCK,
						/obj/item/mechcomp/led = GENERAL_STOCK,
						/obj/item/mechcomp/mic = GENERAL_STOCK,
						/obj/item/mechcomp/orcomp = GENERAL_STOCK,
						/obj/item/mechcomp/paperscan = GENERAL_STOCK,
						/obj/item/mechcomp/payment = GENERAL_STOCK,
						/obj/item/mechcomp/pressure = GENERAL_STOCK,
						/obj/item/mechcomp/printer = GENERAL_STOCK,
						/obj/item/mechcomp/radiocomp = GENERAL_STOCK,
						/obj/item/mechcomp/relay = GENERAL_STOCK,
						/obj/item/mechcomp/selectcomp = GENERAL_STOCK,
						/obj/item/mechcomp/sigbuilder = GENERAL_STOCK,
						/obj/item/mechcomp/synthcomp = GENERAL_STOCK,
						/obj/item/mechcomp/toggle = GENERAL_STOCK)

	contraband = list(	/obj/item/mechcomp/teleporter = SPECIAL_STOCK,
						/obj/item/mechcomp/graviton/advanced = SPECIAL_STOCK)

#undef SPECIAL_STOCK
#undef GENERAL_STOCK
