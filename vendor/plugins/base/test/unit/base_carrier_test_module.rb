require File.dirname(__FILE__) + '/../test_helper'

module BaseCarrierTestModule

  class << self
    def included(base)
      base.class_eval do
        include AuthenticatedTestHelper
        fixtures :base_carriers
      end
    end
  end

  # 基本的なリレーションのテスト
  def test_releation
    base_carrier = BaseCarrier.find(1)
    assert_not_nil base_carrier
  end
  
  # キャリア情報をキャリア名に変換しレコードを取得する　test_find_by_carrier　のテスト
  def test_find_by_carrier
    base_carrier = BaseCarrier.find_by_carrier(Jpmobile::Mobile::Docomo.new(nil))
    assert_equal(base_carrier.name, 'docomo')
    
    base_carrier = BaseCarrier.find_by_carrier(Jpmobile::Mobile::Au.new(nil))
    assert_equal(base_carrier.name, 'au')
    
    base_carrier = BaseCarrier.find_by_carrier(Jpmobile::Mobile::Softbank.new(nil))
    assert_equal(base_carrier.name, 'softbank')
    
    base_carrier = BaseCarrier.find_by_carrier(nil)
    assert_equal(base_carrier.name, 'other')
    
  end
  
  # リクエスト情報からキャリアの名前を選別する carrier_name のテスト
  def test_carrier_name
    name = BaseCarrier.carrier_name(Jpmobile::Mobile::Docomo.new(nil))
    assert_equal(name, 'docomo')
    
    name = BaseCarrier.carrier_name(Jpmobile::Mobile::Au.new(nil))
    assert_equal(name, 'au')
    
    name = BaseCarrier.carrier_name(Jpmobile::Mobile::Softbank.new(nil))
    assert_equal(name, 'softbank')
    
    # willcomは種別範囲外なのでother
    name = BaseCarrier.carrier_name(Jpmobile::Mobile::Willcom.new(nil))
    assert_equal(name, 'other')
  end
  
  # キャリアオブジェクトを変換しキャリア名でsetするsetterのテスト
  def test_carrier_setter
    # docomo 
    base_carrier = BaseCarrier.new
    base_carrier.carrier = Jpmobile::Mobile::Docomo.new(nil)
    assert_equal(base_carrier.name, 'docomo')
    
    # au
    base_carrier = BaseCarrier.new
    base_carrier.carrier = Jpmobile::Mobile::Au.new(nil)
    assert_equal(base_carrier.name, 'au')
    
    # softbank
    base_carrier = BaseCarrier.new
    base_carrier.carrier = Jpmobile::Mobile::Softbank.new(nil)
    assert_equal(base_carrier.name, 'softbank')
    
    # willcom 
    base_carrier = BaseCarrier.new
    base_carrier.carrier = Jpmobile::Mobile::Willcom.new(nil)
    assert_equal(base_carrier.name, 'other')    
  end

  define_method('test: キャリアごとのユーザ数を取得する') do 
    base_carrier = BaseCarrier.find(1)
    
    assert_difference 'base_carrier.count_base_user', -1 do
      base_user = BaseUser.find(1)
      base_user.base_carrier_id = 3
      base_user.save!
    end
    
  end
end