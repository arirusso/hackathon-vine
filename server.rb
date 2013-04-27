require "data_mapper"
require "json"
require "net/http"
require "sinatra"
require "uri"

#set :port, 8000

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
   <h1>Music Hackathon</h1>
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
  "http://vineviewer.co/actions/search.php?q=#{q}%2Fv%2F+&rpp=1&page=1"
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

#p video_query(Hashtag.last.name)
p video_query("plants").first

get '/' do
  form
end

post '/' do
  Hashtag.create(:name => params[:hashtag], :submitted_at => Time.now).save
  form
end

#post '/video' do
#  vidurl
#  content_type :json
#  { :key1 => 'value1', :key2 => 'value2' }.to_json
#end

