#{icon('euro')} *Последние платежи*

#{list_today_qiwi_payments(@payments)}
****
  [
    [
      button('Обновить', 'today_qiwi_payments')
    ],
    [
      button("Назад к кошелькам", 'back_to_qiwi_wallets')
    ]
  ]
