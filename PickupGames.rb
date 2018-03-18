require 'sinatra/base'
require_relative 'PickupGamesApplicationController.rb'

class PickupGamesApplication < Sinatra::Base
  enable(:sessions)
  set(:port, 80)

  use Rack::MethodOverride

  use PickupGamesApplicationController
  # put other controllers here

  not_found do
    redirect('/main/not_found')
  end
end

PickupGamesApplication.run!
