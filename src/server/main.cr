require "amber"
require "./controller"

include Amber
include Naidira::Server

Server.configure do |app|
  pipeline :api do
    plug Pipe::CORS.new
  end

  routes :api do
    get "/", ApiController, :index
    get "/search/:query", ApiController, :search
    get "/alphabetical", ApiController, :alphabetical
  end
end

Server.start