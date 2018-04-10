require 'time'
require_relative 'Database'

class Game

  attr_accessor :sportID, :skillLevel, :startTime, :locationID

  # startTime should be Time object
  def initialize(sportID:, skillLevel:, startTime:, locationID:)
    @sportID    = sportID
    @skillLevel = skillLevel
    @startTime  = startTime
    @locationID = locationID
  end

  def self.findBy(gameID:)
    queryString = "SELECT * FROM Game g WHERE g.gameID = '#{gameID}';"
    resultArray = Database.makeQuery(queryString)
    values = resultArray[0]
    return self.new(sportID:   values['sportID'],
                    skillLevel: values['skillLevel'],
                    startTime:  Time.strptime(values['startTime'].to_s, '%Y-%m-%d %H:00:00'),
                    locationID: values['locationID'])

  end
end