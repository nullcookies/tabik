Номер телефона *#{@wallet.phone}*
Токен *#{@wallet.token}*
Статус *#{@wallet.active == 1 ? icon('large_blue_circle') : icon('white_circle') } #{@wallet.active == 1 ? 'Активен' : 'Неактивен'}*
****
if @wallet.active == 0
  [
    [
      button('Сегодняшние платежи', 'today_qiwi_payments')
    ],
    [
      button('Активировать', 'activate_qiwi_wallet'),
      button('Удалить', 'sure_delete')
    ],
    [
      button("Назад к кошелькам", 'back_to_qiwi_wallets')
    ]
  ]
else
  [
      [
          button('Сегодняшние платежи', 'today_qiwi_payments')
      ],
      [
          button('Удалить', 'sure_delete')
      ],
      [
          button("Назад к кошелькам", 'back_to_qiwi_wallets')
      ]
  ]
end

