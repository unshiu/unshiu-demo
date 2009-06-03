require "#{File.dirname(__FILE__)}/../test_helper"

module TpcControllerIntegrationTestModule
  
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
  
  define_method('test: コミュニティトピックを作成の確認画面を表示しようとするが参加していないコミュニティなので作成不可なのでエラー画面へ遷移する') do
    post "base_user/login", :login => "ten", :password => "test"
    
    post "tpc/create_confirm", :topic_type => 'TpcTopicCmmCommunity', :topic_info => { :cmm_community_id => 1 }, 
                               :topic => { :title => "新しいトピック", :body => "トピック本文" }
    assert_response :redirect
    assert_redirected_to :action => 'error'
    
    follow_redirect!
     
    assert_equal assigns(:error_code), "U-09005"
  end
  
  define_method('test: 参加しているコミュニティのトピックを作成の確認画面を表示しようとするがこのコミュニティは管理者以外トピックが作成不可なのでエラー画面へ遷移する') do
    post "base_user/login", :login => "quentin", :password => "test"
    
    post "tpc/create_confirm", :topic_type => 'TpcTopicCmmCommunity', :topic_info => { :cmm_community_id => 1 }, 
                               :topic => { :title => "新しいトピック", :body => "トピック本文" }
    assert_response :redirect
    assert_redirected_to :action => 'error'
    
    follow_redirect!
     
    assert_equal assigns(:error_code), "U-09005"
  end
  
end