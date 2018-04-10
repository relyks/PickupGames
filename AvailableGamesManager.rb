require_relative 'Database'

class AvailableGamesManager
  def self.getAvailableGames
    queryString =
      %(
        SELECT P.gameID,
               Count(*) AS currentNumberOfPlayers,
               numberOfPlayers
        FROM   plays P,
               Sport S,
               Game G
        WHERE  P.gameID = G.gameID
               AND S.sportID = G.sportID
        GROUP  BY P.gameID
        HAVING Count(*) < numberOfPlayers;
       )
    resultArray = Database.makeQuery(queryString)
    availableGames = resultArray.map { |row|
      [
        row['gameID'],
        Game.findBy(gameID: row['gameID']),
        row['numberOfPlayers'] - row['currentNumberOfPlayers']
      ]
    }
    return availableGames.map { |gameID, game, playersNeeded|
      { sport:    Sport.getSportName(sportID: game.sportID),
        level:    game.skillLevel.capitalize,
        time:     game.startTime,
        location: Location.getLocationName(locationID: game.locationID),
        gameID: gameID,
        playersNeeded: playersNeeded
      }
    }.sort_by { |game| game[:time] }
  end
end