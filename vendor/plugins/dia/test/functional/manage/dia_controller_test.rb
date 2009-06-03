require File.dirname(__FILE__) + '/../../test_helper'

module Manage
  module DiaControllerTestModule
    
    class << self
      def included(base)
        base.class_eval do
          include TestUtil::Base::PcControllerTest
          
          fixtures :base_users
          fixtures :base_friends
          fixtures :dia_diaries
          fixtures :dia_entries
          fixtures :dia_entry_comments
        end
      end
    end
  
    define_method('test: 日記管理トップページを表示する') do 
      login_as :quentin
    
      post :index
      assert_response :redirect
      assert_redirected_to :controller => 'manage/dia_entry', :action => 'list'
    end
  end
end
