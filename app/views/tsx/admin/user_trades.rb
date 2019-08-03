#{icon('e-mail')} <b>Рассылка ##{@spam.id}</b>
<b>#{@spam.status == Spam::NEW ? "⌛ Ожидает отправки" : "🆗 Отправлено"}</b>

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