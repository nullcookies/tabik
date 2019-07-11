#{icon(@product[:icon])} *#{@product.russian}*, *#{kladov(@item_count)}*.
#{City[@district.city].russian}, #{@district.russian}.

#{icon('grey_exclamation')} Действует акция `-#{@tsx_bot.discount}%` на клады старше *#{dney(@tsx_bot.discount_period)}*. Акционные клады помечены значком #{icon(@tsx_bot.icon_old)}.
****
cur = @tsx_bot.get_var('currency')
lab = "грн."
buts = keyboard(@items, 2) do |item|
  "#{item.price_string("UAH", 'грн.')} #{item.id}"
end
buts << [btn_back, btn_main, btn_add_item, btn_transfer]-[nil]
