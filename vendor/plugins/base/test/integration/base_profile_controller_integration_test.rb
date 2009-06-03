require "#{File.dirname(__FILE__)}/../test_helper"

module BaseProfileControllerIntegrationTestModule
  
  class << self
    def included(base)
      base.class_eval do
        fixtures :base_users
        fixtures :base_profiles
        fixtures :base_ng_words
        fixtures :base_errors
      end
    end
  end
  
end