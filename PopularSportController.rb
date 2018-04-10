require 'sinatra/base'
require_relative 'PopularSport'

class PopularSportController < Sinatra::Base

  get('/most_popular_sport') do
    @sportTotals = PopularSport.getSportsAndTheirTotalGames
    @popularTimesBySport = PopularSport.getMostPopularTimesForSports
    haml(:most_popular_sport)
  end
end