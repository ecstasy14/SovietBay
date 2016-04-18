//Basically, a big signaler

/obj/item/mechcomp/radiocomp
	name = "Radio component"
	desc = "Major Tom to Ground Control..."

	icon_state = "comp_radiosig"

	var/code = 30
	var/frequency = 1457
	var/datum/radio_frequency/radio_connection

/obj/item/mechcomp/radiocomp/New()
	..()
	handler.addInput("set code", "code")
	handler.addInput("set frequency", "freq")
	handler.addInput("send", "send")
	set_frequency(1457)

/obj/item/mechcomp/radiocomp/proc/code(var/signal)
	code = round(text2num(signal))
	code = min(100, src.code)
	code = max(1, src.code)

/obj/item/mechcomp/radiocomp/proc/freq(var/signal)
	var/new_frequency = round(text2num(signal))
	if(new_frequency < RADIO_LOW_FREQ || new_frequency > RADIO_HIGH_FREQ)
		new_frequency = sanitize_frequency(new_frequency, RADIO_LOW_FREQ, RADIO_HIGH_FREQ)
	set_frequency(frequency)

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
	radio_connection = radio_controller.add_object(src, frequency, RADIO_CHAT)