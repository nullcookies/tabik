#{icon('id')} *Информация о клиенте*

Номер клиента /#{@user.id}
Никнейм *#{@user.username}*
Баланс *#{@tsx_bot.amo(@user.available_cash)}*
Регистрация *#{human_date(@user.created)}*
Покупок *#{@spend.count}* на сумму *#{@tsx_bot.amo(@spend.sum(:price))}*
Заработано *#{@tsx_bot.amo(@user.ref_cash)}*
Статус *#{@user.banned? ? '🚷 Забанен' : '👌 Автивен'}*
Роль *#{@user.is_admin?(@tsx_bot) ? "👮 Администратор" : "👤 Покупатель"}*
****
buts = [
  [
    button(@user.banned? ? 'Разбанить' : 'Забанить', @user.banned? ? 'unban' : 'ban'),
    button('Пополнить', 'admin_add_cash')
  ],
]
if @user.is_admin?(@tsx_bot)
  buts << [
    button('Удалить из админов', 'del_from_admins')
  ]
else
  buts << [
    button('Добавить в админы', 'add_to_admins')
  ]
end
buts