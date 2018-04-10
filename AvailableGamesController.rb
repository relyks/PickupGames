require 'sinatra/base'
require_relative 'AvailableGamesManager'
require_relative 'SportsGameManager'
require_relative 'Game'

class AvailableGamesController < Sinatra::Base

  get('/available_games/?') do
    if params.has_key?(:filterBySport) and params[:filterBySport] != 'none'
      @currentSportFilter = params[:filterBySport]
    end
    if session.has_key?(:recently_joined_game)
      @recentlyJoinedGame = Game.findBy(gameID: session[:recently_joined_game])
      session.delete(:recently_joined_game)
    end
    @availableGames = AvailableGamesManager.getAvailableGames
    haml(:available_games)
  end

  get('/join_game') do
    SportsGameManager.addUserToGame(username: session[:user], gameID: params['gameID'])
    session[:recently_joined_game] = params['gameID']
    redirect('/available_games')
  end
end