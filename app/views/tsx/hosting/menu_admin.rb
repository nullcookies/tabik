🏬 *Склад Бот*
`v#{Version.current}`

Админ #{icon('id')} *#{hb_client.id}*
Бот *#{@master.title}*
Сотрудников *#{ludey(@master.kladmans.count)}*
Всего *#{kladov(@master.all_items)}*
Общий долг *#{kladov(hb_client.klads_not_found)}*
Всего выплачено *#{@tsx_bot.amo(hb_client.kladman_debt)}*
****
buts ||= []
buts = keyboard(@kladmans, 1) do |rec|
  button("#{rec[:id]} / #{rec[:username]}", rec[:id])
end