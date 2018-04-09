require 'sinatra/base'
require_relative 'GamesListManager.rb'

class MyGameRequestsController < Sinatra::Base

  get('/my_sports_game_requests') do
    if session.has_key?(:action_completed)
      @action = session[:action_completed]
      session.delete(:action_completed)
    end
    @unsatisfiedGameRequests = GamesListManager.getUnsatisfiedGameRequests(email: session[:user])
    # @potentialGameRequests   = GamesListManager.getPotentialGameRequests
    # @satisfiedGameRequests   = GamesListManager.getSatisfiedGameRequests
    # @finalGameRequests       = GamesListManager.getFinalGameRequests
    @potentialGameRequests = []
    @satisfiedGameRequests = []
    @finalGameRequests = []
    @user = session[:user]
    haml(:my_games_request)
  end
end