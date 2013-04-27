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

#@connection = HTTPClient.new
#@connection.set_cookie_store('/tmp/cookie.dat')

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

#def vidurl
#  h = Hashtag.last
#  q = URI.escape(h.name)
#  #  Connection.instance.post("http://vineviewer.co/actions/search.php?q=blah%2Fv%2F+&rpp=100&page=1", params)
#  
#end

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

