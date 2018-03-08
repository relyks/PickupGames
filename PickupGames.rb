require 'sinatra/base'
require 'pstore'

class AuthenticationMiddleware < Sinatra::Base
  enable(:sessions)

  get('/register/?') do
    haml(:register)
  end

  post('/register/?') do
    UserManager.createNewUser(params['email'],
                              params['password'],
                              params['school'])
    redirect('/main')
  end

  post('/login/?') do
    if UserManager.userShouldBeAccepted?(params['email'], params['password'])
      session[:user] = params['email']
      redirect('/all_users')
    else
      redirect('/login')
    end
  end

  get('/login/?') do
    haml(:login)
  end

  get('/main/?') do
    haml(:main)
  end
end

class PickupGamesApplicationController < Sinatra::Base
  use AuthenticationMiddleware

  before do
    if session[:user].nil? and request.path != '/'
      redirect('/login')
    end
  end

  get('/') do
    redirect('/main')
  end

  get('/all_users/?') do
    @users = UserManager.getAllUsers
    puts @users
    haml(:all_users)
  end
end

class PickupGamesApplication < Sinatra::Base
  use PickupGamesApplicationController
end

User = Struct.new(:username, :password, :school)

class UserManager
  @@users = {}

  def self.connectToDatabase
    nil
  end

  def self.createNewUser(username, password, school)
    @@users[username] = User.new(username, password, school)
  end

  def self.userShouldBeAccepted?(username, password)
    @@users.has_key?(username) and
      @@users[username].password == password
  end

  def self.getAllUsers
    users = []
    for (email, user) in @@users
      users.push({email: email, password: user.password})
    end
    users
  end
end

PickupGamesApplication.run!
