require 'sinatra/base'
require_relative 'PickupGamesApplicationController'
require_relative 'ActionsController'
require_relative 'NewSportsGameRequestController'
require_relative 'MyGameRequestsController'
require_relative 'PopularSportController'

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
  use PopularSportController

  not_found do
    redirect('/main/not_found')
  end
end

PickupGamesApplication.run!
