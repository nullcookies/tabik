#{icon('pencil2')} Введите *код подтверждения* платежа.
****
btns = []
more_buts = []
more_buts << icon('dollar', 'Оплатить с баланса') if @buts[:balance_btn]
more_buts << icon('hand', 'Взять') if @buts[:take_free_btn]
more_buts << icon('eyes', 'Посмотреть') if @buts[:view_free_btn]
btns << more_buts << [icon(@tsx_bot.icon_cancel, 'Отменить'), btn_main] << [icon(@tsx_bot.icon_payments, 'Как платить?')]
btns
