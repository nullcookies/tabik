🏬 *Склад Бот*
`v#{Version.current}`

Кладмен #{icon('id')} *#{hb_client.id}*
Остатки *#{kladov(hb_client.rest - hb_client.klads_uploaded)}*
Загружено *#{kladov(hb_client.klads_uploaded)}*
Штрафов *#{@tsx_bot.amo(hb_client.kladman_fines)}*
Выплачено *#{@tsx_bot.amo(hb_client.kladman_paid)}*
К выплате *#{@tsx_bot.amo(hb_client.kladman_debt - hb_client.kladman_paid - hb_client.kladman_fines)}*
****
hosting_buttons