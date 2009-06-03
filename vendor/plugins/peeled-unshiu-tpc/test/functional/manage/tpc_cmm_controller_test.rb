require File.dirname(__FILE__) + '/../../test_helper'

module Manage::TpcCmmControllerTestModule

  class << self
    def included(base)
      base.class_eval do
        include TestUtil::Base::PcControllerTest

        fixtures :base_users
        fixtures :base_friends
        fixtures :tpc_topics
        fixtures :tpc_topic_cmm_communities
        fixtures :tpc_comments
      end
    end
  end

  define_method('test: コミュニティのトピック詳細を表示する') do
    login_as :quentin

    post :show, :id => 1 # tpc_tpic_cmm_community id = 1 のコミュニティのトピックの詳細
    assert_response :success
    assert_template 'show'

    assert_not_nil(assigns['topic'])
    assert_not_nil(assigns['community'])
    assert_not_nil(assigns['comments'])
  end
  
  define_method('test: コミュニティ内のトピック一覧を表示する') do
    login_as :quentin

    post :list, :id => 1 # cmm_community id = 1 のコミュニティのトピック一覧
    assert_response :success
    assert_template 'list'

    assert_not_nil(assigns['topics'])
    assert_not_nil(assigns['community'])
  end
  
  define_method('test: コミュニティ横断で全トピック一覧を表示する') do
    login_as :quentin

    post :alllist
    assert_response :success
    assert_template 'alllist'

    assert_not_nil(assigns['topics'])
  end
  
  define_method('test: 特定のコミュニティの中からトピックを検索する') do
    login_as :quentin

    post :search, :id => 1, :keyword => 'あ' # cmm_commuity id = 1 のコミュニティ内でトピックを検索する
    assert_response :success
    assert_template 'list'

    assert_not_nil(assigns['topics'])
    assert_not_nil(assigns['community'])
  end
  
  define_method('test: 全コミュニティの中からトピックを検索する') do
    login_as :quentin

    post :allsearch, :keyword => 'あ'
    assert_response :success
    assert_template 'alllist'

    assert_not_nil(assigns['topics'])
  end
  
  define_method('test: トピック削除の確認画面を表示する') do
    login_as :quentin

    post :delete_confirm, :id => 1 # tpc_tpic_cmm_community id = 1 のコミュニティのトピック
    assert_response :success
    assert_template 'delete_confirm'

    assert_not_nil(assigns['topic'])
    assert_not_nil(assigns['community'])
  end
  
  define_method('test: トピック削除の実行をする') do
    login_as :quentin

    before_tpc_topic_cmm_community = TpcTopicCmmCommunity.find_by_id(1)
    tpc_topic_id = before_tpc_topic_cmm_community.tpc_topic.id
    
    post :delete_complete, :id => 1 # tpc_tpic_cmm_community id = 1 のコミュニティのトピック
    assert_response :redirect
    assert_redirected_to :controller => 'manage/cmm', :action => :show, :id => 1

    after_tpc_topic_cmm_community = TpcTopicCmmCommunity.find_by_id(1)
    assert_nil(after_tpc_topic_cmm_community) # トピック関連は削除
    tpc_topic = TpcTopic.find_by_id(tpc_topic_id)
    assert_nil(tpc_topic) # トピックも削除
    tpc_comments = TpcComment.find(:all, :conditions => ["tpc_topic_id = #{tpc_topic_id}"])
    assert_equal(tpc_comments.size, 0) # トピックコメントも削除
  end
  
  define_method('test: トピック削除の実行のキャンセルをする') do
    login_as :quentin

    before_tpc_topic_cmm_community = TpcTopicCmmCommunity.find_by_id(1)
    tpc_topic_id = before_tpc_topic_cmm_community.tpc_topic.id
    
    post :delete_complete, :id => 1, :cancel => 'true' 
    assert_response :redirect
    assert_redirected_to :action => 'show'

    after_tpc_topic_cmm_community = TpcTopicCmmCommunity.find_by_id(1)
    assert_not_nil(after_tpc_topic_cmm_community) # トピック関連は削除されていない
    tpc_topic = TpcTopic.find_by_id(tpc_topic_id)
    assert_not_nil(tpc_topic) # トピックも削除されてない
    tpc_comments = TpcComment.find(:all, :conditions => ["tpc_topic_id = #{tpc_topic_id}"])
    assert_not_equal(tpc_comments.size, 0) # トピックコメントも削除されてない
  end
  
  define_method('test: トピックコメント削除の確認画面を表示する') do
    login_as :quentin

    post :delete_comment_confirm, :id => 1 # tpc_comment = 1 のトピックコメント
    assert_response :success
    assert_template 'delete_comment_confirm'

    assert_not_nil(assigns['topic'])
    assert_not_nil(assigns['comment'])
    assert_not_nil(assigns['community'])
  end
  
  define_method('test: トピックコメント削除実行をする') do
    login_as :quentin

    post :delete_comment_complete, :id => 1 # tpc_comment = 1 のトピックコメント
    assert_response :redirect
    assert_redirected_to :action => 'show'

    tpc_comment = TpcComment.find_by_id(1)
    assert_not_nil(tpc_comment) 
    assert_equal(tpc_comment.invisibled_by_anyone?, true) # 削除されている
  end
  
  define_method('test: トピックコメント削除実行のキャンセルをする') do
    login_as :quentin

    post :delete_comment_complete, :id => 1, :cancel => 'true' # tpc_comment = 1 のトピックコメント
    assert_response :redirect
    assert_redirected_to :action => 'show'

    tpc_comment = TpcComment.find_by_id(1)
    assert_not_nil(tpc_comment) 
    assert_equal(tpc_comment.invisibled_by_anyone?, false) # 削除されてはいない
  end
end