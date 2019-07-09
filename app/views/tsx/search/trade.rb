*#{_buy.product_string} #{(topay = Price[_buy.prc]).qnt}*

Ваш баланс *#{@tsx_bot.amo(hb_client.available_cash)}*
Номер клада *##{_buy.id}*
Город *#{_buy.city_string}, #{_buy.district_string}*
#{method_helper(@method, _buy)}
****
buts ||= []
@avlbl = @seller_bot.available_payments
buts = keyboard(@avlbl, 2) do |rec|
    m = Meth[rec.meth]
    button(icon(@method == m.title ? 'large_blue_circle' : 'white_circle', m.russian), m.title)
end
buts