#{icon('euro')} *Последние платежи*

#{list_today_payments(@payments)}
****
  [
    [
      button('Обновить', 'today_payments')
    ],
    [
      button("Назад к кошелькам", 'back_to_wallets')
    ]
  ]
