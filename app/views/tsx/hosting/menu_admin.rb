🏬 *Склад Бот*
`v#{Version.current}`

Кладмен #{icon('id')} *#{hb_client.id}*
Загружено *#{kladov(hb_client.klads_uploaded)}*
Не найдено *#{kladov(hb_client.klads_not_found)}*
Штрафов *#{@tsx_bot.amo(hb_client.kladman_fines)}*
Выплачено *#{@tsx_bot.amo(hb_client.kladman_paid)}*
К выплате *#{@tsx_bot.amo(hb_client.kladman_debt)}*
****
hosting_buttons