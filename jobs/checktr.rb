# require 'net/http'
# require 'uri'
#
# uri = URI.parse("https://api.easypay.ua/api/payment/getReceipt?receiptId=785760125&amount=200.00&contentType=application/pdf")
# request = Net::HTTP::Get.new(uri)
# request.content_type = "application/json; charset=UTF-8"
# request["Locale"] = "ua"
# request["User-Agent"] = "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/74.0.3729.131 Safari/537.36"
# request["Accept"] = "application/pdf"
#
# req_options = {
#     use_ssl: uri.scheme == "https",
# }
#
# response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
#   http.request(request)
# end
#
# puts response.code
# # puts response.body


arr = [{:keeper=>"17359271"}, {:keeper=>"77877807"}, {:keeper=>"51448218"}, {:keeper=>"44292241"}, {:keeper=>"72569874"}]
puts arr.to_hash.values