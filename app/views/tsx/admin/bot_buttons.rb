Выберите или добавьте кнопку.
****
buts ||= []
buts = keyboard(@buttons, 1) do |rec|
  button("#{rec[:title]}", rec[:id])
end
if @buttons.count < 3
  buts << [
      button('Добавить кнопку', 'enter_button_title'),
      button('К настройкам', 'view_admin_interface')
  ]
else
  buts << [button('К настройкам', 'view_admin_interface')]
end
