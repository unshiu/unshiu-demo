require File.dirname(__FILE__) + '/../test_helper'

module DiaControllerTestModule
  
  class << self
    def included(base)
      base.class_eval do
        include TestUtil::Base::MobileControllerTest
      end
    end
  end

  # DiaControllerはDia系の基底クラスとして存在し、DiaController個別の機能はないためここではテストしない
  def test_truth
    assert true
  end
end
