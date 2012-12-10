# encoding: utf-8

require 'sinatra'
require 'sinatra/reloader' if development?
require 'sinatra/content_for'

require 'haml'
require 'omniauth'
require 'omniauth-github'
require 'faraday'
require 'faraday_middleware'

set :haml, { :format => :html5 }
enable :sessions, :logging

before do
#  request.script_name = '/github-activity-tunes'
end

use OmniAuth::Builder do
  provider :github, 'bdbaacc862910d00a2ae', '480c64e934829cd5d4f290e18df8e0e9cb946ff5'
end

def repositories(user, token)
  conn = Faraday.new(:url => 'https://api.github.com', :ssl => {:verify => false}) do |faraday|
    faraday.request  :url_encoded
    faraday.response :logger
    faraday.adapter  Faraday.default_adapter
    faraday.use FaradayMiddleware::ParseJson
  end

  conn.get("/users/#{user}/repos", {
             :type => 'owner', :sort => "updated", :access_token => token
           }).body
end

def activities(user, repo)
  conn = Faraday.new(:url => 'https://github.com', :ssl => {:verify => false}) do |faraday|
    faraday.request  :url_encoded
    faraday.response :logger
    faraday.adapter  Faraday.default_adapter
    faraday.use FaradayMiddleware::ParseJson
  end

  obj = conn.get("/#{user}/#{repo}/graphs/owner_participation").body
  p obj
  obj
end

get "/" do
  haml :index
end

get "/auth/:name/callback" do
  auth = request.env['omniauth.auth']
  session[:github_token] = auth.credentials.token
  haml :user_form
end

post "/tune" do
  user = params[:user].strip
  j=0
  @total_activities = []
  repositories(user, session[:github_token]).each do |repo|
    j+=1
    activities(user, repo['name'])['owner'].each_with_index do |week_activities, week|
      if total_activities[week]
        total_activities[week] += week_activities.to_i
      else
        total_activities[week] = 0
      end
    end
    break if j > 15
  end

  @total_activities
  haml :user_form
end

get '/tune' do
  haml :tune
end
