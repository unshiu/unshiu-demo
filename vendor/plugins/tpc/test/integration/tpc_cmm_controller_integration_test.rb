require "#{File.dirname(__FILE__)}/../test_helper"

module TpcCmmControllerIntegrationTestModule
  
  class << self
    def included(base)
      base.class_eval do
        fixtures :base_users
        fixtures :base_friends
        fixtures :tpc_topics
        fixtures :tpc_comments
        fixtures :tpc_topic_cmm_communities
        fixtures :base_errors
      end
    end
  end
  
  define_method('test: トピックを閲覧しようとするが閲覧権限がないのでエラー画面へ遷移') do 
    post "base_user/login", :login => "ten", :password => "test"
    
    post "tpc_cmm/show", :id => 6 # tpc_topic_cmm_communities_id = 6 は閲覧制限あり
    assert_response :redirect 
    assert_redirected_to :action => 'error'
    
    follow_redirect!
     
    assert_equal assigns(:error_code), "U-09001"
  end
  
  define_method('test: トピックにコメントを書こうとするがコミュニティに参加していないのでエラー画面へ遷移') do 
    post "base_user/login", :login => "ten", :password => "test"
    
    post "tpc_cmm/new_comment", :id => 6 # tpc_topic_cmm_communities_id = 6 は閲覧制限あり
    assert_response :redirect 
    assert_redirected_to :action => 'error'
    
    follow_redirect!
     
    assert_equal assigns(:error_code), "U-09002"
  end
  
  define_method('test: トピックを削除しようとするが管理者ではないのでエラー画面へ遷移') do 
    post "base_user/login", :login => "aaron", :password => "test"
    
    post "tpc_cmm/delete_confirm", :id => 6
    assert_response :redirect 
    assert_redirected_to :action => 'error'
    
    follow_redirect!
     
    assert_equal assigns(:error_code), "U-09003"
  end
  
  define_method('test: トピックのコメントを削除しようとするが削除する権限がないのでエラー画面へ遷移') do 
    post "base_user/login", :login => "three", :password => "test"
    
    post "tpc_cmm/delete_comment_confirm", :id => 1
    assert_response :redirect 
    assert_redirected_to :action => 'error'
    
    follow_redirect!
     
    assert_equal assigns(:error_code), "U-09004"
  end
  
end