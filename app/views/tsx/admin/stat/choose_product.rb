Выберите продукт из города *#{@city.russian}*, чтобы посмотреть остатки.
****
buts ||= []
buts = keyboard(@products, 4) do |rec|
  button("#{icon("#{rec[:entity_icon]}")} #{rec[:entity_russian]}", rec[:entity_id])
end
buts << [button('Другой город', 'stat_choose_city')]