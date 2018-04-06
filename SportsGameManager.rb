require_relative 'Database.rb'

Game = Struct.new(:sportKind, :skillLevel, :startTime, :locationID)

class SportsGameManager

  def self.createSport(sportID:, sportType:, numberOfPlayers:)
    queryString =
      %(
        INSERT INTO Sport(sportID, sportType, numberOfPlayers)
          VALUES ('#{sportID}', '#{sportType}', #{numberOfPlayers});
       )
    Database.makeQuery(queryString)
  end

  def self.createGame(gameID:, skillLevel:, startTime:, sportID:, locationID:, finalGame: false)
    queryString =
      %(
        INSERT INTO Game(gameID, skillLevel, startTime, finalGame, sportID, locationID)
          VALUES ('#{gameID}', '#{skillLevel}', '#{startTime.strftime('%Y-%m-%d %H:00:00')}',
                 #{finalGame.to_s}, '#{sportID}', '#{locationID}');
       )
    Database.makeQuery(queryString)
  end

  def self.createLocation(locationID:, locationName:)
    queryString =
      %(
        INSERT INTO Location(locationID, locationName)
          VALUES ('#{locationID}', '#{locationName}');
       )
    Database.makeQuery(queryString)
  end

  def self.createUserPlaysGameRelation(gameID:, email:)
    queryString =
      %(
        INSERT INTO plays(gameID, email)
          VALUES ('#{gameID}', '#{email}');
       )
    Database.makeQuery(queryString)
  end

  def self.createLocationHostsSportRelation(locationID:, sportID:)
    queryString =
      %(
        INSERT INTO canHost(locationID, sportID)
          VALUES ('#{locationID}', '#{sportID}');
       )
    Database.makeQuery(queryString)
  end

  def self.getPossibleSports
    queryString = 'SELECT DISTINCT sportType FROM Sport;'
    resultArray = Database.makeQuery(queryString)
    return resultArray.map { |row| row['sportType'] }
  end

  def self.createNewRequest(username:, sportKind:, skillLevel:, startTime:, locationID:)
    st = Time.strptime(startTime, "%Y-%m-%dT%H:%M")
    if st.to_i % 60 > 0
      return [nil, [false, 'A time block can only be scheduled on the hour']]
    end
    gameInfo = Game.new(sportKind, skillLevel, startTime, locationID)
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