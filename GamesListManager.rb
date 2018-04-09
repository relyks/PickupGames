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
        WHERE  gameID = (SELECT gameID
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
              gameID: gameID
            }
          }
  end
end