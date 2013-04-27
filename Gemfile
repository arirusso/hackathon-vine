source 'https://rubygems.org'
gem "data_mapper"
gem "httpclient"
gem "sinatra"
gem "unicorn"
gem "nokogiri"

group :production do
  gem 'dm-postgres-adapter'
end

group :test, :development do
  gem 'dm-sqlite-adapter'
end
