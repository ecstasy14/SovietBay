// This system defines news that will be displayed in the course of a round.
// Uses BYOND's type system to put everything into a nice format

/datum/news_announcement
	var
		round_time // time of the round at which this should be announced, in seconds
		message // body of the message
		author = "NanoTrasen Editor"
		channel_name = "Nyx Daily"
		can_be_redacted = 0
		message_type = "Story"

	revolution_inciting_event

		paycuts_suspicion
			round_time = 60*10
			message = {"С перехваченных у НТ отчетов вы&#255;снено, что они планируют урезать разплату на многих исследовательских
			станци&#255;х в системе Тау Цети.Очевидно, что эти станции не дали ожидаемый доход и поэтому сокращени&#255; зарплат
			скорее всего пройдут."}
			author = "Unauthorized"

		paycuts_confirmation
			round_time = 60*40
			message = {"Ранее опубликованные слухи о понижении зарплаты на исследовательских станци&#255;х в системете Тау Цети
			были подтверждены. Шокирующе так же, что сокращение зарплат касаетс&#255; только "низкосортного" персонала.
			Глав это касатьс&#255; не будет."}
			author = "Unauthorized"

		human_experiments
			round_time = 60*90
			message = {"Неверо&#255;тные отчеты об экспериментах над людьми достигли наших ушей. По словам беженца с одной
						станции из Tau Ceti. С целью увеличени&#255; доходов, НТ проводит эксперименты над живыми людьми
						в том числе воздейтвие различных вирусов, генетических экспериментов и кормёжки слизн&#255;ми дл&#255; того что
						бы посмотреть что с ними потом будет. Якобы, эти испытуемые не были ни гуманизированные обезь&#255;ны,
						ни добровольцы, а скорее неквалифицированный персонал, которые были вынуждены учавствовать
						в экспериментах, и по сообщени&#255;м погибли в следствии "несчастного случа&#255;"."}
			author = "Unauthorized"

	bluespace_research

		announcement
			round_time = 60*20
			message = {"Новое направление научных исследований по изучению подпространства или так же известного "Голубого
						пространства" достигла новых высот.Из ста космических станций в насто&#255;щее врем&#255; на орбите в системе
						Тау Кита, п&#255;тнадцать теперь имеют специальное оборудование дл&#255; экспериментов с эффектами подпространства
						и исследовани&#255; его. По слухам, некоторые из них имеют даже "Путеводные ворота". Они позвол&#255;ют перемещатьс&#255;
						между реальност&#255;ми, тоесть в другие измерени&#255;."}

	random_junk

		cheesy_honkers
			author = "Assistant Editor Carl Ritz"
			channel_name = "The Gibson Gazette"
			message = {"Сырные гудки увеличивают риск выкидыша? Множество центров здравоохранени&#255; говор&#255;т "Нет!"}
			round_time = 60 * 15

		net_block
			author = "Assistant Editor Carl Ritz"
			channel_name = "The Gibson Gazette"
			message = {"Несколько корпораций объедин&#255;ютс&#255; дл&#255; блокировки сайта wetskrell.nt, администраци&#255; сайта это
						считает нарушением закона."}
			round_time = 60 * 50

		found_ssd
			channel_name = "Nyx Daily"
			author = "Doctor Eric Hanfield"

			message = {"Множество людей были обнаружены возле своих терминалов без сознани&#255;.
						Считаетс&#255;, что это произошло из-за недостатка сна или просто от мигреней, гл&#255;д&#255; на
						экран слишком долго. Кадры камеры показывает, что многие из них играли в игры вместо
						работы. И их зарплата была составлена соответствующим образом."}
			round_time = 60 * 90

	lotus_tree

		explosions
			channel_name = "Nyx Daily"
			author = "Reporter Leland H. Howards"

			message = {"Новый гражданский транспорт Древо Лотоса пострадал от двух больших взрывов возле мостика
						сегодн&#255;, и есть неподтвержденные сообщени&#255; о том, что число погибших превысило 50 членов экипажа.
						Причина взрывов остаётс&#255; неизвестной, но есть предположение, что это может иметь св&#255;зь с недавними
						изменени&#255; в корпорации  Мип-Ли, крупной финансистки корабл&#255;, когда МЛ объ&#255;вили, что официально
						признали межрасовые браки и предоставление таким парам различных льгот."}
			round_time = 60 * 30

	food_riots

		breaking_news
			channel_name = "Nyx Daily"
			author = "Reporter Ro'kii Ar-Raqis"

			message = {"Последние новости: "Пищевые бунты" разразились  по всей колонии астероида убежище в
						системе Тенебрейт Люпус. Это произошло всего через несколько часов после того как чиновники НТ
						объ&#255;вили, что торговать с колонией не будут, ссыла&#255;сь на увеличение присутстви&#255; враждебных
						группировок, из-за чего с колонией торговать стало слишком опасно. Чиновники НТ не дали никаких
						подробностей о данных группировках."}
			round_time = 60 * 10

		more
			channel_name = "Nyx Daily"
			author = "Reporter Ro'kii Ar-Raqis"

			message = {"Подробнее о пищевых беспор&#255;дках в убежище: Совет Убежища осудил вывод НТ из колонии,
						утвержда&#255;: "Не было никакого усилени&#255; активности анти-НТ группировок", и "Причиной &#255;вл&#255;етс&#255; то,
						что в системе Тенебрейт Люпус полностью истощены запасы Форона. У нас есть немного Форона, чтобы
						торговать с ними в насто&#255;щее врем&#255; ". Чиновники НТ отрицают эти обвинени&#255;, называ&#255; их "еще одним
						доказательством" анти-НТ настроений в колонии. В то же врем&#255;, СБ убежища не смогли подавить
						беспор&#255;дки. Более подробно об этом в 6."}
			round_time = 60 * 60


var/global/list/newscaster_standard_feeds = list(/datum/news_announcement/bluespace_research, /datum/news_announcement/lotus_tree, /datum/news_announcement/random_junk,  /datum/news_announcement/food_riots)

proc/process_newscaster()
	check_for_newscaster_updates(ticker.mode.newscaster_announcements)

var/global/tmp/announced_news_types = list()
proc/check_for_newscaster_updates(type)
	for(var/subtype in typesof(type)-type)
		var/datum/news_announcement/news = new subtype()
		if(news.round_time * 10 <= world.time && !(subtype in announced_news_types))
			announced_news_types += subtype
			announce_newscaster_news(news)

proc/announce_newscaster_news(datum/news_announcement/news)
	var/datum/feed_channel/sendto
	for(var/datum/feed_channel/FC in news_network.network_channels)
		if(FC.channel_name == news.channel_name)
			sendto = FC
			break

	if(!sendto)
		sendto = new /datum/feed_channel
		sendto.channel_name = news.channel_name
		sendto.author = news.author
		sendto.locked = 1
		sendto.is_admin_channel = 1
		news_network.network_channels += sendto

	var/author = news.author ? news.author : sendto.author
	news_network.SubmitArticle(news.message, author, news.channel_name, null, !news.can_be_redacted, news.message_type)
