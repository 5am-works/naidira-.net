require "amber"
require "./naidira"

include Amber

class ApiController < Amber::Controller::Base
  def index
    response.status_code = 501
  end
end

Server.configure do |app|
  pipeline :api

  routes :api do
    get "/", ApiController, :index
  end
end

Server.start