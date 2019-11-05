Кому передать
****
buts ||= []
buts = keyboard(@kladmans, 1) do |rec|
  button("#{rec[:id]} / #{rec[:username]}", rec[:id])
end