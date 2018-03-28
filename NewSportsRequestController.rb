require 'sinatra/base'

class NewSportsRequestController < Sinatra::Base

  get('/new_sports_game_request/?') do
    if session.has_key?(:invalid_game_creation_request)
      @error = session[:invalid_game_creation_request]
    end
    @possibleSports     = Sports.getPossibleSports()
    @availableLocations = Locations.getPossibleLocations()
    haml(:new_sports_request)
  end

  post('/new_sports_game_request/?') do
    (gameID, (isSuccessfulRequest, errorMessage)) =
      SportsGameManager.createNewRequest(username:   session[:user],
                                         sportKind:  params['sportKind'],
                                         skillLevel: params['skillLevel'],
                                         startTime:  params['startTime'],
                                         location:   params['location'])
    if isSuccessfulRequest
      session[:recently_made_request] = gameID
      redirect('/my_sports_game_requests')
    else
      session[:invalid_game_creation_request] = errorMessage
      redirect('/new_sports_game_request')
    end
  end
end