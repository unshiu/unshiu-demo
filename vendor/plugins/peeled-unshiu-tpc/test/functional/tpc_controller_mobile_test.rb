require File.dirname(__FILE__) + '/../test_helper'

module TpcControllerMobileTestModule
  
  class << self
    def included(base)
      base.class_eval do
        include TestUtil::Base::MobileControllerTest
        fixtures :base_users
        fixtures :base_friends
        fixtures :tpc_topics
        fixtures :tpc_topic_cmm_communities
      end
    end
  end
  
  define_method('test: 新しくコミュニティトピックを作成する') do
    login_as :aaron
    
    post :new_cmm_topic, :id => 1 , :topic_info => { :cmm_community_id => 1 } # community_id = 1 にトピックを作成
    assert_response :success
    assert_template 'new_cmm_topic_mobile'
  end
  
  define_method('test: コミュニティトピックを作成の確認画面を表示する') do
    login_as :aaron
    
    post :create_confirm, :topic_type => 'TpcTopicCmmCommunity', :topic_info => { :cmm_community_id => 1 }, 
                          :topic => { :title => "新しいトピック", :body => "トピック本文" }
    assert_response :success
    assert_template 'create_confirm_mobile'
  end
  
  define_method('test: コミュニティトピックを作成の確認画面を表示しようとするが本文が空なので入力画面を再表示する') do
    login_as :aaron
    
    post :create_confirm, :topic_type => 'TpcTopicCmmCommunity', :topic_info => { :cmm_community_id => 1 }, 
                          :topic => { :title => "新しいトピック", :body => "" }
    assert_response :success
    assert_template 'new_cmm_topic_mobile'
  end
  
  define_method('test: コミュニティトピックを作成の確認画面を表示しようとするが参加していないコミュニティなので作成不可なのでエラー画面へ遷移する') do
    login_as :ten
    
    post :create_confirm, :topic_type => 'TpcTopicCmmCommunity', :topic_info => { :cmm_community_id => 1 }, 
                          :topic => { :title => "新しいトピック", :body => "トピック本文" }
    assert_response :redirect
    assert_redirect_with_error_code "U-09005"
  end
  
  define_method('test: 参加しているコミュニティのトピックを作成の確認画面を表示しようとするがこのコミュニティは管理者以外トピックが作成不可なのでエラー画面へ遷移する') do
    login_as :quentin
    
    post :create_confirm, :topic_type => 'TpcTopicCmmCommunity', :topic_info => { :cmm_community_id => 1 }, 
                          :topic => { :title => "新しいトピック", :body => "トピック本文" }
    assert_response :redirect
    assert_redirect_with_error_code "U-09005"
  end
  
  define_method('test: コミュニティトピックを作成の実行をする') do
    login_as :aaron
    
    before_tpc_topic_count = TpcTopicCmmCommunity.count(:conditions => ['cmm_community_id = 1'])
    
    post :create_complete, :topic_type => 'TpcTopicCmmCommunity', :topic_info => { :cmm_community_id => 1 }, 
                          :topic => { :title => "新しいトピック", :body => "トピック本文" }
    assert_response :redirect
    assert_redirected_to :action => 'create_cmm_topic_done'
    
    after_tpc_topic_count = TpcTopicCmmCommunity.count(:conditions => ['cmm_community_id = 1'])
    assert_equal(before_tpc_topic_count + 1, after_tpc_topic_count) # 1個トピックが増えている
  end
  
  define_method('test: コミュニティトピックを作成のキャンセルをする') do
    login_as :aaron
    
    before_tpc_topic_count = TpcTopicCmmCommunity.count(:conditions => ['cmm_community_id = 1'])
    
    post :create_complete, :topic_type => 'TpcTopicCmmCommunity', :topic_info => { :cmm_community_id => 1 }, 
                           :topic => { :title => "新しいトピック", :body => "トピック本文" },
                           :cancel => 'true'
    assert_response :success
    assert_template 'new_cmm_topic_mobile'
    
    after_tpc_topic_count = TpcTopicCmmCommunity.count(:conditions => ['cmm_community_id = 1'])
    assert_equal(before_tpc_topic_count, after_tpc_topic_count) # トピックは増えていない
  end
  
  define_method('test: コミュニティトピックを作成の実行をしようとするがこのコミュニティは管理者以外トピックが作成不可なのでエラー画面へ遷移する') do
    login_as :quentin
    
    before_tpc_topic_count = TpcTopicCmmCommunity.count(:conditions => ['cmm_community_id = 1'])
    
    post :create_complete, :topic_type => 'TpcTopicCmmCommunity', :topic_info => { :cmm_community_id => 1 }, 
                          :topic => { :title => "新しいトピック", :body => "トピック本文" }
    assert_response :redirect
    assert_redirect_with_error_code "U-09005"
    
    after_tpc_topic_count = TpcTopicCmmCommunity.count(:conditions => ['cmm_community_id = 1'])
    assert_equal(before_tpc_topic_count, after_tpc_topic_count) # トピックは増えていない
  end
  
  define_method('test: コミュニティトピックを作成完了画面を表示する') do
    login_as :aaron
    
    post :create_cmm_topic_done, :id => 1
    assert_response :success
    assert_template 'create_cmm_topic_done_mobile'
  end
end
