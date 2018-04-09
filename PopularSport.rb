require_relative 'PopularSport'

class PopularSport
  def self.getSportsAndTheirTotalGames
    queryString =
        %(
            SELECT sportType,
                   COUNT(P.gameid) AS numberOfGames
            FROM   Sport S,
                   Game G,
                   plays P
            WHERE  S.sportID = G.sportID
                   AND P.gameID = G.gameID
            GROUP  BY sportType
            ORDER  BY COUNT(P.gameID) DESC;
        )
    return Database.makeQuery(queryString).map {}
  end
end