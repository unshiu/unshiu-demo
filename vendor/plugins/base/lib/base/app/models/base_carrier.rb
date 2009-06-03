# == Schema Information
#
# Table name: base_carriers
#
#  id         :integer(4)      not null, primary key
#  name       :string(256)     default(""), not null
#  created_at :datetime
#  updated_at :datetime
#  deleted_at :datetime
#

module BaseCarrierModule
  class << self
    def included(base)
      base.extend(ClassMethods)
      base.class_eval do
        acts_as_paranoid
        has_many :base_users
        
        # constant
        const_set('CARRIER_DOCOMO', "docomo")
        const_set('CARRIER_AU', "au")
        const_set('CARRIER_SOFTBANK', "softbank")
        const_set('CARRIER_OTHER', "other")
      end
    end
  end
  
  module ClassMethods
    # キャリアオブジェクトでキャリアを検索する
    # _param1_:: carrier_obj Jpmobile::Mobile以下のキャリアオブジェクト
    # return  :: string
    def find_by_carrier(carrier_obj)
      name = carrier_name(carrier_obj) 
      find(:first, :conditions => [' name = ? ', name])
    end
    
    # キャリア名を返す。
    # docomo,au,softbank以外はその他とする
    # _param1_:: carrier_obj Jpmobile::Mobile以下のキャリアオブジェクト
    # return  :: string
    def carrier_name(carrier_obj)
      return BaseCarrier::CARRIER_OTHER if carrier_obj.nil?
      
      if carrier_obj.class == Jpmobile::Mobile::Docomo
        return BaseCarrier::CARRIER_DOCOMO
      elsif carrier_obj.class == Jpmobile::Mobile::Au
        return BaseCarrier::CARRIER_AU
      elsif carrier_obj.class == Jpmobile::Mobile::Softbank || carrier_obj.class == Jpmobile::Mobile::Vodafone
        return BaseCarrier::CARRIER_SOFTBANK
      else
        return BaseCarrier::CARRIER_OTHER
      end
    end
    
  end
  
  def carrier=(carrier_obj)
    self.name = BaseCarrier.carrier_name(carrier_obj) 
  end
  
  # キャリアごとの登録ユーザ数を返す
  # return  :: integer
  def count_base_user
    BaseUser.count(:conditions => ['base_users.base_carrier_id = ?', self.id])
  end
end
