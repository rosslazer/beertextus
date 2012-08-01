class BeertestController < ApplicationController
  def index

    #########################################
    ##    SET TRUE FOR PRODUCTION MODE     ##
    ##       SET FALSE FOR DEV MODE        ##
    #########################################
    @prodMode = true
    
    # import gems
    require 'rubygems'
    require 'twilio-ruby'

    if @prodMode
      # auth for Twilio
      @account_sid = 'AC0626c6d8dc0a4551b159161c5ca7ced2'
      @auth_token = 'd27c1fd426321b9306b58df6dd3a24aa'

      # set up a client to talk to the Twilio REST API
      @client = Twilio::REST::Client.new(@account_sid, @auth_token)

      # get sender's search and number
      beersearch = params["Body"]
      fromNumber = params["From"]
    else
      # dev mode search
      beersearch = "laasdfaf"
    end

    # remove whitespace from searches
    beersearch.strip!

    # search variables
    arrayLimit = 4 # max length of beer list
    minChars = 3 # min characters user must enter for search
  	
    # used to store and format search results
    @match = []
    @matchString =""
    @messages = []

    # search BreweryDB for any matches
    results = BreweryDb2.search(:q => beersearch)

    # improve search results
    if beersearch.length >= minChars && results != nil
      # regex filter
      results.each do |beer|
        if beer.name.downcase.include? beersearch.downcase
          if beer.type == "beer"
            @match << beer
          end
        end
      end
      # if there is an exact match, only return that beer
      @match.each do |beer|
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
      @match = ["Sorry, no beers by that name found. Should we know it? Add it at brewerydb.com!"]
    end

    # trim search results to arrayLimit
    @match = @match.take(arrayLimit)

    # return error String if present
    if @match[0].kind_of? String
      @matchString = @match[0]
    # if only one beer matched search, return info on beer
    elsif @match.length == 1
      @matchString = "Name: #{@match[0].name} Description: "
      # if fields aren't empty, write them otherwise write N/A
      if @match[0].description != nil
        @matchString = @matchString + "#{@match[0].description} ABV: "
      else
        @matchString = @matchString + "N/A ABV: "
      end
      if @match[0].abv != nil
        @matchString = @matchString + @match[0].abv + "%"
      else
        @matchString = @matchString + "N/A"
      end
    # otherwise return list of beers
    else
      @match.each do |beer|
        @matchString += beer.name + ", "
      end
      #remove last comma and space
      @matchString = @matchString[0,@matchString.length-2]
    end

    # remove bad characters from final string
    @matchString.gsub!("\\","")
    @matchString.gsub!("\"","")
    @matchString.gsub!("\n"," ")
    @matchString.gsub!("\t"," ")
    @matchString.gsub!("\r"," ")

    # cut message into multiple sms and attach message number
    count = @matchString.length / 155 + 1
    messageNumber = 1
    totalMessages = count

    while count > 0 && @messages.length < 10
      @messages << "(#{messageNumber}/#{totalMessages})" + @matchString[0,154]
      @matchString = @matchString[154,@matchString.length-1]
      count -= 1
      messageNumber += 1
    end

    # send messages
    if @prodMode
      @messages.each do |message|
        @client.account.sms.messages.create(
        :from => +13156794711,
        :to => fromNumber,
        :body => message)

        #sleep to help lower misordering messages
        sleep 3
      end
    end

  end #method end
end #controller end
