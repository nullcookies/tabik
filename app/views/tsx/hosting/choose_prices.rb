Выберите фасовку.
****
buts ||= []
buts = keyboard(@prices, 4) do |rec|
  p = Price[rec[:id]]
  button("#{p.qnt} за #{@tsx_bot.amo(p.price)}", rec[:id])
end
