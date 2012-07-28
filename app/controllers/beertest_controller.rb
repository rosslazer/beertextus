class BeertestController < ApplicationController
  def index
    
    require 'rubygems'
    require 'twilio-ruby'

    @account_sid = 'AC0626c6d8dc0a4551b159161c5ca7ced2'
    @auth_token = 'd27c1fd426321b9306b58df6dd3a24aa'

    # set up a client to talk to the Twilio REST API
    @client = Twilio::REST::Client.new(@account_sid, @auth_token)
  
    beersearch = params["Body"]
    from_number = params["From"]

  	@match = ""

  	results = BreweryDb2.search(:q => beersearch)    

  	results.each do |beer|
  		if beer.name.casecmp(beersearch)
  			@match = beer.name
  		end
  	end

    puts " #{@match}"

    #####################

    @client.account.sms.messages.create(
        :from => +13156794711,
        :to => from_number,
        :body => " #{@match}"
        )

  end #method end
end #controller end



