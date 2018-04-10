require 'humanhash'
require_relative 'Database'

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

  def self.getPossibleLocations()
    queryString = 'SELECT DISTINCT locationName FROM Location;'
    resultArray = Database.makeQuery(queryString)
    return resultArray.map { |row| row['locationName'] }
  end

  # TODO: need to make rest method for this to be accessible by ajax?
  def self.getPossibleLocationsForSport(sportID: )
    queryString =
        %(
           SELECT DISTINCT l.locationName
           FROM   Location l
                  INNER JOIN canHost c
                          ON c.locationID = l.locationID
                  INNER JOIN Sport s
                          ON s.sportID = c.sportID
           WHERE  s.sportID = '#{sportID}';
         )
    resultArray = Database.makeQuery(queryString)
    return resultArray.map { |row| row['locationName'] }
  end

  def self.getPlayerCountOf(gameID:)
    queryString = "SELECT count(*) FROM plays p WHERE p.gameID = '#{gameID}';"
    return Database.makeQuery(queryString)[0]['count(*)']
  end

  def self.removePlayerFromGame(username:, gameID:)
    queryString =
      %(
        DELETE FROM plays
          WHERE gameID = '#{gameID}' AND email = '#{username}';
       )
    Database.makeQuery(queryString)
  end

  def self.removeGame(gameID:)
    queryString = "DELETE FROM Game WHERE gameID = '#{gameID}';"
    Database.makeQuery(queryString)
  end

  def self.maxPlayersForGame(gameID:)
    queryString =
      %(
        SELECT numberOfPlayers FROM Sport
          WHERE sportID = '#{Game.findBy(gameID: gameID).sportID}';
       )
    return Database.makeQuery(queryString)[0]['numberOfPlayers']
  end

  # (matchingGameExists, gameIsFull, gameID)
  def self.findExistingGameMatchingCriteria(gameInfo)
    queryString =
      %(
        SELECT g.gameID
        FROM   Game g
        WHERE  g.startTime      = '#{gameInfo.startTime.strftime('%Y-%m-%d %H:00:00')}'
               AND g.locationID = '#{gameInfo.locationID}'
               AND g.sportID    = '#{gameInfo.sportID}'
               AND g.skillLevel = '#{gameInfo.skillLevel}';
       )
    puts 'finding existing game....'
    puts queryString
    rows = Database.makeQuery(queryString)
    if rows.empty?
      return [false, false, nil]
    else
      gameID = rows[0]['gameID']
      puts gameID
      return [true, getPlayerCountOf(gameID: gameID) == maxPlayersForGame(gameID: gameID), gameID].tap { |it| puts it }
    end
  end

  # TODO: is the right query?
  def self.getAvailableLocationsAtSameTime(gameInfo:, game:)
    queryString =
      %(
         SELECT DISTINCT l.locationName
         FROM   Location l
           INNER JOIN canHost c
                   ON c.locationID = l.locationID
           INNER JOIN Sport s
                   ON s.sportID = c.sportID
           INNER JOIN game g1
                   ON g1.sportID = s.sportID
        WHERE  g1.gameID = '#{game}'
               AND l.locationID NOT IN (SELECT g3.locationID
                                        FROM   game g3
                                               INNER JOIN plays p
                                                       ON g3.gameID = p.gameID
                                        WHERE  g3.startTime = g1.startTime);
       )
    return Database.makeQuery(queryString).map { |row| row['locationName'] }
  end

  def self.removeExistingRequest(username:, gameID:)
    removePlayerFromGame(username: username, gameID: gameID)
    if getPlayerCountOf(gameID: gameID) == 0
      removeGame(gameID: gameID)
    end
  end

  def self.createNewGame(user:, gameInformation:)
    gameID = HumanHash.uuid.first
    createGame(gameID: gameID,
               sportID:    gameInformation.sportID,
               skillLevel: gameInformation.skillLevel,
               locationID: gameInformation.locationID,
               startTime:  gameInformation.startTime)
    addUserToGame(username: user, gameID: gameID)
  end

  def self.addUserToGame(username:, gameID:)
    createUserPlaysGameRelation(gameID: gameID, email: username)
  end

  # TODO: fix the query in this
  def self.getAvailableTimesAtSameLocation(gameInfo:, game:)
    queryString =
      %(
         SELECT g.starttime
          FROM   game g
                 INNER JOIN game g2
                         ON g.locationID = g2.locationID
                            AND g2.gameID = #{game.gameID}
                            AND g.startTime BETWEEN Date_sub(g2.starttime, INTERVAL 3 hour)
                            AND Date_add(g2.starttime,
                                                        INTERVAL 3 hour)
                  AND NOT g.gameid = g2.gameid;
       )
    return Database.makeQuery(queryString).map { |row| row['startTime'] }
  end

  def self.createNewRequest(username:, sportID:, skillLevel:, startTime:, locationID:)
    if startTime.to_i % 60 > 0
      return [nil, [false, 'A time block can only be scheduled on the hour']]
    end
    gameInfo = Game.new(sportID:  sportID,
                        skillLevel: skillLevel,
                        startTime:  startTime,
                        locationID: locationID)
    (matchingGameExists, gameIsFull, gameID) = findExistingGameMatchingCriteria(gameInfo)
    if matchingGameExists
      puts 'matching game exists'
      if gameIsFull
        puts 'game is full'
        alternativeLocations = getAvailableLocationsAtSameTime(gameInfo: gameInfo, game: gameID)
        if not alternativeLocations.empty?
          return [
                   nil,
                   [
                     false,
                     'Please try one of the following locations: ' + alternativeLocations.join(', ')
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
        puts 'adding user to game'
        addUserToGame(gameID: gameID, username: username)
        return [gameID, [true, nil]]
      end
    else
      puts 'creating new game'
      gameID = createNewGame(user: username, gameInformation: gameInfo)
      return [gameID, [true, nil]]
    end
  end
end