🏬 *Склад Бот*
`v#{Version.current}`

Кладмен #{icon('id')} *#{hb_client.id}*
К выплате *#{@tsx_bot.amo(hb_client.ref_cash)}*
Выплачено *670 грн.*
#{"Поддержка" if !@tsx_bot.support.nil?} #{@tsx_bot.support_line if !@tsx_bot.support.nil?}
****
hosting_buttons