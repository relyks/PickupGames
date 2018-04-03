require_relative 'Database.rb'

class UserManager
  # need to do some startup tasks when the app is first launched
  # check if the tables in the database have been created

  def self.userIsAlreadyRegistered?(username:)
    queryString =
      %(
        SELECT email
          FROM User
          WHERE email = '#{username}';
      )
    resultArray = Database.makeQuery(queryString)
    return (not resultArray.empty?)
  end

  def self.createNewUser(username:, password:, firstName:, lastName:, realUser: false)
    queryString =
      %(
        INSERT INTO User(email, password, firstName, lastName, realUser)
          VALUES ('#{username}', '#{password}', '#{firstName}', '#{lastName}', #{realUser.to_s});
      )
    Database.makeQuery(queryString)
  end

  def self.userShouldBeAccepted?(username:, password:)
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