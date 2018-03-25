require 'sinatra/base'
require_relative 'PickupGamesApplicationController.rb'
require_relative 'ActionsController.rb'

class PickupGamesApplication < Sinatra::Base
  enable :sessions
  set :port, 80

  configure do
    enable :logging
  end

  # get('/favicon.ico') do
  #   redirect('/static/favicon.ico')
  # end

  use Rack::MethodOverride

  use PickupGamesApplicationController

  get('/test') do
    'Redirect is working'
  end
  #use ActionsController
  #use NewSportsRequestController

  not_found do
    redirect('/main/not_found')
  end
end

PickupGamesApplication.run!
