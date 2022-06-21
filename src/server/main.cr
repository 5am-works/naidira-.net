require "amber"
require "./controller"

include Amber
include Naidira::Server

Server.configure do |app|
  pipeline :api

  routes :api do
    get "/", ApiController, :index

    get "/search/:query", ApiController, :search
  end
end

Server.start