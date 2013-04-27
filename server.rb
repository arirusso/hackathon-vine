require "data_mapper"
require "json"
require "net/http"
require "sinatra"
require "uri"

DataMapper.setup(:default, ENV['DATABASE_URL'] || "sqlite3://#{Dir.pwd}/development.db")

class Hashtag
  include DataMapper::Resource
  property :id,        Serial  
  property :name,         String, :required => true
  property :submitted_at, DateTime
end
DataMapper.finalize

#Hashtag.auto_migrate!

def form
  hashtags = Hashtag.all.map(&:name).map { |n| "<li>#{n}</li>" }.join
  '<form name="input" action="/" method="post">
   <h1>Music Hackathon @ Jazz & Technology Forum</h1>
   <h2>April 27, 2013</h2>
   <h3>Enter a hashtag</h3> <br /><input type="text" name="hashtag">
   <input type="submit" value="Submit">
   </form>
   <h4>Hashtags so far:</h4>
   <ul>
  ' + hashtags +
  '</ul>'
end

def video_url(query)
  q = URI.escape(query)
  "http://vineviewer.co/actions/search.php?q=#{q}%2Fv%2F+&rpp=100&page=1"
end

def video_query(query)
  url = video_url(query)
  uri = URI.parse(url)
  http = Net::HTTP.new(uri.host, uri.port)
  request = Net::HTTP::Get.new(uri.request_uri)
  response = http.request(request)
  if !response.nil? && !response.code.nil? && response.code == "200" && !response.body.nil?
    data = JSON.parse(response.body)
    data["results"] if !data["results"].nil?
  end
end

def url_from_result(result)
  text = result["text"]
  url = text.split(/\ /).last
  url.match(/https?:\/\/[\S]+/) ? url : nil
end

def url_from_results(results)
  results.each do |r| 
    url = url_from_result(r)
    return url unless url.nil?
  end
  nil
end

def latest_valid_url(hashtag)
  results = video_query(hashtag)
  url_from_results(results)
end

def find_good_query(queries)
  queries.each do |query|
    url = latest_valid_url(query)
    return { :name => query, :url => url } unless url.nil?
  end
  nil
end

def find_good_video
  hashtags = Hashtag.all
  queries = hashtags.reverse.map(&:name)
  find_good_query(queries) 
end

get "/" do
  form
end

post "/" do
  Hashtag.create(:name => params[:hashtag], :submitted_at => Time.now).save
  redirect "/"
end

get "/video" do  
  video = find_good_video
  content_type :json
  { :query => video[:name], :url => video[:url] }.to_json
end
