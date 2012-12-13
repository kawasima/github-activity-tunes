# encoding: utf-8

require 'sinatra'
require 'sinatra/reloader' if development?
require 'sinatra/content_for'

require 'json'
require 'yaml'
require 'haml'
require 'omniauth'
require 'omniauth-github'
require 'faraday'
require 'faraday_middleware'

set :haml, { :format => :html5 }
set :cacheDir, "cache"
enable :sessions, :logging

before do
#  request.script_name = '/github-activity-tunes'
end

use OmniAuth::Builder do
  provider :github, ENV['clientId'], ENV['clientSecret']
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

  conn.get("/#{user}/#{repo}/graphs/owner_participation").body
end

get "/" do
  if session[:github_token]
    haml :user_form
  else
    haml :index
  end
end

get "/auth/:name/callback" do
  auth = request.env['omniauth.auth']
  session[:github_token] = auth.credentials.token
  haml :user_form
end

post "/tune" do
  @user = params[:user].strip
  cache_file = "#{settings.cacheDir}/#{@user}.yml"
  if File.file? cache_file
    @total_activities = YAML.load_file(cache_file)
  else
    @total_activities = []
    repositories(@user, session[:github_token]).each_with_index do |repo, repo_index|
      next unless repo
      (activities(@user, repo['name']) || { 'owner' => []})['owner'].each_with_index do |week_activities, week|
        if @total_activities[week]
          @total_activities[week] += week_activities.to_i
        else
          @total_activities[week] = 0
        end
      end
      break if repo_index > 15
    end
    @total_activities.reverse!
    YAML.dump(@total_activities, File.open(cache_file, 'w'))
  end

  haml :tune
end

get '/tune' do
  haml :tune
end
