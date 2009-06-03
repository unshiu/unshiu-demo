module ManageMngSystemHelperModule
  
  # 秒数をわかりやすく単位変換する
  def sec_format(value)
    return "#{value / 60}分" if value / 60 < 60
    return "#{value / 60 / 60}時" if value / 60 / 60 < 60
    return "#{value / 60 / 60 / 24}日" if value / 60 / 60 / 24 < 24
  end
  
  # df 結果を整形
  def df_format(value)
    value.gsub(/ /,'&nbsp;')
  end
  
  # backgroudrb情報を整形
  def backgrourndrb_info_format(value)
    value.pretty_inspect.gsub(/\},/,'},<br/>')
  end
  
end
