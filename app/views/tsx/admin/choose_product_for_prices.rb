#{icon('1234')} *Установка цен*

Выберите продукт, на который Вы хотите *поменять* или *установить новые* цены.

#{@discount_string}

#{icon('grey_exclamation')} Если Вы хотите добавить в бот новый продукт и цены, нажмите `Добавить продукт`.
****
buts ||= []
buts = keyboard(@products, 2) do |rec|
  puts rec.inspect
  button("#{icon(rec[:icon])} #{rec[:russian]}", rec[:prod])
end
buts <<
    [
        button('Добавить продукт', 'admin_choose_all_products'),
        button('Настроить скидки', 'enter_discount_period')
    ]