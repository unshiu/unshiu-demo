require File.dirname(__FILE__) + '/../test_helper'

module BaseMailDispatchInfoTestModule

  class << self
    def included(base)
      base.class_eval do
        include AuthenticatedTestHelper
        fixtures :base_mail_dispatch_infos
      end
    end
  end

  def test_mail_address
    # 正常系
    info = BaseMailDispatchInfo.find_by_dispatch(1, 'DiaEntry', 'receive', 1)
    assert_not_nil info
    assert 'test1@test', info.mail_address

    # モデルが存在しない
    info2 = BaseMailDispatchInfo.find_by_dispatch(1, 'hogehoge', 'receive', 1)
    assert_nil info2

    # 該当する振り分け情報がない
    info3 = BaseMailDispatchInfo.find_by_dispatch(3, 'DiaEntry', 'receive', 1)
    assert_nil info3
  end

end