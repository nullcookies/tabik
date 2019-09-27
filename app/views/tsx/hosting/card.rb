#{icon('construction_worker')} *Табель сотрудника*

Номер #{icon('id')} *#{@kladman.id}*
Никнейм *#{@kladman.username}*
Остатки *#{kladov(@kladman.rest - @kladman.klads_uploaded)}*
Загружено *#{kladov(@kladman.klads_uploaded)}*
Штрафов *#{@tsx_bot.amo(@kladman.kladman_fines)}*
Выплачено *#{@tsx_bot.amo(@kladman.kladman_paid)}*
К выплате *#{@tsx_bot.amo(@kladman.kladman_debt - @kladman.kladman_paid - @kladman.kladman_fines)}*
****
[
    [
        button('Выдать опт', 'kladman_send_opt'),
        button('Ненаход', 'klad_not_found')
    ],
    [
        button('Выплатить', 'kladman_pay_out')
    ],
    [
        button('Назад', 'back_to_kladmans')
    ]
]