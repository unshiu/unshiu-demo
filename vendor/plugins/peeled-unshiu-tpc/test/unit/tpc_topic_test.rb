require File.dirname(__FILE__) + '/../test_helper'

module TpcTopicTestModule
  
  class << self
    def included(base)
      base.class_eval do
        fixtures :cmm_communities
        fixtures :cmm_communities_base_users
        fixtures :base_users
        fixtures :tpc_topics
      end
    end
  end
  
  def test_latest_at
    t1 = TpcTopic.find 1
    assert_equal t1.last_commented_at, t1.latest_at

    # last_commented_atがnil
    t3 = TpcTopic.find 3
    assert_equal t3.created_at, t3.latest_at
  end

  define_method('test: トッピックの新規作成時は最終コメント時刻に作成時間がはいる') do
    topic = TpcTopic.create({:title => "new create", :body => "new create body", :base_user_id => 1})
    assert_equal(topic.created_at, topic.last_commented_at)
  end
  
end
