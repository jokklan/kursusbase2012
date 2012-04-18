require "net/http"
require "uri"
require "rails"

uri = URI.parse("https://auth.dtu.dk/dtu/mobilapp.jsp")

# Shortcut


# Full control
http = Net::HTTP.new(uri.host, uri.port)

http.use_ssl = true
http.verify_mode = OpenSSL::SSL::VERIFY_NONE

request = Net::HTTP::Post.new(uri.request_uri)
request.set_form_data({"username" => "s103472", "password" => "Supsdermand8fs"})
response = http.request(request)

puts response.to_yaml

puts "ACCESS KEY:"
if response.body =~ /LimitedAccess Password/
  puts "True#{response.body =~ /LimitedAccess Password/}"
else
  puts "false#{response.body =~ /LimitedAccess Password/}"
end
puts /Password="(.*)"/.match(response.body)[1]