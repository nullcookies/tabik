#{icon('id')} *Информация о клиенте*

Номер клиента /#{@user.id}
Никнейм *#{@user.username}*
Баланс *#{@tsx_bot.amo(@user.available_cash)}*
Регистрация *#{human_date(@user.created)}*
Покупок *#{@spend.count}* на сумму *#{@tsx_bot.amo(@spend.sum(:price))}*
Заработано *#{@tsx_bot.amo(@user.ref_cash)}*
Статус *#{@user.banned? ? '🚷 Забанен' : '👌 Автивен'}*
Роль *#{!@user.readable_role(@tsx_bot) ? 'Покупатель': @user.readable_role(@tsx_bot)}*
****
buts = [
  [
    button(@user.banned? ? 'Разбанить' : 'Забанить', @user.banned? ? 'unban' : 'ban'),
    button('Пополнить', 'admin_add_cash')
  ],
  [
    button('Все покупки', 'admin_user_trades')
  ]
]
if @user.is_admin?(@tsx_bot)
  buts << [
    button('Удалить из админов', 'del_from_admins')
  ]
end
if @user.is_operator?(@tsx_bot)
  buts << [
    button('Удалить из операторов', 'del_from_operators')
  ]
end
if !@user.is_operator?(@tsx_bot) and !@user.is_admin?(@tsx_bot)
  buts << [
    button('Добавить в админы', 'sure_add_admin')
  ]
  buts << [
    button('Добавить в операторы', 'sure_add_operator')
  ]
end
buts