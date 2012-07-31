class BeertestController < ApplicationController
  def index
    
    # import gems
    require 'rubygems'
    require 'twilio-ruby'

    # auth for Twilio
    @account_sid = 'AC0626c6d8dc0a4551b159161c5ca7ced2'
    @auth_token = 'd27c1fd426321b9306b58df6dd3a24aa'

    # set up a client to talk to the Twilio REST API
    @client = Twilio::REST::Client.new(@account_sid, @auth_token)

    # get sender's search and number
    beersearch = params["Body"]
    from_number = params["From"]

    # search variables
    arrayLimit = 4 # max length of beer list
    minChars = 3 # min characters user must enter for search
  	
    # used to store and format search results
    @match = []
    @final =""

    # search BreweryDB for any matches
    results = BreweryDb2.search(:q => beersearch)

    # improve search results
    if beersearch.length >= minChars && results != nil
      # regex filter
      results.each do |beer|
        if beer.name.downcase.include? beersearch.downcase
          @match << beer
        end
      end
      # if there is an exact match, only return that beer
      results.each do |beer|
        if beer.name.downcase == beersearch.downcase
          @match = [beer]
	end
      end
    # return error if user doesn't enter enough search characters
    elsif beersearch.length < minChars
      @match = ["Please use at least #{minChars} characters for your search!"]
    end

    # if no matches found, create no matches found responce
    if @match == []
      @match = ["Sorry, no beers by that name found!"]
    end

    # trim search results to arrayLimit
    @match = @match.take(arrayLimit)

    # return error String if present
    if @match[0].kind_of? String
      @final = @match[0]
    # if only one beer matched search, return info on beer
    elsif @match.length == 1
      @final = "Name: #{@match[0].name} Description: "
      # if fields aren't empty, write them otherwise write N/A
      if @match[0].description != nil
        @final = @final + "#{@match[0].description} ABV: "
      else
        @final = @final + "N/A ABV: "
      end
      if @match[0].abv != nil
        @final = @final + @match[0].abv
      else
        @final = @final + "N/A"
      end
    # otherwise return list of beers
    else
      @match.each do |beer|
        @final += beer.name + ", "
      end
      #remove last comma and space
      @final = @final[0,@final.length-2]
    end

    # remove bad characters from final string
    @final.gsub!("\\","")
    @final.gsub!("\"","")

    #cut message into multiple sms and send
    count = @final.length / 160.0

    while count > 0
      @client.account.sms.messages.create(
      :from => +13156794711,
      :to => from_number,
      :body => "#{@final.first(160)}"
      )

      @final = @final[161,@final.length-1]
      count = count - 1

      sleep 3
    end
  
  end #method end
end #controller end
