*#{@item.product_string} #{(topay = Price[_buy.prc]).qnt}*

Ваш баланс *#{@tsx_bot.amo(hb_client.available_cash)}*
Номер клада *##{@item.id}*
Город *#{@item.city_string}, #{@item.district_string}*
#{method_helper(@method, @item)}
#{method_desc(@method)}
****
[[
  button(icon(@method == 'easypay' ? 'large_blue_circle' : 'white_circle', 'Easypay'), 'view_easypay_trade'),
  button(icon(@method == 'bitobmen' ? 'large_blue_circle' : 'white_circle', 'BitObmen'), 'view_bitobmen_trade')
]]
# buts ||= []
# @avlbl = @seller_bot.available_payments
# buts = keyboard(@avlbl, 2) do |rec|
#     m = Meth[rec.meth]
#     button(icon(@method == m.title ? 'large_blue_circle' : 'white_circle', m.russian), m.title)
# end
# buts