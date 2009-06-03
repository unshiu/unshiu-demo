

module PntHistorySummaryGenerateModule
  
  class << self
    def included(base)
      base.class_eval do
        include TestUtil::Base::PcControllerTest
        fixtures :base_users
        fixtures :base_user_roles
        fixtures :pnt_masters
        fixtures :pnt_points
        fixtures :pnt_histories
        fixtures :pnt_history_summaries
      end
    end
  end
  
  define_method('test: 先月の取引履歴情報を生成する') do 
    
    system("ruby #{RAILS_ROOT}/script/pnt_history_summary_generate > #{RAILS_ROOT}/log/pnt_history_summary_generate_test.log")
    
    pnt_history_summary = PntHistorySummary.find(:first, :order => ['created_at desc']) # 最新の履歴
    assert_equal pnt_history_summary.kind_type, 3
    
    # 本当は値まで調べたいがテスト日によって集計値がかわってしまうので値がはいっていることのみ確認する。
    # 集計値が正しいかどうかは PntHistorySummaryのUnitテストで証明している
    assert_not_nil pnt_history_summary.sum_issue_point
    assert_not_nil pnt_history_summary.sum_use_point
    assert_not_nil pnt_history_summary.record_count
  end
  
end