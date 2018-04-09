require 'sinatra/base'
require_relative 'Game'
require_relative 'SportsGameManager'

class NewSportsGameRequestController < Sinatra::Base

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
    @availableLocations = SportsGameManager.getPossibleLocations()
    haml(:new_game_request)
  end

  post('/new_sports_game_request/?') do
    # convert time to right format
    params['startTime'] = Time.strptime(params['startTime'], "%Y-%m-%dT%H:%M")
    (gameID, (isSuccessfulRequest, errorMessage)) =
      SportsGameManager.createNewRequest(username:   session[:user],
                                         sportID:    params['sportID'],
                                         skillLevel: params['skillLevel'],
                                         startTime:  params['startTime'],
                                         locationID: params['location'])
    session[:action_completed] = :CREATION
    if isSuccessfulRequest
      session[:recently_made_request] = gameID
      session.delete(:invalid_game_creation_request)
      session.delete(:form_parameters)
      redirect('/my_sports_game_requests')
    else
      session[:invalid_game_creation_request] = errorMessage
      session[:form_parameters] = params.dup
      redirect('/new_sports_game_request')
    end
  end

  delete('/delete_sports_game_request/game/:gameID') do
    SportsGameManager.removeGameRequest(username: session[:user],
                                        gameID:   params[:gameID])
    session[:action_completed] = :DELETION
    redirect('/my_sports_game_requests')
  end

  # need to remove from the game table when there are no people left
  # instead of just removing the relation in i

  put('/edit_game_request/game/:gameID') do
    gameInfo = Game.findBy(gameID: params[:gameID])
    SportsGameManager.removeExistingRequest(username: session[:user],
                                            gameID:   params[:gameID])
    session[:action_completed] = :EDIT
    # TODO: change to use actual sport kind and location here

    session[:form_parameters] = { sportID:  gameInfo.sportID,
                                  skillLevel: gameInfo.skillLevel,
                                  startTime:  gameInfo.startTime,
                                  locationID: gameInfo.locationID }
    redirect('/new_sports_game_request')
  end
end