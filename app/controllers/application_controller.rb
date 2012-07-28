class ApplicationController < ActionController::Base
  protect_from_forgery


  def brew
  	BreweryDb.configure do |config|
  		config.apikey = '9694c7382740c1afd4f0dff20cf58da3'
	end
  end

end
