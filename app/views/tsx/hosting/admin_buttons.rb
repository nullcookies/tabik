🏬 *Склад Бот*
`v#{Version.current}`

Админ #{icon('id')} *#{hb_client.id}*
Сотрудников *#{ludey(@master.kladmans.count)}*
Всего кладов *#{@master.all_items}*
Общий долг *#{kladov(hb_client.klads_not_found)}*
Всего выплачено *#{@tsx_bot.amo(hb_client.kladman_debt)}*
****
hosting_admin_buttons