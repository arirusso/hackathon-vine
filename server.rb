require "data_mapper"
require "json"
require "net/http"
require "sinatra"
require "uri"

DataMapper.setup(:default, ENV['DATABASE_URL'] || "sqlite3://#{Dir.pwd}/development.db")

class Hashtag
  include DataMapper::Resource
  property :id,        Serial  
  property :url,  Text
  property :name,         String, :required => true
  property :submitted_at, DateTime
end
DataMapper.finalize
#DataMapper.auto_migrate!
def taglist
  Hashtag.all.map(&:name).reverse.map { |n| "<li>#{n}</li>" }.join
end

def form
  '<form name="input" action="/" method="post">
   <h1>Music Hackathon @ Jazz & Technology Forum</h1>
   <h2>April 27, 2013</h2>
   <h3>Enter a hashtag</h3> <br /><input type="text" name="hashtag">
   <input type="submit" value="Submit">
   </form>
   <h4>Hashtags so far:</h4>
   <ul>
  ' + taglist +
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

def redirected_url(url)
  #"https://vine.co/v/bxhYjjTXW7v" # placeholder
  url = "https://#{url}" unless url =~ /^http/
  uri = URI.parse(url)
  http = Net::HTTP.new(uri.host, uri.port)
  request = Net::HTTP::Get.new(uri.request_uri)
  http.use_ssl = true if uri.port == 443
  response = http.request(request)
  url = response.code == "301" ? response["location"] : nil
  url if url.match(/vine\.co/)
end

def video_url_from(url)
  "https://vines.s3.amazonaws.com/videos/2013/04/27/4D7D48D6-257F-40B1-9E7D-996AEAC39A3C-3644-00000332370EC914_1.0.7.mp4?versionId=0sdbPSuCYORPfdjaSaUdU7rECF2K9wfE" # placeholder
end

def url_from_result(result)
  text = result["text"]
  url = text.split(/\ /).last
  if url.match(/https?:\/\/[\S]+/)
    redirected_url = redirected_url(url)
    unless redirected_url.nil?
      video_url = video_url_from(redirected_url)
      video_url unless video_url.nil?
    end
  end
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

def find_good_video
  tags = Hashtag.last
end

##################### API

get "/" do
  form
end

post "/" do
  tag = params[:hashtag]
  url = latest_valid_url(tag)
  unless url.nil?
    Hashtag.new(:name => tag, :url => url, :submitted_at => Time.now).save
  end
  redirect "/"
end

get "/video" do  
  video = find_good_video
  content_type :json
  video.nil? ? {} : { :query => video[:name], :url => video[:url] }.to_json
end

get "/player" do
  File.read(File.join('.', 'player.html'))
end
