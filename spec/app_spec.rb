require 'spec_helper'

def app
  @app ||= Sinatra::Application
end

describe "VinLookerUpper" do
  include Rack::Test::Methods

  let(:admin_params) {
    { :email => "j@a.com",
      :password => "password",
      :password_confirmation => "password",
      :permission_level => -1
    }
  }
 let(:normal_params) {
   { :email => "a@j.com",
     :password => "foobar",
     :password_confirmation => "foobar"
   }
 }

  before(:all) do
    DataMapper.auto_migrate!
    #create one admin user and one normal user
    @admin_user = User.set(admin_params)
    @normal_user = User.set(normal_params)
  end

  describe "authentication" do

    it "should allow admin users to create new users" do
      session[:user] = @admin_user.id
      post "/create_user", normal_params.merge({:email => "hurp@durp.com" })
      follow_redirect!
      flash[:notice].should == "Account created."
      User.count(:email => "hurp@durp.com").should == 1
    end

  end
end
