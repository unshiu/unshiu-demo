module BaseProfileHelperModule
  
  # 最終ログイン日付からログインステータスを表示する
  # _param1_:: Time value 
  def login_status(value)
    [1, 3, 5, 30].each do |min|
      return "#{min}分以内" if value > Time.now - min * 60
    end
    [1, 3].each do |hour|
      return "#{hour}時間以内" if value > Time.now - hour * 60 * 60
    end
    [1, 3, 7].each do |day|
      return "#{day}日以内" if value > Time.now - day * 60 * 60 * 24
    end
    
    "1週間以上前"
  end
  
end
