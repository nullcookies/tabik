HAMDLERS = {
      "start": 'start',
      "Главная": 'start',
      "help": 'welcome',
      "Профиль": 'my_overview',
      "Настройки": 'my_settings',
      "Сделки": :escrow,
      "Продукт": 'product',
      "Район": 'district',
      "О системе": 'welcome',
      "Заказы": 'my_trades',
      "Заказ": 'pending_trade',
      "Назад": 'go_back',
      "Правила": 'rules',
      "Платежи": 'payments',
      "payments": 'payments',
      "rules": 'rules',
      "Работа": 'jobs',
      "me": 'my_account',
      "cashout": 'cashout',
      "баланса": 'pay_by_balance',
      "оценку": 'rate_trade',
      "позже": 'later',
      "easypaysample": 'easypaysample',
      "Перезаклад!": 'reitem',
      "Выдать": 'approve_reitem',
      "Отказать": 'reject_reitem',
      "Клад": 'add_item',
      "Помощь": 'help',
      "запрос": 'cancel_dispute',
      "Взять": 'take_free',
      "Посмотреть": 'view_free',
      "геопозицию": 'save_location',
      "Бухгалтерия": 'system_accounts',
      "Админ": 'admin_menu',
      "Стата": 'admin_menu',
      "Плагины": 'admin_plugins',
      "Долги": 'debts',
      "Прайсы": 'prices',
      "платить?": 'payments',
      "бот": 'new_bot',
      "Рекомендуем": 'welcome_bots',
      "регистрацию": 'cancel_new_bot',
      "кошель": 'service_wallets',
      "системе": 'service_about',
      "Bitcoin": 'service_btc',
      "Проблемы": 'abuse',
      "сделку": 'start_trade',
      "Данные": 'start_info',
      "Привязать": 'ask_token',
      "Подтвердить": 'confirm_escrow',
      "Отказаться": 'deny_escrow',
      "Реклама": 'activate_darkside',
      "Выключить Рекламу": 'remove_darkside',
      "Пополнение": 'admin_add_cash',
      "Продажи": 'admin_sales',
      "Официально": 'info',
      "Пожаловаться": 'abuse',
      "Отмена": 'cancel',
      "Кабинет": 'panel',
      "Вывести": 'cashout',
      "Выписка": 'client_statement',
      "Рефералы": 'client_referals',
      "Цены": 'admin_choose_product_for_prices',
      "Клады": 'admin_uploads',
      "Кошельки": 'admin_wallets',
      "Спам": 'admin_spam',
      "загрузку": 'admin_cancel_upload',
      "admin_create_spam": 'admin_create_spam',
      "admin_delete_spam": 'admin_delete_spam',
      "admin_edit_spam": 'admin_edit_spam',
      "admin_resend_spam": 'admin_resend_spam',
      "admin_back_to_spam": 'admin_back_to_spam',
      "рассылку": 'admin_cancel_spam',
      "редактирование": 'admin_cancel_spam',
      "цен": 'admin_menu',
      "admin_choose_all_products": 'admin_choose_all_products',
      "back_to_bot_products": 'back_to_bot_products',
      "admin_view_next_products_page": 'admin_view_next_products_page',
      "next_districts": 'next_districts',
      "prev_districts": 'prev_districts',
      "Команда": 'admin_team',
      "admin_add_cash": 'admin_add_cash',
      "add_to_admins": 'add_to_admins',
      "del_from_admins": 'del_from_admins',
      "ban": 'ban',
      "unban": 'unban',
      "delete_product": 'delete_product',
      "Интерфейс": 'admin_interface',
      "new_bot": 'new_bot',
      "bot_admin": 'bot_admin',
      "transfer": 'transfer',
      "use_code": 'use_code'
}

CHAT_HAMDLERS = {
    "activate_darkside": 'activate_darkside',
    "remove_darkside": 'remove_darkside'
}

LINES = [
    '#edc951', '#eb6841', '#cc2a36', '#4f372d', '#00a0b0', '#f96161', '#d0b783', '#2a334f', '#6b4423', '#0077AA'
]

ENDPOINTS = %w(
        getUpdates setWebhook deleteWebhook getWebhookInfo getMe sendMessage
        forwardMessage sendPhoto sendAudio sendDocument sendSticker sendVideo
        sendVoice sendLocation sendVenue sendContact sendChatAction
        getUserProfilePhotos getFile kickChatMember leaveChat unbanChatMember
        getChat getChatAdministrators getChatMembersCount getChatMember
        answerCallbackQuery editMessageText editMessageCaption
        editMessageReplyMarkup answerInlineQuery sendGame setGameScore
        getGameHighScores deleteMessage
      ).freeze


MARKDAOWN_EXAMPLE =  """
Отзывы и более сотни трипрепортов о нашей продукции и магазине Вы можете прочитать на таких ресурсах:

[Ветка на БигБро](http://bbro.com)
[Ветка на Лигалйзере](http://legalizer.info)
[Ветка на LegalRC](http://legalrc.com)
"""
