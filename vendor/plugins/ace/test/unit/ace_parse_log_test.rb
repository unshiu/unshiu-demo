require File.dirname(__FILE__) + '/../test_helper'

module AceParseLogTestModule
  
  class << self
    def included(base)
      base.class_eval do
        fixtures :ace_parse_logs
      end
    end
  end
  
  define_method('test: アクセス解析ログを作成する') do 
    @valid_attributes = {
      :client_id => 1, :filename => "test", :complate_point => 0, :created_at => Time.now, :updated_at => Time.now
    }
    
    AceParseLog.create!(@valid_attributes)
  end
  
end