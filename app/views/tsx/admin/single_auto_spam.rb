#{icon('e-mail')} <b>Рассылка ##{@spam.id}</b>
🌀 Отправляется каждые <b>#{minut(@spam.period)}</b>

#{@spam.text}

****
[
    [
      button('Удалить', 'admin_delete_spam'),
      button('Повторить', 'admin_resend_spam')
    ],
    [
        button('Назад', 'admin_back_to_spam')
    ]
]