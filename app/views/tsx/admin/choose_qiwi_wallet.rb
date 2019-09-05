#{icon('pouch')} *Кошельки*

Добавляйте сколько угодно Easypay кошельков. Активный может быть один. Нажмите на любой из кошельков, чтобы упралять им или посмотреть сегодняшние платежи.
****
buts ||= []
wallets = Wallet.where(bot: @tsx_bot.id).order(:id)
buts = keyboard(wallets, 3) do |rec|
  wallet = Wallet[rec[:id]]
  button("#{wallet.active == 1 ? icon('large_blue_circle') : icon('white_circle')} #{rec[:keeper]}", rec[:id])
end
buts <<
  [
    button("Добавить кошелек", 'enter_keeper'),
  ]

