#{icon('beginner')} *Загрузка кладов*

Чтобы загрузить клады, Вы должны будете выбрать последовательно город, район, продукт и фасовку. Начните с города.
****
buts ||= []
@avlbl = City.where(country: @tsx_bot.get_var('country'))
buts = keyboard(@avlbl, 4) do |rec|
  button("#{rec[:russian]}", rec[:id])
end
