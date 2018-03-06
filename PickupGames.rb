require 'sinatra/base'

class AuthenticationMiddleware < Sinatra::Base
  enable(:sessions)

  get('/main') do
    haml(:main)
  end

  get('/register') do
    haml(:register)
  end

  post('/register') do
    $password = params['password']
    $email = params['email']
    'You have registered!'
  end

  post('/login') do
    if params['password'] == $password and
       params['email'] == $email
      session[:admin] = params['email']
      redirect('/main')
    else
      redirect('/login')
    end
  end

  get('/login') do
    haml(:login)
  end
end

class PickupGamesApplication < Sinatra::Base
  use AuthenticationMiddleware

  before do
    if session[:admin].nil? and request.path != '/'
      redirect('/login')
    end
  end

  get('/') do
    redirect('/main')
  end

  get('/some_love') do
    'You made it!'
  end

  not_found do
    redirect('/main')
  end

  # helpers do
  #   def is_application_path?(path)
  #     puts path
  #     puts Sinatra::Application.routes
  #     Sinatra::Application.routes
  #                         .map { |_, paths| paths }
  #                         .flatten
  #                         .include?(path)
  #   end
  # end
end

PickupGamesApplication.run!
