require 'sinatra/base'
require_relative 'PickupGamesApplicationController.rb'
require_relative 'ActionsController.rb'
require_relative 'NewSportsGameRequestController.rb'
require_relative 'MyGameRequestsController.rb'

class PickupGamesApplication < Sinatra::Base
  enable :sessions
  set :port, 80
  enable :logging

  use Rack::MethodOverride

  use PickupGamesApplicationController

  # get('/test') do
  #   'Redirect is working'
  # end
  use ActionsController
  use NewSportsGameRequestController
  use MyGameRequestsController

  not_found do
    redirect('/main/not_found')
  end
end

PickupGamesApplication.run!
