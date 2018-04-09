require_relative 'Database'

class Sport
  def self.getSportName(sportID:)
    queryString = "SELECT sportType FROM Sport where sportID = '#{sportID}';"
    return Database.makeQuery(queryString)[0]['sportType']
  end
end