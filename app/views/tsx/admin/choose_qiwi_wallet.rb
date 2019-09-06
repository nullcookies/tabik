#{icon('pouch')} *Кошельки Qiwi*

Добавляйте сколько угодно Qiwi кошельков. Активный может быть один. Нажмите на любой из кошельков, чтобы упралять им или посмотреть сегодняшние платежи.
****
buts ||= []
wallets = Qiwi.where(bot: @tsx_bot.id).order(:id)
buts = keyboard(wallets, 3) do |rec|
  wallet = Qiwi[rec[:id]]
  button("#{wallet.active == 1 ? icon('large_blue_circle') : icon('white_circle')} #{rec[:phone]}", rec[:id])
end
buts <<
  [
    button("Добавить кошелек", 'enter_qiwi_phone'),
  ]

