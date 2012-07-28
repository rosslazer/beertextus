class BeertestController < ApplicationController
  def index

	###################################
	######## SEARCH VARIABLES #########
	arrayLimit = 4 # Max length of list
	minChars = 3 # Min characters user must enter into search
	###################################

  	
	beersearch = "coors" #FOR DEBUGGING
  	@match = []

  	results = BreweryDb2.search(:q => beersearch)    

  	if beersearch.length >= minChars
		results.each do |beer|
			# regex match
  			if beer.name.downcase.include? beersearch.downcase
				@match << beer.name
			end
  		end
	else
		@match << "Please use at least #{minChars} characters"
	end

	@match = @match.take(arrayLimit)

    #twilio stuff

    require 'rubygems'
    require 'twilio-ruby'

    @account_sid = 'AC0626c6d8dc0a4551b159161c5ca7ced2'
    @auth_token = 'd27c1fd426321b9306b58df6dd3a24aa'

    # set up a client to talk to the Twilio REST API
    @client = Twilio::REST::Client.new(@account_sid, @auth_token)

    message_body = params["Body"]

    puts "hello! #{message_body}"

  end
end



