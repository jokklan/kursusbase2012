namespace :campus_net do
  require "net/http"
  require "uri"
  require "rails"
  # desc "Testing the campusnet api"
  task :access_key, [:seed] => :environment do |t,args|
    uri = URI.parse("https://auth.dtu.dk/dtu/mobilapp.jsp")

    # Full control
    http = Net::HTTP.new(uri.host, uri.port)

    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
  
    auth = {}
    auth[:username] = ask("username")
    auth[:password] = ask("password")

    request = Net::HTTP::Post.new(uri.request_uri)
    request.set_form_data(auth)
    response = http.request(request)

    puts response.to_yaml
    

    if response.body =~ /LimitedAccess Password/
      test = /Password=\"([^\"]*)\"/.match(response.body)[1]
      puts "ACCESS KEY: #{test}"
    else
      test = /Reason=\"([^\"]*)\"/.match(response.body)[1]
      puts "ERROR: #{test}"
    end
  end
  
  task :call, [:seed] => :environment do |t,args|
    path = ask("path")
    require 'crack/xml'
    uri = URI.parse("https://www.campusnet.dtu.dk/data/#{path}")

    http = Net::HTTP.new(uri.host, uri.port)

    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE

    request = Net::HTTP::Get.new(uri.request_uri)

    request.add_field("accept-language", "da-DK")
    
    username = ask("username")
    access_key = ask("access_key")
    
    request.add_field("X-Include-services-and-relations", "true")
    request.basic_auth(username, access_key)
    response = http.request(request)
    courses = response.body
    
    puts "DATA for #{path}, #{username}:\n#{Crack::XML.parse(courses).to_yaml}"
  end
  
  
  def ask (message)
    print "#{message}: "
    STDIN.gets.chomp
  end
end