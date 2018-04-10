require_relative 'Database'
require_relative 'Location'
require_relative 'Sport'
require_relative 'Game'

class GamesListManager

  def self.getUnsatisfiedGamesByID(email:)
    queryString =
      %(
        SELECT *
        FROM   Game
        WHERE  gameID IN (SELECT gameID
                         FROM   plays
                         WHERE  gameID IN (SELECT gameID
                                           FROM   plays
                                           GROUP  BY gameID
                                           HAVING Count(email) = 1)
                                AND email = '#{email}');
      )
    return Database.makeQuery(queryString).map { |row| row['gameID'] }
  end

  def self.getUnsatisfiedGameRequests(email:)
    unsatisfiedGames = getUnsatisfiedGamesByID(email: email).map { |gameID| [gameID, Game.findBy(gameID: gameID)] }
    return unsatisfiedGames.map { |gameID, game|
      { sport:    Sport.getSportName(sportID: game.sportID),
        level:    game.skillLevel.capitalize,
        time:     game.startTime,
        location: Location.getLocationName(locationID: game.locationID),
        gameID: gameID,
        playersNeeded: SportsGameManager.maxPlayersForGame(gameID: gameID) - 1
      }
    }.sort_by { |game| game[:time] }
  end

  def self.getPotentialGamesByID(email:)
    queryString =
      %(
        SELECT P.gameID,
               numberOfPlayers,
               Count(*) AS currentNumberOfPlayers
        FROM   plays P,
               Game G,
               Sport S
        WHERE  G.gameID = P.gameID
               AND G.sportID = S.sportID
        GROUP  BY gameID
        HAVING Count(*) < numberOfPlayers
               AND P.gameID IN(SELECT P.gameID
                               FROM   plays P
                                      INNER JOIN Game G
                                              ON P.gameID = G.gameID
                                      INNER JOIN Sport S
                                              ON G.sportID = S.sportID
                               WHERE  P.email = '#{email}');
      )
    return Database.makeQuery(queryString).map { |row|
      { gameID: row['gameID'], playersNeeded: row['numberOfPlayers'] - row['currentNumberOfPlayers'] }
    }
  end

  def self.getPotentialGameRequests(email:)
    unsatisfiedGamesByID = getUnsatisfiedGamesByID(email: email)
    potentialGamesByID = getPotentialGamesByID(email: email)
                             .reject { |game| unsatisfiedGamesByID.include?(game[:gameID]) }
    potentialGames = potentialGamesByID.map { |game|
      [
          game[:gameID],
          game[:playersNeeded],
          Game.findBy(gameID: game[:gameID])
      ]
    }
    return potentialGames.map { |gameID, playersNeeded, game|
      { sport:    Sport.getSportName(sportID: game.sportID),
        level:    game.skillLevel.capitalize,
        time:     game.startTime,
        location: Location.getLocationName(locationID: game.locationID),
        gameID:   gameID,
        playersNeeded: playersNeeded
      }
    }.sort_by { |game| game[:time] }
  end

  def self.getSatisfiedGamesByID(email:)
    queryString =
        %(
        SELECT P.gameID,
               numberOfPlayers,
               Count(*) AS currentNumberOfPlayers
        FROM   plays P,
               Game G,
               Sport S
        WHERE  G.gameID = P.gameID
               AND G.sportID = S.sportID
        GROUP  BY gameID
        HAVING Count(*) = numberOfPlayers
               AND P.gameID IN(SELECT P.gameID
                               FROM   plays P
                                      INNER JOIN Game G
                                              ON P.gameID = G.gameID
                                      INNER JOIN Sport S
                                              ON G.sportID = S.sportID
                               WHERE  P.email = '#{email}');
      )
    return Database.makeQuery(queryString).map { |row| row['gameID'] }
  end

  def self.getSatisfiedGameRequests(email:)
    satisfiedGames = getSatisfiedGamesByID(email: email).map { |gameID| [gameID, Game.findBy(gameID: gameID)] }
    return satisfiedGames.map { |gameID, game|
      { sport:    Sport.getSportName(sportID: game.sportID),
        level:    game.skillLevel.capitalize,
        time:     game.startTime,
        location: Location.getLocationName(locationID: game.locationID),
        gameID: gameID,
        playersNeeded: 0
      }
    }.sort_by { |game| game[:time] }
  end
end