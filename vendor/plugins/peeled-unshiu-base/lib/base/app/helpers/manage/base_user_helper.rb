module ManageBaseUserHelperModule
  
  # ポイントマスタを選択するかどうか
  # ポイントマスタが1つなら選択する必要がない
  def master_select?
    @pnt_masters.size != 1 ? true : false
  end
  
  # ポイント関連情報が有効か。pluginが有効でもマスタが0件なら事実上有効ではない
  def pnt_active?
    @pnt_masters.size != 0 ? true : false
  end
  
  def sex(user)
    profile = user.base_profile
    return '未選択' unless profile
    BaseProfile.sex_kind_name(profile.sex)
  end
  
  def device(user)
    device_name = user.device_name
    return '不明' unless device_name
    device_name
  end
  
  def carrier(user)
    carrier = BaseCarrier.find_by_id(user.base_carrier_id)
    return '不明' unless carrier
    carrier.name
  end
end
