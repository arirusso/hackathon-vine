source 'https://rubygems.org'
gem "data_mapper"
gem "httpclient"
gem "sinatra"
gem "unicorn"

group :production do
  gem 'dm-postgres-adapter'
end

group :test, :development do
  gem 'dm-sqlite-adapter'
end
