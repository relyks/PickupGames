require 'sinatra/base'
require 'mysql2'

class AuthenticationMiddleware < Sinatra::Base
  enable(:sessions)
  set(:bind, '0.0.0.0')

  before do
    cache_control(:no_cache)
  end

  get('/register/?') do
    haml(:register)
  end

  post('/register/?') do
    if UserManager.userIsAlreadyRegistered?(username: params['email'])
      redirect('/register/error')
    else
      UserManager.createNewUser(username:  params['email'],
                                password:  params['password'],
                                school:    params['school'],
                                firstName: params['firstName'],
                                lastName:  params['lastName'])
      redirect('/login')
    end
  end

  get('/register/error/?') do
    @error = :ERROR
    haml(:register)
  end

  post('/login/?') do
    if UserManager.userShouldBeAccepted?(username: params['email'],
                                         password: params['password'])
      session[:user] = params['email']
      redirect('/all_users')
    else
      redirect('/login/invalid')
    end
  end

  get('/login/?') do
    haml(:login)
  end

  get('/login/invalid/?') do
    @error = :INVALID
    haml(:login)
  end

  get('/login/unauthorized/?') do
    @error = :UNAUTHORIZED
    haml(:login)
  end

  get('/logout/?') do
    session.delete(:user)
    redirect('/main')
  end

  get('/main/?') do
    if not session[:user].nil?
      @firstName = UserManager.getFirstnameOfUser(username: session[:user])
    end
    haml(:main)
  end
end

class PickupGamesApplicationController < Sinatra::Base
  use AuthenticationMiddleware

  before do
    if session[:user].nil? and request.path != '/'
      redirect('/login/unauthorized')
    end
  end

  get('/') do
    redirect('/main')
  end

  get('/all_users/?') do
    @users = UserManager.getAllUsers
    haml(:all_users)
  end
end

class PickupGamesApplication < Sinatra::Base
  use PickupGamesApplicationController
  # put other controllers here
end

User = Struct.new(:username, :password, :school, :firstName, :lastName)

class UserManager
  # need to do some startup tasks when the app is first launched
  # check if the tables in the database have been created

  def self.make_query(queryString)
    return @@client.query(queryString).to_a
  end

  def self.connectToDatabase
    @@client = Mysql2::Client.new(host:     'localhost',
                                  database: 'test',
                                  username: 'root',
                                  password: File.read('password.txt').chomp)
  end

  def self.getFirstnameOfUser(username:)
    connectToDatabase
    queryString =
      %(
        SELECT firstName
          FROM User
          WHERE email = '#{username}';
      )
    resultArray = make_query(queryString)
    return resultArray[0]['firstName']
  end

  def self.userIsAlreadyRegistered?(username:)
    connectToDatabase
    queryString =
      %(
        SELECT email FROM User
          WHERE email = '#{username}';
      )
    resultArray = make_query(queryString)
    return (not resultArray.empty?)
  end

  def self.createNewUser(username:, password:, school:, firstName:, lastName:)
    connectToDatabase
    queryString =
      %(
        INSERT INTO User(email, password, firstName, lastName)
          VALUES ('#{username}', '#{password}', '#{firstName}', '#{lastName}');
      )
    make_query(queryString)
  end

  def self.userShouldBeAccepted?(username:, password:)
    connectToDatabase
    queryString =
      %(
        SELECT email, password
          FROM User
          WHERE email = '#{username}' AND password = '#{password}';
      )
    resultArray = make_query(queryString)
    return (not resultArray.empty?)
  end

  def self.getAllUsers
    connectToDatabase
    queryString =
      %(
        SELECT email, password
          FROM User;
      )
    resultArray = make_query(queryString)
    users = []
    for row in resultArray do
      users.push({ email: row['email'], password: row['password'] })
    end
    return users
  end
end

PickupGamesApplication.run!
