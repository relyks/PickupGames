require_relative 'Database.rb'

User = Struct.new(:username, :password, :school, :firstName, :lastName)

class UserManager
  # need to do some startup tasks when the app is first launched
  # check if the tables in the database have been created

  def self.getFirstnameOfUser(username:)
    Database.connect
    queryString =
      %(
        SELECT firstName
          FROM User
          WHERE email = '#{username}';
      )
    resultArray = Database.makeQuery(queryString)
    return resultArray[0]['firstName']
  end

  def self.userIsAlreadyRegistered?(username:)
    Database.connect
    queryString =
      %(
        SELECT email
          FROM User
          WHERE email = '#{username}';
      )
    resultArray = Database.makeQuery(queryString)
    return (not resultArray.empty?)
  end

  def self.createNewUser(username:, password:, school:, firstName:, lastName:)
    Database.connect
    queryString =
      %(
        INSERT INTO User(email, password, firstName, lastName)
          VALUES ('#{username}', '#{password}', '#{firstName}', '#{lastName}');
      )
    Database.makeQuery(queryString)
  end

  def self.userShouldBeAccepted?(username:, password:)
    Database.connect
    queryString =
      %(
        SELECT email, password
          FROM User
          WHERE email = '#{username}' AND password = '#{password}';
      )
    resultArray = Database.makeQuery(queryString)
    return (not resultArray.empty?)
  end

  def self.getAllUsers
    Database.connect
    queryString =
      %(
        SELECT email, password
          FROM User;
      )
    resultArray = Database.makeQuery(queryString)
    users = []
    for row in resultArray do
      users.push({ email:    row['email'],
                   password: row['password'] })
    end
    return users
  end
end