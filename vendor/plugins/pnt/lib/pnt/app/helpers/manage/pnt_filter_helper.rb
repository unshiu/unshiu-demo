module ManagePntFilterHelperModule
  
  # 配布期間をもっているか
  def has_limit_day?
    @pnt_filter.start_at.nil? ? false : true
  end
  
  # 配布限度をもっているか
  def has_limit_stock?
    @pnt_filter.has_limit? ? true : false
  end
  
  # 配布ルールをもっているか
  def has_limit_rule?
    @pnt_filter.rule_day.nil? ? false : true
  end
  
end