#{icon('art')} *Интерфейс*

Название бота *#{@tsx_bot.title}*
#{"Поддержка" if !@tsx_bot.support.nil?} #{@tsx_bot.support_line if !@tsx_bot.support.nil?}
Кастомные кнопки *#{Button.where(bot: @tsx_bot.id).count}*
Аватар #{icon('rice_scene')} [Ссылка на картинку](#{@tsx_bot.avatar})
Иконки #{list_icons}

Здесь можно настроить интерфейс бота. Выбрать аватар, настроить иконки и кнопки для главного меню.
****
[
  [
      button('Аватар', 'enter_avatar'),
      button('Название', 'enter_bot_title'),
      button('Поддержка', 'enter_bot_support')
  ],
  [
      button('Иконки', 'bot_icons'),
      button('Кнопки', 'bot_buttons'),
  ]
]