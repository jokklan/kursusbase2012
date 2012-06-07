require "net/http"
require "uri"
require "rails"

uri = URI.parse("https://auth.dtu.dk/dtu/mobilapp.jsp")

# Shortcut
# 0462F7FB-7ED9-44A7-B81E-8ADAD17BBA1F

# Full control
http = Net::HTTP.new(uri.host, uri.port)

http.use_ssl = true
http.verify_mode = OpenSSL::SSL::VERIFY_NONE

request = Net::HTTP::Post.new(uri.request_uri)
request.set_form_data()
response = http.request(request)

puts response.to_yaml

# puts "ACCESS KEY:"
# if response.body =~ /LimitedAccess Password/
#   puts /Password=\"([^\"]*)\"/.match(response.body)[1]
# else
#   puts /Reason=\"([^\"]*)\"/.match(response.body)[1]
# end
