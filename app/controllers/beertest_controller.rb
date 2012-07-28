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

	###################################
	######## SEARCH VARIABLES #########
	arrayLimit = 4 # Max length of list
	minChars = 3 # Min characters user must enter into search
	###################################
  	
  	@match = []
    @final =""

  	results = BreweryDb2.search(:q => beersearch)    


  	if beersearch.length >= minChars
		results.each do |beer|
			# regex match
  			if beer.name.downcase.include? beersearch.downcase
				@match << beer
			end
  		end

	else
		@match << "Please use at least #{minChars} characters"
    @final = @match

	end

	@match = @match.take(arrayLimit)

  if @match.length ==1
    @final = "Name: #{@match[0].name}" + " " + "Description: #{@match[0].description}"
  else
    @match.each do |beer|
      @final += beer.name + ", "
    end
  end

  ################################################################
  ### Handling instances where responses are more than one SMS ###
  ################################################################

  count = @final.length / 160.0

  while count > 0
    @client.account.sms.messages.create(
    :from => +13156794711,
    :to => from_number,
    :body => " #{@final.first(160)}"
    )

    @final = @final[160,@final.length-1]
    count = count - 1

    sleep 1
  end
  
  end #method end
end #controller end



