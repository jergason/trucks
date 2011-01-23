require 'spec_helper'

def app
  @app ||= Sinatra::Application
end

describe "VinLookerUpper" do
  include Rack::Test::Methods
end
