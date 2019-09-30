Рулеточный бот приветствует!
****
buts ||= []
numbers = [*1..50]
buts = keyboard(numbers, 4) do |rec|
  button("##{rec}", rec)
end