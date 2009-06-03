require File.dirname(__FILE__) + '/../test_helper'

module AceAccessLogTestModule
  
  class << self
    def included(base)
      base.class_eval do
        fixtures :ace_access_logs
      end
    end
  end
  
  define_method('test: アクセスログを作成する') do 
    @valid_attributes = {
      :host => "127.0.0.1", :response_code => "200", :request_url => "/hoge/hoge", :user_agent => "firefox", 
      :base_user_id => 1, :access_at => Time.now, :created_at => Time.now, :updated_at => Time.now
    }
    
    AceAccessLog.create!(@valid_attributes)
  end
end