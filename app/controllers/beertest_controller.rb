class BeertestController < ApplicationController
  def index

  	beersearch = "coors light"
  	@match = ""

  	results = BreweryDb2.search(:q => beersearch)    

  	results.each do |beer|
  		if beer.name.casecmp(beersearch)
  			@match = beer.name
  		end

  	end


  end
end



