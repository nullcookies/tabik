Вы действительно хотите добавить #{icon('id')} *#{@client.id}* / @#{@client.username} в *админы* бота?

#{icon('grey_exclamation')} Этот человек сможет пользоваться *всеми* админскими функциями.
****
[
  [
    button('Да, уверенно', 'add_to_admins'),
    button('Нет, ошибочка', 'show_user')
  ]
]
