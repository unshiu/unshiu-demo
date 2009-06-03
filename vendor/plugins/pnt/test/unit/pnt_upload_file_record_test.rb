require File.dirname(__FILE__) + '/../test_helper'
require 'active_form'

module PntUploadFileRecordTestModule
  
  class << self
    def included(base)
      base.class_eval do
      end
    end
  end
  
  # validationのテスト
  def test_validation
    pnt_file_update_file_record = PntUploadFileRecord.new
    assert_equal(pnt_file_update_file_record.valid?, false) # 空はだめ
    
    # 必須チェック
    pnt_file_update_file_record.pnt_master_id = 1 # +pnt_master_id
    assert_equal(pnt_file_update_file_record.valid?, false) 
    pnt_file_update_file_record.base_user_id = 1  # +base_user_id
    assert_equal(pnt_file_update_file_record.valid?, false) 
    pnt_file_update_file_record.point = 100  # +point
    assert_equal(pnt_file_update_file_record.valid?, false)
    pnt_file_update_file_record.message = 'test'  # +message
    assert_equal(pnt_file_update_file_record.valid?, true) # 必須項目が全部はいったのでOK
    
    # pnt_master_idに数字以外を指定したらだめ
    pnt_file_update_file_record.pnt_master_id = 'aiueo' 
    assert_equal(pnt_file_update_file_record.valid?, false) 
    
    # base_user_idに数字以外を指定したらだめ
    pnt_file_update_file_record.pnt_master_id = 1
    pnt_file_update_file_record.base_user_id = 'aiueo' 
    assert_equal(pnt_file_update_file_record.valid?, false) 
    
    # pointに数字以外を指定したらだめ
    pnt_file_update_file_record.pnt_master_id = 1
    pnt_file_update_file_record.base_user_id = 1
    pnt_file_update_file_record.point = 'ebz'
    assert_equal(pnt_file_update_file_record.valid?, false)
  end
end
