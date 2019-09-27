#{icon('construction_worker')} *Табель сотрудника*

Номер #{icon('id')} *#{@kladman.id}*
Никнейм *#{@kladman.username}*
Остатки *#{kladov(@kladman.rest - @kladman.klads_uploaded)}*
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