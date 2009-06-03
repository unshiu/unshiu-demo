require File.dirname(__FILE__)+'/helper'

class DocomoWithDBTest < Test::Unit::TestCase
  Jpmobile::USE_DB = true
  
  def setup
    Jpmobile::Model::JpmobileDevice.delete_all
  end
  
  # DoCoMo, 端末種別の識別
  def test_docomo_sh902i
    jpmobile_device = Jpmobile::Model::JpmobileDevice.new({:device => "SH902i", :name => "SH902i", :model => "SH902i",
                                                           :gif => true, :jpg => true, :png => false, :flash => true,
                                                           :flash_version => "1.1", :ssl => true})
    jpmobile_device.save!
  
    reqs = request_with_ua("DoCoMo/2.0 SH902i(c100;TB;W24H12)")
    reqs.each do |req|
      assert_equal(true, req.mobile?)
      assert_instance_of(Jpmobile::Mobile::Docomo, req.mobile)
      assert_equal(nil, req.mobile.position)
      assert_equal(nil, req.mobile.areacode)
      assert_equal(nil, req.mobile.serial_number)
      assert_equal(nil, req.mobile.icc)
      assert_equal(nil, req.mobile.ident)
      assert_equal(nil, req.mobile.ident_device)
      assert_equal(nil, req.mobile.ident_subscriber)
      assert(!req.mobile.supports_cookie?)
      
      assert_equal("SH902i", req.mobile.device_id)
      assert_equal("SH902i", req.mobile.device_name)
      assert_equal(true, req.mobile.gif?)
      assert_equal(true, req.mobile.jpg?)
      assert_equal(false, req.mobile.png?)
      assert_equal(true, req.mobile.flash?)
      assert_equal("1.1", req.mobile.flash_version)
      assert_equal(true, req.mobile.ssl?)
    end
  end

end
