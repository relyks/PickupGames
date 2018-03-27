require 'sinatra/base'
require_relative 'AuthenticationMiddleware.rb'
require_relative 'UserManager.rb'

class PickupGamesApplicationController < Sinatra::Base
  use AuthenticationMiddleware

  before do
    cache_control :private,
                  :no_cache,
                  :no_store,
                  :must_revalidate,
                  max_age: 0

    if (not session.has_key?(:user)) and
       (request.path != '/')         and
       (not request.path.start_with?('/static/'))
      session[:login_unauthorized] = true
      session[:requested_path] = request.path
      redirect('/login')
    end
  end

  get('/') do
    redirect('/main')
  end

  get('/all_users/?') do
    @users = UserManager.getAllUsers()
    haml(:users)
  end
end