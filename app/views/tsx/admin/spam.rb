#{icon('incoming_envelope')} *Рассылки*

Создавайте автоматические или одноразовые рассылки клиентам бота.

#{icon('information_source')} Обратите внимание, что рассылки отправляются раз в 5 минут в порядке общей очереди.
****
buts ||= []
@spam = Spam.where(bot: @tsx_bot.id)
buts = keyboard(@spam, 1) do |rec|
  s = Spam[rec[:id]]
  if s.auto == 1
    button("🌀 #{rec[:text]}", rec[:id])
  else
    button("#{s.status == Spam::NEW ? icon('hourglass') : icon('white_check_mark')} #{rec[:text]}", rec[:id])
  end
end
buts << [
     button('Создать одноразовую', 'admin_create_spam'),
     button('Создать автоматическую', 'admin_create_auto_spam'),
]
buts