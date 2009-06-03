require File.dirname(__FILE__) + '/../test_helper'

module TpcCommentTestModule
  
  class << self
    def included(base)
      base.class_eval do
        fixtures :cmm_communities
        fixtures :cmm_communities_base_users
        fixtures :base_users
        fixtures :tpc_topics
        fixtures :tpc_comments
        fixtures :tpc_topics
        fixtures :base_ng_words
      end
    end
  end

  define_method('test: 関連を確認') do
    tpc_comment = TpcComment.find_by_id(1)
    assert_not_nil(tpc_comment.tpc_topic)
    assert_not_nil(tpc_comment.base_user)
  end
  
  define_method('test: validateを確認する') do
    base_ng_word = BaseNgWord.find_by_id(1) # 定義再ロード
    
    tpc_comment = TpcComment.new
    tpc_comment.body = "body"
    assert_equal(tpc_comment.valid?, true)
    
    tpc_comment.body = "あ" * 2001 
    assert_equal(tpc_comment.valid?, false)
    
    tpc_comment.body = "aaa" # NG word
    assert_equal(tpc_comment.valid?, false)
  end
  
  define_method('test: あるトピックの最新のコメントを指定数分取得する') do
    tpc_topic = TpcTopic.find_by_id(1)
    tpc_comments = tpc_topic.tpc_comments.recent(3)
    
    assert_not_nil(tpc_comments)
    assert_equal(tpc_comments.length, 3)
    
    tpc_comments = tpc_topic.tpc_comments.recent(1)
    assert_equal(tpc_comments.length, 1)
  end
  
  define_method('test: コメントを更新したらトピックの最終コメント時刻が更新されている') do
    before_lasted_comment = TpcTopic.find_by_id(1).last_commented_at
    sleep(1)
    tpc_comment = TpcComment.new({:tpc_topic_id => 1, :body => "body", :base_user_id => 1})
    tpc_comment.save!
    
    assert_not_equal(before_lasted_comment, TpcTopic.find_by_id(1).last_commented_at) # 更新されているので違う
  end
  
  define_method('test: コメントを追加されるとトピックのコメント数は自動で更新される') do
    tpc_topic = TpcTopic.find(1)
    
    comment = TpcComment.new(:tpc_topic_id => tpc_topic.id, :title => "hoge", :body => "hoge", :base_user_id => 1)
    comment.save
    
    assert_equal(TpcTopic.find(1).tpc_comments.count, TpcTopic.find(1).comment_count)
  end
end
