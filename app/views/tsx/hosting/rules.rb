*Заливатор*
`v#{Version.current}`

Кладмен #{icon('id')} *#{hb_client.id}*
Бот #{icon('b')} *#{hb_client[:master]}*
Баланс *#{@tsx_bot.amo(hb_client.available_cash)}*
Кладов *#{hb_client.buy_trades([Trade::FINALIZED, Trade::FINISHED]).count}* на *#{@tsx_bot.amo(hb_client.buy_trades([Trade::FINALIZED, Trade::FINISHED]).sum(:price))}* #{"\nПродаж *#{hb_client.sell_trades([Trade::FINALIZED, Trade::FINISHED]).count}* на *#{@tsx_bot.amo(hb_client.sell_trades([Trade::FINALIZED, Trade::FINISHED]).sum(:price))}*" if @sh}
Рефералов *#{ludey(hb_client.client_referals)}*
Заработано *#{@tsx_bot.amo(hb_client.ref_cash)}*
#{"Поддержка" if !@tsx_bot.support.nil?} #{@tsx_bot.support_line if !@tsx_bot.support.nil?}
****
hosting_buttons