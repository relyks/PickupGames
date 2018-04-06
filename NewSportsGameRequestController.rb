require 'sinatra/base'

class NewSportsGameRequestController < Sinatra::Base

  helpers do
    def processRequestResult(isSuccessfulRequest, gameID, errorMessage, parameters)
      if isSuccessfulRequest
        session[:recently_made_request] = gameID
        session.delete(:invalid_game_creation_request)
        session.delete(:form_parameters)
        redirect('/my_sports_game_requests')
      else
        session[:invalid_game_creation_request] = errorMessage
        session[:form_parameters] = parameters.dup
        redirect('/new_sports_game_request')
      end
    end
  end

  get('/new_sports_game_request/?') do
    if session.has_key?(:invalid_game_creation_request)
      @errorMessage = session[:invalid_game_creation_request]
      session.delete(:invalid_game_creation_request)
    end
    if session.has_key?(:form_parameters)
      @parameters = session[:form_parameters].map { |key, value| [key.to_sym, value] }.to_h
      session.delete(:form_parameters)
    end
    @possibleSports     = SportsGameManager.getPossibleSports()
    @availableLocations = Locations.getPossibleLocations()
    haml(:new_game_request)
  end

  post('/new_sports_game_request/?') do
    (gameID, (isSuccessfulRequest, errorMessage)) =
      SportsGameManager.createNewRequest(username:   session[:user],
                                         sportKind:  params['sportKind'],
                                         skillLevel: params['skillLevel'],
                                         startTime:  params['startTime'],
                                         locationID: params['location'])
    session[:action_completed] = :CREATION
    processRequestResult(isSuccessfulRequest, gameID, errorMessage, params)
  end

  delete('/delete_sports_game_request/game/:gameID') do
    SportsGameManager.removeGameRequest(username: session[:user],
                                        gameID: params[:gameID])
    session[:action_completed] = :DELETION

    redirect('my_sports_game_requests')
  end

  get('/edit_game_request/game/:gameID') do

    # get info for game
    # load it into the form
    # submitting the form
  end

  post('/edit_game_request/game/:gameID') do
    SportsGameManager.removeGameRequest(username: session[:user],
                                        gameID: params[:gameID])
    # need to remove from the game table when there are no people left
    # instead of just removing the relation in i
    (gameID, (isSuccessfulRequest, errorMessage)) =
        SportsGameManager.createNewRequest(username:   session[:user],
                                           sportKind:  params['sportKind'],
                                           skillLevel: params['skillLevel'],
                                           startTime:  params['startTime'],
                                           locationID: params['location'])
    session[:action_completed] = :EDIT
    processRequestResult(isSuccessfulRequest, gameID, errorMessage, params)
  end
end