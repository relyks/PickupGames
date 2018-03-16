require 'sinatra/base'

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

  get('/main/not_found') do
    status 404
    @error = :NOT_FOUND
    haml(:main)
  end
end