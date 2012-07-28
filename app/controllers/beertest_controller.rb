class BeertestController < ApplicationController
  def index

  	@results = BreweryDb2.search(:q => 'hoegarden')


  end
end
