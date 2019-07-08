#{icon('bar_chart')} *Общая статистика*

Бот [@#{@tsx_bot.tele + (@tsx_bot.underscored_name == 1 ? "_bot": "bot")}](http://t.me/#{@tsx_bot.tele + (@tsx_bot.underscored_name == 1 ? "_bot": "bot")})
Номер бота *#{@tsx_bot.id}*
Клиентов *#{@tsx_bot.bot_clients.count}*
Баланс *#{@tsx_bot.amo(@tsx_bot.beneficiary.rent_cash)}*
К выплате *#{@tsx_bot.debt_in_btc} BTC*
Погашение *#{human_date(@tsx_bot.paid + 1.month)}*

Всего *#{kladov(@tsx_bot.all_items)}*
На продаже *#{kladov(@tsx_bot.active_items)}*
Продано *#{kladov(@tsx_bot.sold_items)}*
Зарезервировано *#{kladov(@tsx_bot.reserved_items)}*
Сегодня *#{@tsx_bot.today_bot_sales(Date.today)}* на *#{@tsx_bot.amo(@tsx_bot.today_income(Date.today))}*
#{share_stat if @tsx_bot.has_shares?}
****
[[button('Погасить долг', 'admin_pay_debt')]]