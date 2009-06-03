require File.dirname(__FILE__) + '/../test_helper'
require File.dirname(__FILE__) + '/../../vendor/plugins/abm/test/unit/abm_album_test.rb'

class AbmAlbumTest < ActiveSupport::TestCase
  include AbmAlbumTestModule
  
  # You must write UnitTest!!
  def test_default
    assert true
  end
  
end
