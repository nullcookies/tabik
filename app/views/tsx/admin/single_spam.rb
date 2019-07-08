#{icon('e-mail')} *Рассылка ##{@spam.id}*

#{@spam.text}

*#{@spam.status == Spam::NEW ? "⌛ Ожидает отправки" : "🆗 Отправлено"}*
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