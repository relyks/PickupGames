require 'sinatra/base'
require_relative 'UserManager'
require_relative 'User'

class AuthenticationMiddleware < Sinatra::Base

  before do
    cache_control :private,
                  :no_cache,
                  :no_store,
                  :must_revalidate,
                  max_age: 0
  end

  get('/register/?') do
    if session.has_key?(:registration_error)
      @error = :ERROR
      session.delete(:registration_error)
    end
    haml(:register)
  end

  post('/register/?') do
    if UserManager.userIsAlreadyRegistered?(username: params['email'])
      session[:registration_error] = true
      redirect('/register')
    else
      session.delete(:registration_error)
      UserManager.createNewUser(username:  params['email'],
                                password:  params['password'],
                                firstName: params['firstName'],
                                lastName:  params['lastName'],
                                realUser:  true)
      redirect('/login')
    end
  end

  post('/login/?') do
    if UserManager.userShouldBeAccepted?(username: params['email'],
                                         password: params['password'])
      session[:user] = params['email']
      session.delete(:login_invalid)
      path = '/all_users'
      if session.has_key?(:requested_path)
        path = session[:requested_path]
        session.delete(:requested_path)
      end
      redirect(path)
    else
      session[:login_invalid] = true
      redirect('/login')
    end
  end

  get('/login/?') do
    if session.has_key?(:login_invalid)
      @error = :INVALID
      session.delete(:login_invalid)
    elsif session.has_key?(:login_unauthorized)
      @error = :UNAUTHORIZED
      session.delete(:login_unauthorized)
    end
    haml(:login)
  end

  get('/logout/?') do
    session.delete(:user)
    redirect('/main')
  end

  get('/main/?') do
    if session.has_key?(:user)
      user = User.new(username: session[:user])
      @firstName = user.firstName
    end
    haml(:main)
  end

  get('/main/not_found') do
    status 404
    @error = :NOT_FOUND
    haml(:main)
  end
end
