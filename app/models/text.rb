class Text
  def self.send_text(user, message)
    unless ['test', 'development', 'staging'].include? Rails.env
      begin
        response = RestClient::Request.new(
          :method => :post,
          :url => "https://api.twilio.com/2010-04-01/Accounts/#{ENV['TWILIO_ACCOUNT_SID']}/Messages.json",
          :user => ENV['TWILIO_ACCOUNT_SID'],
          :password => ENV['TWILIO_AUTH_TOKEN'],
          :payload => { :Body => message,
                        :From => ENV['TWILIO_PHONE_NUMBER'],
                        :To => user }
        ).execute
      rescue RestClient::BadRequest => error
        message = JSON.parse(error.response)['message']
        errors = [message]
        false
      end
    end
  end
end
