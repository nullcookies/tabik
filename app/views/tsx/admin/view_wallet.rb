Номер кошелька *#{@wallet.keeper}*
Номер внутреннего кошелька *#{@wallet.wallet}*
Номер телефона *#{@wallet.phone}*
Пароль *#{@pass}*
Статус *#{@wallet.active == 1 ? icon('large_blue_circle') : icon('white_circle') } #{@wallet.active == 1 ? 'Активен' : 'Неактивен'}*
Дополнительный? *#{@wallet.secondary == 1 ? icon('electric_plug') : icon('no_entry_sign') } #{@wallet.secondary == 1 ? 'Да' : 'Нет'}*
****
if @wallet.secondary == 1
  [
      [
          button('Сегодняшние платежи', 'today_payments')
      ],
      [
          button('Убрать из дополнительных', 'remove_from_secondary'),
      ],
      [
          button("Назад к кошелькам", 'back_to_wallets')
      ]
  ]
elsif @wallet.active == 0
  [
    [
      button('Сегодняшние платежи', 'today_payments')
    ],
    [
      button('Активировать', 'activate_wallet'),
      button('Сделать дополнительным', 'set_secondary'),
    ],
    [
        button('Удалить', 'sure_delete')
    ],
    [
      button("Назад к кошелькам", 'back_to_wallets')
    ]
  ]
else
  [
      [
          button('Сегодняшние платежи', 'today_payments')
      ],
      [
          button('Удалить', 'sure_delete')
      ],
      [
          button("Назад к кошелькам", 'back_to_wallets')
      ]
  ]
end

