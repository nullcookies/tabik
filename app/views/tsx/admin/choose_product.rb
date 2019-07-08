Выберите продукт.
****
buts ||= []
buts = keyboard(@products, 2) do |rec|
  button("#{icon(rec[:icon])} #{rec[:russian]}", rec[:prod])
end
