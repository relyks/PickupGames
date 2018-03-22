require_relative 'Database.rb'

class User

  def initialize(username:)
    @username = username
  end

  def firstName
    if @firstName == nil
      @firstName = getFirstName()
    end
    return @firstName
  end

  private

  def getFirstName
    queryString =
      %(
        SELECT firstName
          FROM User
          WHERE email = '#{@username}';
      )
    resultArray = Database.makeQuery(queryString)
    return resultArray[0]['firstName']
  end
end