require 'rubygems'
require 'ccsv'
require 'rubygems'
require 'sinatra'
require 'haml'



get '/' do
  response.headers['Cache-Control'] = "public, max-age=#{60*60}"
  
  @mps = YAML.load_file( "mps.yaml" )
  puts @mps.inspect
  
  @bothered = YAML.load_file("bothered.yaml")
  
  @pro_mps = []
  @anti_mps = []
  @unknown_mps = []
  @late_mps = []
  
  @mps.each do |mp|
    if @bothered["Pro"].include?(mp.ivars["full_name"])
      @pro_mps << mp
    end
    if @bothered["Anti"].include?(mp.ivars["full_name"])
      @anti_mps << mp
    end
    if @bothered["Unknown"].include?(mp.ivars["full_name"])
      @unknown_mps << mp
    end
    if @bothered["Late"].include?(mp.ivars["full_name"])
      @late_mps << mp
    end
  end
  
  @tweets = []
  @cols = []
  y = 0
  first_line = true
  Ccsv.foreach("tweets.csv") do |values|
    if (first_line == true)
      values.each do |val|
        @cols << val.to_sym
      end
      first_line = false

    else
      tweet = {}
      x = 0
      values.each do |val|
        tweet[@cols[x]] = val
        x = x+1
      end

      @tweets << tweet
    end
    y = y+1
    #break if y > 20
  end

  @usernames = {}

  @tweets.each do |tweet|
    @usernames[tweet[:from_user]] = tweet[:from_user_id]
  end
  @tweets.reverse!
  haml :index
end

get '/css/:file.css' do
  content_type "text/css", :charset => "utf-8"
  response.headers['Cache-Control'] = "public, max-age=#{60*60}"
  sass "sass/#{params[:file]}".to_sym
end