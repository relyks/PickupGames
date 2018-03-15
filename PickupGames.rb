require 'sinatra/base'
require 'mysql2'

class AuthenticationMiddleware < Sinatra::Base

  before do
    cache_control(:private,
                  :no_cache,
                  :no_store,
                  :must_revalidate,
                  max_age: 0)
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
    if session[:user] != nil
      @firstName = UserManager.getFirstnameOfUser(username: session[:user])
    end
    haml(:main)
  end
end

class PickupGamesApplicationController < Sinatra::Base
  use AuthenticationMiddleware

  before do
    cache_control(:private,
                  :no_cache,
                  :no_store,
                  :must_revalidate,
                  max_age: 0)
    if session[:user] == nil and
       request.path != '/'   and
       (not request.path.start_with?('/static/'))
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
  enable(:sessions)
  set(:port, 80)

  use PickupGamesApplicationController
  # put other controllers here
end

User = Struct.new(:username, :password, :school, :firstName, :lastName)

class UserManager
  # need to do some startup tasks when the app is first launched
  # check if the tables in the database have been created

  def self.makeQuery(queryString)
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
    resultArray = makeQuery(queryString)
    return resultArray[0]['firstName']
  end

  def self.userIsAlreadyRegistered?(username:)
    connectToDatabase
    queryString =
      %(
        SELECT email
          FROM User
          WHERE email = '#{username}';
      )
    resultArray = makeQuery(queryString)
    return (not resultArray.empty?)
  end

  def self.createNewUser(username:, password:, school:, firstName:, lastName:)
    connectToDatabase
    queryString =
      %(
        INSERT INTO User(email, password, firstName, lastName)
          VALUES ('#{username}', '#{password}', '#{firstName}', '#{lastName}');
      )
    makeQuery(queryString)
  end

  def self.userShouldBeAccepted?(username:, password:)
    connectToDatabase
    queryString =
      %(
        SELECT email, password
          FROM User
          WHERE email = '#{username}' AND password = '#{password}';
      )
    resultArray = makeQuery(queryString)
    return (not resultArray.empty?)
  end

  def self.getAllUsers
    connectToDatabase
    queryString =
      %(
        SELECT email, password
          FROM User;
      )
    resultArray = makeQuery(queryString)
    users = []
    for row in resultArray do
      users.push({ email: row['email'], password: row['password'] })
    end
    return users
  end
end

PickupGamesApplication.run!
