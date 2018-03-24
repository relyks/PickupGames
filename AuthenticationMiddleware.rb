require 'sinatra/base'
require 'sinatra/cookies'
require_relative 'UserManager.rb'
require_relative 'User.rb'

class AuthenticationMiddleware < Sinatra::Base
  helpers Sinatra::Cookies

  before do
    cache_control :private,
                  :no_cache,
                  :no_store,
                  :must_revalidate,
                  max_age: 0
  end

  get('/register/?') do
    if cookies.has_key?(:registration_error)
      @error = :ERROR
      cookies.delete(:registration_error)
    end
    haml(:register)
  end

  post('/register/?') do
    if UserManager.userIsAlreadyRegistered?(username: params['email'])
      cookies[:registration_error] = true
      redirect('/register')
    else
      cookies.delete(:registration_error)
      UserManager.createNewUser(username:  params['email'],
                                password:  params['password'],
                                school:    params['school'],
                                firstName: params['firstName'],
                                lastName:  params['lastName'])
      redirect('/login')
    end
  end

  post('/login/?') do
    if UserManager.userShouldBeAccepted?(username: params['email'],
                                         password: params['password'])
      session[:user] = params['email']
      cookies.delete(:login_invalid)
      path = '/all_users'
      if cookies.has_key?(:requested_path)
        path = cookies[:requested_path]
        cookies.delete(:requested_path)
      end
      redirect(path)
    else
      cookies[:login_invalid] = true
      redirect('/login')
    end
  end

  get('/login/?') do
    if cookies.has_key?(:login_invalid)
      @error = :INVALID
      cookies.delete(:login_invalid)
    elsif cookies.has_key?(:login_unauthorized)
      @error = :UNAUTHORIZED
      cookies.delete(:login_unauthorized)
    end
    haml(:login)
  end

  get('/logout/?') do
    session.delete(:user)
    redirect('/main')
  end

  get('/main/?') do
    if session[:user] != nil
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
