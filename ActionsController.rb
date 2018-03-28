require 'sinatra/base'

class ActionsController < Sinatra::Base

  get('/actions/?') do
    session.delete(:recently_made_request) # this might need to be done everywhere?
    haml(:actions)
  end
end
