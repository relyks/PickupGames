require 'sinatra/base'
require 'pstore'

class AuthenticationMiddleware < Sinatra::Base
  enable(:sessions)

  get('/register/?') do
    haml(:register)
  end

  post('/register/?') do
    $password = params['password']
    $email = params['email']
    'You have registered!'
  end

  post('/login/?') do
    if params['password'] == $password and
       params['email'] == $email
      session[:admin] = params['email']
      redirect('/main')
    else
      redirect('/login')
    end
  end

  get('/login/?') do
    haml(:login)
  end

  not_found do
    redirect('/main')
  end
end

class FormController < Sinatra::Base
  get('/form') do
    'Yessssss'
  end
end

class PickupGamesApplicationController < Sinatra::Base
  use AuthenticationMiddleware

  before do
    if session[:admin].nil? and request.path != '/'
      redirect('/login')
    end
  end

  get('/') do
    redirect('/main')
  end

  get('/main/?') do
    haml(:main)
  end

  get('/some_love/?') do
    'You made it!'
  end
end

class PickupGamesApplication < Sinatra::Base
  use PickupGamesApplicationController
  ######
  use FormController
  get('/app') do
    'Am I logged in?'
  end
end

class UserManager

  def self.createNewUser(username, password, school)
    
  end

  def self.userShouldBeAccepted?(username, password)

  end
end

PickupGamesApplication.run!
