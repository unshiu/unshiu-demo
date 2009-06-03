module ManageMngHelperModule
  
  # ポイントマスタを選択するかどうか
  # ポイントマスタが1つなら選択する必要がない
  def master_select?
    @pnt_masters.size != 1 ? true : false
  end
  
end
