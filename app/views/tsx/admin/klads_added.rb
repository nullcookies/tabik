#{icon('white_check_mark')} Клады добавлены.
****
buts ||= []
buts = keyboard(@products, 2) do |rec|
  button("#{icon(rec[:icon])} #{rec[:russian]}", rec[:prod])
end
