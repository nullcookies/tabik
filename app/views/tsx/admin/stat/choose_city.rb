Выберите город.
****
buts ||= []
buts = keyboard(@cities, 4) do |rec|
  puts rec.inspect
  button("#{rec[:entity_russian]}", "#{rec[:entity_id]}")
end
