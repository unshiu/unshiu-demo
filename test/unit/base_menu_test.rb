require File.dirname(__FILE__) + '/../test_helper'

class BaseMenuTest < ActiveSupport::TestCase
  fixtures :base_menus
  
  define_method('test: メニューのマスタ情報を取得する') do    
    base_menu = BaseMenu.new({:base_menu_master_id => 1})
    assert_not_nil(base_menu.base_menu_master)
    assert_equal(base_menu.base_menu_master.id, 1)
    assert_equal(base_menu.base_menu_master.name, "更新情報")
  end
  
  define_method('test: 表示するかどうかを判断する') do    
    base_menu = BaseMenu.new({:show_flag => true})
    assert_equal(base_menu.show?, true)
    
    base_menu = BaseMenu.new({:show_flag => false})
    assert_equal(base_menu.show?, false)
  end
  
  define_method('test: あるユーザのメニューを更新する') do    
    # base_user_id = 1 の　base_menu_master_id = 1 の　並び順を　4 番目に変更
    BaseMenu.resetting_menu(1, 1, 4)
    
    base_menus = BaseMenu.find(:all, :conditions => ['base_user_id = 1'], :order => ["base_menu_master_id"])
    
    assert_equal(base_menus[0].num, 4)
    assert_equal(base_menus[1].num, 1)
    assert_equal(base_menus[2].num, 2)
    assert_equal(base_menus[3].num, 3)
    assert_equal(base_menus[4].num, 5)
    assert_equal(base_menus[5].num, 6)  
  end
  
  define_method('test: ユーザのメニュー設定をされていないユーザが設定を更新しようとするとデフォルトを元に作成し、更新する') do    
    # base_user_id = 2 の　base_menu_master_id = 2 の　並び順を　4 番目に変更
    BaseMenu.resetting_menu(2, 2, 4)
    
    base_menus = BaseMenu.find(:all, :conditions => ['base_user_id = 2'], :order => ["base_menu_master_id"])
    
    assert_equal(base_menus[0].num, 1) # デフォルトの base_menu_masterの関係があるので
    assert_equal(base_menus[1].num, 4)
    assert_equal(base_menus[2].num, 6)
    assert_equal(base_menus[3].num, 2)
    assert_equal(base_menus[4].num, 5)
    assert_equal(base_menus[5].num, 3)  
  end
  
  define_method('test: メニュー再構築後、表示可能最大数以上のメニューは表示しない') do    
    # base_user_id = 1 の　base_menu_master_id = 2 の　並び順を　4 番目に変更
    BaseMenu.resetting_menu(1, 2, 6)
    
    base_menus = BaseMenu.find(:all, :conditions => ['base_user_id = 1'], :order => ["base_menu_master_id"])
    
    # テスト環境ではmax = 2
    assert_equal(base_menus[0].base_menu_master_id, 1)
    assert_equal(base_menus[0].num, 1)
    assert_equal(base_menus[0].show_flag, true)
    
    assert_equal(base_menus[1].base_menu_master_id, 2)
    assert_equal(base_menus[1].num, 6)
    assert_equal(base_menus[1].show_flag, false)
    
    assert_equal(base_menus[2].base_menu_master_id, 3)
    assert_equal(base_menus[2].num, 2)
    assert_equal(base_menus[2].show_flag, true)
    
    assert_equal(base_menus[3].base_menu_master_id, 4)
    assert_equal(base_menus[3].num, 3)
    assert_equal(base_menus[3].show_flag, false)
    
    assert_equal(base_menus[4].base_menu_master_id, 5)
    assert_equal(base_menus[4].num, 4)
    assert_equal(base_menus[4].show_flag, false)
    
    assert_equal(base_menus[5].base_menu_master_id, 6)
    assert_equal(base_menus[5].num, 5)
    assert_equal(base_menus[5].show_flag, false)
    
  end
end
