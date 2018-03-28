require_relative 'Databases.rb'

Game = Struct.new(:sportKind, :skillLevel, :startTime, :location)

class SportsGameManager

  def self.createNewRequest(username:, sportKind:, skillLevel:, startTime:, location:)
    st = Time.strptime(startTime, "%Y-%m-%dT%H:%M")
    if st.to_i % 60 > 0
      return [nil, [false, 'A time block can only be scheduled on the hour']]
    end
    gameInfo = Game.new(sportKind, skillLevel, startTime, location)
    (matchingGameExists, gameIsFull, gameID) = findExistingGameMatchingCriteria(gameInfo)
    if matchingGameExists
      if gameIsFull
        alternativeLocations = getAvailableLocationsAtSameTime(gameInfo: gameInfo, game: gameID)
        if not alternativeLocations.empty?
          return [
                   nil,
                   [
                     false,
                     'Please try one of the following locations: ' + alternativeLocations.join(',')
                   ]
                 ]
        else
          alternativeTimes = getAvailableTimesAtSameLocation(gameInfo: gameInfo, game: gameID)
          if not alternativeTimes.empty?
            return [
                     nil,
                     [
                       false,
                       "There are other times available on the same day at #{gameInfo.location}. Try a different time"
                     ]
                   ]
          else
            [nil, [false, 'Please complete another request']]
          end
        end
      else
        addUserToGame(game: gameID, user: username, gameInformation: gameInfo)
        return [gameID, [true, nil]]
      end
    else
      gameID = createNewGame(user: username, gameInformation: gameInfo)
      return [gameID, [true, nil]]
    end
  end
end