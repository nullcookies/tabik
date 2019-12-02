#{icon(@product.icon)} *#{@product.russian}*

Ссылка на картнику #{@picture}

#{icon('grey_exclamation')} Обратите внимение, что удалить цены невозможно, так как они привязаны к существующим кладам. Цены можно *только изменить*.
****
buts ||= []
buts = keyboard(@prices, 2) do |rec|
  pr = Price[rec[:id]]
  button("#{pr.qnt} #{@tsx_bot.amo(pr.price)} ", rec[:id])
end
buts <<
    [
      button('Загрузить картинку', 'admin_ask_product_picture'),
      button('Добавить фасовку', 'enter_qnt'),
    ] <<
    [
        button('Назад к продуктам', 'back_to_bot_products')
    ]
