require 'sinatra/base'

class NewSportsRequestController < Sinatra::Base
  get('/my_sports_game_requests') do
    @unsatisfiedGameRequests = SportsGameManager.getUnsatisfiedGameRequests()
  end
end