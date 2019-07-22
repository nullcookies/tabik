Выберите город.
****
buts ||= []
buts = keyboard(@cities, 4) do |rec|
  button("#{rec[:entity_russian]}", rec[:entity_d])
end
