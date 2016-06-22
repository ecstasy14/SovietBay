//Basically, a big signaler

//TODO : add a receiver

/obj/item/mechcomp/radiocomp
	name = "Radio component"
	desc = "Major Tom to Ground Control..."

	icon_state = "comp_radiosig"

	var/code = 30
	var/frequency = 1457
	var/datum/radio_frequency/radio_connection

/obj/item/mechcomp/radiocomp/New()
	..()
	handler.add_input("set code", "code")
	handler.add_input("set frequency", "freq")
	handler.add_input("send", "send")
	spawn(40)
		set_frequency(1457)

/obj/item/mechcomp/radiocomp/proc/code(signal)
	code = round(text2num(signal))
	code = min(100, src.code)
	code = max(1, src.code)

/obj/item/mechcomp/radiocomp/proc/freq(signal)
	//For user input
	var/new_frequency = signal
	//For mechcomps input
	if(!isnum(signal))
		new_frequency = round(text2num(signal))
	if(new_frequency < RADIO_LOW_FREQ || new_frequency > RADIO_HIGH_FREQ)
		new_frequency = sanitize_frequency(new_frequency, RADIO_LOW_FREQ, RADIO_HIGH_FREQ)
	set_frequency(new_frequency)

/obj/item/mechcomp/radiocomp/proc/send(var/signal)
	if(signal != handler.trigger_signal)
		return

	if(!radio_connection)
		return

	var/datum/signal/radio_signal = new
	radio_signal.source = src
	radio_signal.encryption = code
	radio_connection.post_signal(src, radio_signal)

/obj/item/mechcomp/radiocomp/proc/set_frequency(var/new_frequency)
	radio_controller.remove_object(src, frequency)
	frequency = new_frequency
	radio_connection = radio_controller.add_object(src, frequency)

/obj/item/mechcomp/radiocomp/receive_signal(datum/signal/signal)
	if(!signal)
		return 0
	if(signal.encryption != code)
		return 0

	handler.send_signal()

/obj/item/mechcomp/radiocomp/get_settings(source)
	var/dat = "<B>Radio component settings:</B><BR>"
	dat += "Code : <A href='?src=\ref[source];radio_action=set_code'>[code]</A><BR>"
	dat += "Frequency : <A href='?src=\ref[source];radio_action=set_freq'>[frequency]</A><BR>"
	return dat

/obj/item/mechcomp/radiocomp/set_settings(href, href_list, user)
	if(href_list["radio_action"])
		switch(href_list["radio_action"])
			if("set_code")
				var/new_code = input(user, "Enter a new code (1-100):", "Set code", code) as num
				code(new_code)
			if("set_freq")
				var/new_freq = input(user, "Enter a new frequency (without any dots):", "Set frequency", frequency) as num
				freq(new_freq)


		return MT_REFRESH