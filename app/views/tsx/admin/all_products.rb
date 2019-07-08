Выберите продукт из общего списка.
****
buts ||= []
buts = keyboard(@products, 3) do |rec|
  button("#{icon(rec[:icon])} #{rec[:russian]}", rec[:id])
end
if @products.current_page == 1
  buts <<
      [
          button("#{icon('arrow_forward')} Вперед", 'admin_view_next_products_page')
      ]
elsif @products.page_count == @products.current_page
  buts <<
      [
          button("#{icon('arrow_left')} Назад", 'admin_view_prev_products_page'),
      ]
else
  buts <<
      [
          button("#{icon('arrow_left')} Назад", 'admin_view_prev_products_page'),
          button("#{icon('arrow_forward')} Вперед", 'admin_view_next_products_page')
      ]
end
buts <<
[
    button("#{icon('clipboard')} К списку бота", 'back_to_bot_products'),
]

