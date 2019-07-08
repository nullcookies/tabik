#{icon('smile')} *Иконки*

Выберите иконку, чтобы изменить ее. Вводите только текстовые значения иконок. Например, чтобы установить иконку #{icon('smile')} нужно вводить `smile`.

#{icon('grey_exclamation')} Полный список можно посмотреть тут https://www.webfx.com/tools/emoji-cheat-sheet/
****
[
    [
      button("#{icon(@tsx_bot.icon)} Главная", 'enter_icon_main'),
      button("#{icon(@tsx_bot.icon_geo)} Гео", 'enter_icon_geo'),
      button("#{icon(@tsx_bot.icon_old)} Скидки", 'enter_icon_discount'),
      button("#{icon(@tsx_bot.icon_back)} Назад", 'enter_icon_back')
    ],
    [
      button('К настройкам', 'view_admin_interface')
    ]
]
