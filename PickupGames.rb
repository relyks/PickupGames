require 'sinatra/base'
require_relative 'PickupGamesApplicationController.rb'

class PickupGamesApplication < Sinatra::Base
  enable(:sessions)
  set(:port, 80)

  use PickupGamesApplicationController
  # put other controllers here
end

PickupGamesApplication.run!
