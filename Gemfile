source "http://rubygems.org"

gem "sinatra"
gem "rake"
gem "haml"
gem "padrino-helpers"
gem "pony"
gem "dm-core"
gem "dm-migrations"
gem "dm-aggregates"
gem "dm-serializer"
gem "rack-flash"
gem "sinatra-authentication", :path => "/Users/jergason/Dropbox/sinatra-authentication"#:git => "git://github.com/jergason/sinatra-authentication.git"

group :test do
  gem "rspec"
  gem "rack-test"
end

group :production do
  gem "heroku"
  gem "dm-postgres-adapter"
end

group :development, :test do
  gem "sinatra-reloader", :require => "sinatra/reloader"
  gem "dm-sqlite-adapter"
  gem "pp"
end
