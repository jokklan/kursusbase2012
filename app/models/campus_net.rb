class CampusNet < ActiveRecord::Base
  
  class << self
    def api_call(user, path, locale = I18n.locale)
      require 'crack/xml'
      uri = URI.parse("https://www.campusnet.dtu.dk/data/CurrentUser/#{path}")

      http = Net::HTTP.new(uri.host, uri.port)

      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE

      request = Net::HTTP::Get.new(uri.request_uri)
    
      if locale == :da
        request.add_field("accept-language", "da-DK")
      else
        request.add_field("accept-language", "en-GB")
      end
    
      request.add_field("X-Include-services-and-relations", "true")
      request.basic_auth(user.student_number, user.cn_access_key)
      response = http.request(request)
      courses = response.body
      
      Crack::XML.parse(courses)
    end
  
  end
    
end
