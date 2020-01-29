require 'net/http'
require 'uri'

uri = URI.parse("https://api.easypay.ua/api/payment/getReceipt?receiptId=785760125&amount=200.00&contentType=application/pdf")
request = Net::HTTP::Get.new(uri)
request.content_type = "application/json; charset=UTF-8"
request["Pageid"] = "74757f61-2df1-4beb-ab71-c6a63daf7431"
request["Locale"] = "ua"
request["User-Agent"] = "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/74.0.3729.131 Safari/537.36"
request["Accept"] = "application/pdf"
request["Referer"] = "https://easypay.ua/ua/contacts"
request["Appid"] = "452a5b05-9058-4b17-be0b-a7d472e54f37"
request["Partnerkey"] = "easypay-v2"
request["Googleclientid"] = "GA1.2.805737796.1571072043"

req_options = {
    use_ssl: uri.scheme == "https",
}

response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
  http.request(request)
end

puts response.code
# puts response.body