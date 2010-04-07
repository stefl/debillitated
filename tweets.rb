require 'rubygems'
require 'ccsv'
require 'rubygems'
require 'sinatra'
require 'haml'
require 'activesupport'

class Site 
  
  @@pro_mps = []
  @@anti_mps = []
  @@unknown_mps = []
  @@late_mps = []
  @@mps = []
  @@bothered = []
  @@tweets = []
  @@cols = []
  @@number_of_tweets = 0
  @@number_of_twitterers = 0
  
  cattr_accessor :cols
  cattr_accessor :bothered
  cattr_accessor :tweets
  cattr_accessor :mps
  cattr_accessor :pro_mps
  cattr_accessor :anti_mps
  cattr_accessor :unknown_mps
  cattr_accessor :late_mps
  cattr_accessor :number_of_tweets
  cattr_accessor :number_of_twitterers
  cattr_accessor :usernames
   
  def self.load
    
    # Load in the data from text files
    @@mps = YAML.load_file( "mps.yaml" )
    puts @@mps.inspect

    @@bothered = YAML.load_file("bothered.yaml")

    @@mps.each do |mp|
      if @@bothered["Pro"].include?(mp.ivars["full_name"])
        @@pro_mps << mp
      end
      if @@bothered["Anti"].include?(mp.ivars["full_name"])
        @@anti_mps << mp
      end
      if @@bothered["Unknown"].include?(mp.ivars["full_name"])
        @@unknown_mps << mp
      end
      if @@bothered["Late"].include?(mp.ivars["full_name"])
        @@late_mps << mp
      end
    end

    
    y = 0
    first_line = true
    Ccsv.foreach("tweets.csv") do |values|
      if (first_line == true)
        values.each do |val|
          @@cols << val.to_sym
        end
        first_line = false

      else
        tweet = {}
        x = 0
        values.each do |val|
          tweet[@@cols[x]] = val
          x = x+1
        end

        @@tweets << tweet
      end
      y = y+1
      #break if y > 200
    end

    @@usernames = {}

    @@tweets.each do |tweet|
      @@usernames[tweet[:from_user]] = tweet[:from_user_id]
    end

    @@number_of_tweets = @@tweets.size
    @@number_of_twitterers = @@usernames.size

    @@tweets.reverse!

  end

end

Site.load

get '/' do
  response.headers['Cache-Control'] = "public, max-age=#{60*60}"
  haml :index
end

get '/tweet/:index' do |index|
  @tweet = Site.tweets[index.to_i]
  @index = index
  haml :tweet, :layout => false
end

get '/css/:file.css' do
  content_type "text/css", :charset => "utf-8"
  response.headers['Cache-Control'] = "public, max-age=#{60*60}"
  sass "sass/#{params[:file]}".to_sym
end