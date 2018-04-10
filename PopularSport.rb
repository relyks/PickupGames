require 'time'
require_relative 'Sport'
require_relative 'PopularSport'
require_relative 'SportsGameManager'

class PopularSport
  def self.getSportsAndTheirTotalGames
    queryString =
        %(
            SELECT sportType,
                   COUNT(P.gameID) AS numberOfGames
            FROM   Sport S,
                   Game G,
                   plays P
            WHERE  S.sportID = G.sportID
                   AND P.gameID = G.gameID
            GROUP  BY sportType
            ORDER  BY COUNT(P.gameID) DESC;
        )
    return Database.makeQuery(queryString).map { |row| [row['sportType'], row['numberOfGames']] }
  end

  def self.getMostPopularTimeForSport(sportID:)
    queryString =
      %(
          SELECT G.sportID,
                 Hour(startTime)
          FROM   Game G,
                 Sport S
          WHERE  G.sportID = S.sportID
          GROUP  BY G.sportID,
                    Hour(startTime)
          HAVING G.sportID = '#{sportID}'
          ORDER  BY Count(*) DESC
          LIMIT  1;
      )
    result = Database.makeQuery(queryString)[0]
    return {
      sport: Sport.getSportName(sportID: result['sportID']),
      time: Time.parse("#{result['Hour(startTime)']}:00").strftime("%l %P").upcase
    }
  end

  def self.getMostPopularTimesForSports
    return SportsGameManager.getPossibleSports
                            .map { |sportType|
                              s = getMostPopularTimeForSport(sportID: sportType.split.join('-').downcase)
                              [s[:sport], s[:time]]
                            }
  end
end