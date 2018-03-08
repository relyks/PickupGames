require 'sinatra/base'

class AuthenticationMiddleware < Sinatra::Base
  enable(:sessions)
  set(:bind, '0.0.0.0')

  get('/register/?') do
    haml(:register)
  end

  post('/register/?') do
    if UserManager.userIsAlreadyRegistered?(username: params['email'])
      redirect('/register/error')
    else
      UserManager.createNewUser(username: params['email'],
                                password: params['password'],
                                school:   params['school'])
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

User = Struct.new(:username, :password, :school)

class UserManager
  @@users = {}

  def self.connectToDatabase
    nil
  end

  def self.userIsAlreadyRegistered?(username:)
    @@users.keys.include?(username)
  end

  def self.createNewUser(username:, password:, school:)
    @@users[username] = User.new(username, password, school)
  end

  def self.userShouldBeAccepted?(username:, password:)
    @@users.has_key?(username) and
      @@users[username].password == password
  end

  def self.getAllUsers
    @@users.map { |email, user| { email: email, password: user.password } }
  end
end

PickupGamesApplication.run!
