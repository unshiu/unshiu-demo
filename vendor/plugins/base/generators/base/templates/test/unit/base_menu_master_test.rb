require File.dirname(__FILE__) + '/../test_helper'

class BaseMenuMasterTest < ActiveSupport::TestCase
  
  define_method('test: マスタ情報を取得する') do 
    base_menu_master = BaseMenuMaster.find(1)
    assert_not_nil(base_menu_master)
    assert_equal(base_menu_master.id, 1)
  end
  
  define_method('test: メニュー一覧をnum順に取得する') do 
    base_menu_masters = BaseMenuMaster.all_menus
    
    assert_not_nil(base_menu_masters)
    assert_equal(base_menu_masters.size, 6)
    
    show_menu_num = 1
    unshow_menu_num = 1
    base_menu_masters.each do |menu|
      assert_not_nil(menu.id)
      assert_not_nil(menu.name)
      assert_not_nil(menu.url)
      assert_not_nil(menu.icon)
      if menu.default_show
        assert_equal(menu.num, show_menu_num)
        show_menu_num += 1
      else
        assert_equal(menu.num, unshow_menu_num)
        unshow_menu_num += 1
      end
    end
  end
  
  define_method('test: 標準で表示する設定になっているメニュー一覧をnum順に取得する') do 
    base_menu_masters = BaseMenuMaster.all_default_show_menus
    
    assert_not_nil(base_menu_masters)
    assert_equal(base_menu_masters.size, 4)
    
    num = 1
    base_menu_masters.each do |menu|
      assert_equal(menu.num, num)
      assert_not_nil(menu.id)
      assert_not_nil(menu.name)
      assert_not_nil(menu.url)
      assert_not_nil(menu.icon)
      assert_not_nil(menu.num)
      assert_equal(menu.default_show, true)
      num += 1
    end
  end
  
  define_method('test: 標準では表示しない設定になっているメニュー一覧をnum順に取得する') do 
    base_menu_masters = BaseMenuMaster.all_default_unshow_menus
    
    assert_not_nil(base_menu_masters)
    assert_equal(base_menu_masters.size, 2)
    
    num = 1
    base_menu_masters.each do |menu|
      assert_equal(menu.num, num)
      assert_not_nil(menu.id)
      assert_not_nil(menu.name)
      assert_not_nil(menu.url)
      assert_not_nil(menu.icon)
      assert_not_nil(menu.num)
      assert_equal(menu.default_show, false)
      num += 1
    end
  end
end
