require_relative 'Databases.rb'

Game = Struct.new(:sportKind, :skillLevel, :startTime, :location)

class SportsGameManager

  def self.createNewRequest(username:, sportKind:, skillLevel:, startTime:, location:)
    st = Time.strptime(startTime, "%Y-%m-%dT%H:%M")
    et = Time.strptime(endTime, "%Y-%m-%dT%H:%M")
    if st > et
      return [nil, [false, 'Start time needs to be before end time']]
    elsif (st.to_i % 60 > 0) or (et.to_i % 60 > 0)
      return [nil, [false, 'A time block can only be scheduled on the hour']]
    elsif (et - st) > 3600
      return [nil, [false, 'A time block can not be scheduled for more than an hour']]
    end
    gameInfo = Game.new(sportKind, skillLevel, startTime, endTime, location)
    (matchingGameExists, gameIsFull, gameID) = findExistingGameMatchingCriteria(gameInfo)
    if matchingGameExists
      if gameIsFull
        alternativeLocations = getAvailableLocationsAtSameTime(gameInfo: gameInfo, game: gameID)
        return [nil,
                 [
                   false,
                   'Please try one of the following locations: ' + alternativeLocations.join(',')
                 ]
               ]
      else
        addUserToGame(game: gameID, user: username, gameInformation: gameInfo)
      end
    else
      gameID = createNewGame(user: username, gameInformation: gameInfo)
      return 
    end
  end
end