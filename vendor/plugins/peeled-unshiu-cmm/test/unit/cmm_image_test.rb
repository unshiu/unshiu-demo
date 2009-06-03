require File.dirname(__FILE__) + '/../test_helper'

module CmmImageTestModule
  
  class << self
    def included(base)
      base.class_eval do
        include TestUtil::Base::UnitTest
        fixtures :cmm_images
      end
    end
  end
  
  define_method('test: 画像を保存する') do
    update_path = RAILS_ROOT + "/test/tmp/file_column/cmm_image/image/tmp"
    Dir::mkdir(update_path) unless File.exist?(update_path)
    image = uploaded_file(file_path("file_column/cmm_image/image/3/logo.gif"), 'image/gif', 'logo.gif')
    
    assert_difference 'CmmImage.count', 1 do
      cmm_image = CmmImage.new(:cmm_community_id => 1, :image => image)
      cmm_image.save!
    end
  end
  
end
