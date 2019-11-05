#{icon('construction_worker')} *Табель сотрудника*

Номер #{icon('id')} *#{@kladman.id}*
Никнейм *#{@kladman.username}*
За один клад *#{@tsx_bot.amo(@staff.salary)}*
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
        button('Выплатить долг', 'kladman_pay_out'),
        button('Добавить долг', 'kladman_add_debt')
    ],
    [
        button('Передать', 'kladman_transfer_opt')
    ],
    [
        button('Назад', 'back_to_kladmans')
    ]
]