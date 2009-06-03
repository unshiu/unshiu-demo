require File.dirname(__FILE__) + '/../test_helper'

module TpcCmmControllerTestModule
  
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
  
  define_method('test: list はコミュニティのトピック一覧を表示する') do
    login_as :aaron
    
    post :list, :id => 1 # cmm_community_id = 1 のコミュニティのトピック一覧
    assert_response :success
    assert_template 'list'
    
    assert_not_nil(assigns['topics'])
    assert_not_nil(assigns['community'])
    assert_not_nil(assigns['members'])
  end
  
  define_method('test: list はコミュニティのトピックを古い順に表示する') do
    login_as :aaron
    
    TpcTopicCmmCommunity.record_timestamps = false
    topic = TpcTopic.new({:title => "oldest", :body => "oldest topic", :base_user_id => 1})
    topic.save
    tpc_topic_cmm_community = TpcTopicCmmCommunity.new({:tpc_topic_id => topic.id, :cmm_community_id => 1, :public_level => 1,
                                                        :created_at => Time.now - 1.year, :updated_at => Time.now - 1.year})
    tpc_topic_cmm_community.save
    TpcTopicCmmCommunity.record_timestamps = true
    
    post :list, :id => 1, :order => "asc" # cmm_community_id = 1 のコミュニティのトピック一覧
    assert_response :success
    assert_template 'list'
    
    assert_not_nil(assigns['topics'])
    assert_not_nil(assigns['community'])
    assert_not_nil(assigns['members'])
    
    assert_equal(assigns['topics'].to_a[0].tpc_topic.body, "oldest topic")
    before_topic = assigns['topics'].to_a[0].updated_at
    assigns['topics'].each do |topic|
      assert(topic.updated_at >= before_topic)
      before_topic = topic.updated_at
    end
  end
  
  define_method('test: list はコミュニティのトピックを新しいに表示する') do
    login_as :aaron
    
    TpcTopicCmmCommunity.record_timestamps = false
    topic = TpcTopic.new({:title => "newest", :body => "newest topic", :base_user_id => 1})
    topic.save
    tpc_topic_cmm_community = TpcTopicCmmCommunity.new({:tpc_topic_id => topic.id, :cmm_community_id => 1, :public_level => 1,
                                                        :created_at => Time.now + 1.year, :updated_at => Time.now + 1.year})
    tpc_topic_cmm_community.save
    TpcTopicCmmCommunity.record_timestamps = true
    
    post :list, :id => 1, :order => "desc" # cmm_community_id = 1 のコミュニティのトピック一覧
    assert_response :success
    assert_template 'list'
    
    assert_not_nil(assigns['topics'])
    assert_not_nil(assigns['community'])
    assert_not_nil(assigns['members'])
    
    assert_equal(assigns['topics'].to_a[0].tpc_topic.body, "newest topic")
    before_topic = assigns['topics'].to_a[0].updated_at
    assigns['topics'].each do |topic|
      assert(topic.updated_at <= before_topic)
      before_topic = topic.updated_at
    end
  end
  
  define_method('test: list はコミュニティのトピックをコメントが多い順に表示する') do
    login_as :aaron
    
    topic = TpcTopic.new({:title => "max comment", :body => "max comment topic", :base_user_id => 1})
    topic.save
    tpc_topic_cmm_community = TpcTopicCmmCommunity.new({:tpc_topic_id => topic.id, :cmm_community_id => 1, :public_level => 1,
                                                        :created_at => Time.now - 1.year, :updated_at => Time.now - 1.year})
    tpc_topic_cmm_community.save
    10.times do |n| 
      tpc_comment = TpcComment.new({:tpc_topic_id => topic.id, :title => "hoge", :body => "hoge", :base_user_id => 1})
      tpc_comment.save
    end
    
    post :list, :id => 1, :order => "comment" # cmm_community_id = 1 のコミュニティのトピック一覧
    assert_response :success
    assert_template 'list'
    
    assert_not_nil(assigns['topics'])
    assert_not_nil(assigns['community'])
    assert_not_nil(assigns['members'])
    
    assert_equal(assigns['topics'].to_a[0].tpc_topic.body, "max comment topic")
    before_comment_count = assigns['topics'].to_a[0].tpc_topic.tpc_comments.size
    assigns['topics'].each do |topic|
      assert(topic.tpc_topic.tpc_comments.size <= before_comment_count)
      before_comment_count = topic.tpc_topic.tpc_comments.size
    end
  end
  
  define_method('test: トピック詳細画面を表示する') do
    login_as :aaron
    
    post :show, :id => 1 # tpc_topic_cmm_community = 1 のトピック詳細
    assert_response :success
    assert_template 'show'
    
    assert_not_nil(assigns['topic'])
    assert_not_nil(assigns['community'])
    assert_not_nil(assigns['comments'])
  end
  
  define_method('test: トピック詳細画面を表示しようとするが、参加者のみ公開のトピックのためエラーページへ遷移') do
    login_as :ten
    
    post :show, :id => 6
    assert_response :redirect
    assert_redirect_with_error_code "U-09001"
  end

  define_method('test: トピック詳細画面でコメントを新着順に表示する') do
    login_as :aaron
    
    TpcComment.record_timestamps = false
    comment = TpcComment.new({:tpc_topic_id => 1, :body => "newest comment", :base_user_id => 1, :created_at => Time.now + 1.year})
    comment.save
    TpcComment.record_timestamps = true
    
    post :show, :id => 1, :comment_order => "desc"
    assert_response :success
    assert_template 'show'
    
    assert_not_nil(assigns['topic'])
    assert_not_nil(assigns['community'])
    assert_not_nil(assigns['comments'])
    
    assert_equal(assigns['comments'].to_a[0].body, "newest comment")
    before_comment = assigns['comments'].to_a[0].created_at
    assigns['comments'].each do |comment|
      assert(comment.created_at <= before_comment)
      before_comment = comment.created_at
    end
  end
  
  define_method('test: トピック詳細画面でコメントを古い順に表示する') do
    login_as :aaron
    
    TpcComment.record_timestamps = false
    comment = TpcComment.new({:tpc_topic_id => 1, :body => "oldest comment", :base_user_id => 1, :created_at => Time.now - 1.year})
    comment.save
    TpcComment.record_timestamps = true
    
    post :show, :id => 1, :comment_order => "asc"
    assert_response :success
    assert_template 'show'
    
    assert_not_nil(assigns['topic'])
    assert_not_nil(assigns['community'])
    assert_not_nil(assigns['comments'])
    
    assert_equal(assigns['comments'].to_a[0].body, "oldest comment")
    before_comment = assigns['comments'].to_a[0].created_at
    assigns['comments'].each do |comment|
      assert(comment.created_at >= before_comment)
      before_comment = comment.created_at
    end
  end
  
  define_method('test: トピック詳細画面でコメント順番指定におかしな値を指定されたらデフォルトの降順で並びかえる') do
    login_as :aaron
    
    TpcComment.record_timestamps = false
    comment = TpcComment.new({:tpc_topic_id => 1, :body => "newest comment", :base_user_id => 1, :created_at => Time.now + 1.year})
    comment.save
    TpcComment.record_timestamps = true
    
    post :show, :id => 1, :comment_order => "'select * from hoge etc... injection'"
    assert_response :success
    assert_template 'show'
    
    assert_not_nil(assigns['topic'])
    assert_not_nil(assigns['community'])
    assert_not_nil(assigns['comments'])
    
    assert_equal(assigns['comments'].to_a[0].body, "newest comment")
    before_comment = assigns['comments'].to_a[0].created_at
    assigns['comments'].each do |comment|
      assert(comment.created_at <= before_comment)
      before_comment = comment.created_at
    end
  end
  
  define_method('test: トピック削除の確認画面を表示する') do
    login_as :aaron
    
    post :delete_confirm, :id => 1 # tpc_topic_cmm_community = 1 のコミュニティのトピックを削除
    assert_response :success
    assert_template 'delete_confirm'
    
    assert_not_nil(assigns['topic'])
  end
  
  define_method('test: トピック削除の確認画面を表示しようとするが、コミュニティ管理者ではないのでエラー画面へ遷移する') do
    login_as :three
    
    post :delete_confirm, :id => 1 # tpc_topic_cmm_community = 1 のコミュニティのトピックを削除
    assert_response :redirect
    assert_redirect_with_error_code "U-09003"
  end
  
  define_method('test: トピック削除の実行をする') do
    login_as :aaron
    
    post :delete_complete, :id => 1 # tpc_topic_cmm_community = 1 のコミュニティのトピックを削除
    assert_response :redirect
    assert_redirected_to :action => :list, :id => 1
    assert_not_nil(flash[:notice])
    
    tpc_topic_cmm_community = TpcTopicCmmCommunity.find_by_id(1)
    assert_nil(tpc_topic_cmm_community) # 削除されている
  end
  
  define_method('test: トピック削除の実行をキャンセルする') do
    login_as :aaron
    
    post :delete_complete, :id => 1, :cancel => 'true'
    assert_response :redirect
    assert_redirected_to :action => :show, :id => 1
    
    tpc_topic_cmm_community = TpcTopicCmmCommunity.find_by_id(1)
    assert_not_nil(tpc_topic_cmm_community) # 削除されていない
  end
  
  define_method('test: トピックコメントを新規作成する') do
    login_as :aaron
    
    before_tpc_topic = TpcTopic.find_by_id(1)
    
    post :create_remote, :id => 1, :comment => { :tpc_topic_id => 1, :body => "new test create comment!!!"}
    assert_response :success
    assert_rjs :visual_effect, :highlight, "tpc_topic_comment_message"
    
    tpc_comment = TpcComment.find(:first, :conditions => ["body = 'new test create comment!!!'"])
    assert_not_nil(tpc_comment)
    
    # コメント最終日が更新されている
    assert_not_equal(before_tpc_topic.last_commented_at, tpc_comment.tpc_topic.last_commented_at)
  end
  
  define_method('test: トピックコメントを新規作成しようとするが内容が空なのでエラーを表示') do
    login_as :aaron
    
    before_tpc_topic = TpcTopic.find_by_id(1)
    
    post :create_remote, :id => 1, :comment => { :tpc_topic_id => 1, :body => ""}
    assert_response :success
    assert_rjs :visual_effect, :highlight, "tpc_topic_comment_message"
    
    tpc_comment = TpcComment.find(:first, :conditions => ["body = ''"])
    assert_nil(tpc_comment)
  end
  
  define_method('test: トピックコメントの削除の確認画面を表示する') do
    login_as :aaron
    
    post :delete_comment_confirm, :id => 1 # tpc_comment_id = 1 のトピックコメントを削除
    assert_response :success
    assert_template 'delete_comment_confirm'
    
    assert_not_nil(assigns['topic'])
    assert_not_nil(assigns['comment'])
  end
  
  define_method('test: トピックコメントを削除の確認画面を表示しようとするが、管理者でもコメントした人でもないのでエラー画面へ遷移する') do
    login_as :three
    
    post :delete_comment_confirm, :id => 1 # tpc_comment_id = 1 のトピックコメントを削除
    assert_response :redirect
    assert_redirect_with_error_code "U-09004"
  end
  
  define_method('test: トピックコメントを削除実行をする') do
    login_as :aaron
    
    post :delete_comment_complete, :id => 1 # tpc_comment_id = 1 のトピックコメントを削除
    assert_response :redirect
    assert_redirected_to :action => :show, :id => 1
    
    tpc_comment = TpcComment.find_by_id(1)
    assert_not_nil(tpc_comment)
    assert_equal(tpc_comment.invisibled_by_anyone?, true)
  end
  
  define_method('test: トピックコメントを削除実行をキャンセル') do
    login_as :aaron
    
    post :delete_comment_complete, :id => 1, :cancel => 'true'
    assert_response :redirect
    assert_redirected_to :action => :show, :id => 1
    
    tpc_comment = TpcComment.find_by_id(1)
    assert_not_nil(tpc_comment)
    assert_equal(tpc_comment.invisibled_by_anyone?, false) # 削除されていない
  end
  
  define_method('test: latest_list は所属コミュニティの最新トピック一覧を表示する') do
    login_as :aaron
    
    post :latest_list
    assert_response :success
    assert_template 'latest_list'
    
    assert_not_nil(assigns['topics'])
  end
  
  define_method('test: commented_list は自分がコメントしたトピック一覧を表示する') do
    login_as :quentin
    
    post :commented_list
    assert_response :success
    assert_template 'commented_list'
    
    assert_not_nil(assigns['topics'])
  end
  
  define_method('test: commented_list はログインしていないと閲覧できない') do
    # login_as :aaron
    
    post :commented_list
    assert_response :redirect
    assert_redirected_to :controller => :base_user, :action => :login, :return_to => '/tpc_cmm/commented_list'
  end
  
  define_method('test: comments はトピックコメント一覧を表示する') do
    login_as :aaron
    
    post :comments, :id => 1 # tpc_topic_cmm_community = 1 のコミュニティのトピックのコメント
    assert_response :success
    assert_template 'comments'
    
    assert_not_nil(assigns['topic'])
    assert_not_nil(assigns['comments'])
  end
  
  define_method('test: comments はトピックコメント一覧を表示しようとするが、参加者のみ公開のトピックのためエラーページへ遷移') do
    login_as :ten
    
    post :comments, :id => 6
    assert_response :redirect
    assert_redirect_with_error_code "U-09001"
  end
  
end