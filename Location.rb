require_relative 'Database'

class Location
  def self.getLocationName(locationID:)
    queryString = "SELECT locationName FROM Location where locationID = '#{locationID}';"
    return Database.makeQuery(queryString)[0]['locationName']
  end
end