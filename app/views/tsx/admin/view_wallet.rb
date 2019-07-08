Номер кошелька *#{@wallet.keeper}*
Номер внутреннего кошелька *#{@wallet.wallet}*
Номер телефона *#{@wallet.phone}*
Пароль *#{@wallet.password}*
Статус *#{@wallet.active == 1 ? icon('large_blue_circle') : icon('white_circle') } #{@wallet.active == 1 ? 'Активен' : 'Неактивен'}*
****
if @wallet.active == 0
  [
    [
      button('Сегодняшние платежи', 'today_payments')
    ],
    [
      button('Активировать', 'activate_wallet'),
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

