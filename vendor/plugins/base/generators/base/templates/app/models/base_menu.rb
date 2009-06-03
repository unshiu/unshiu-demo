# == Schema Information
#
# Table name: base_menus
#
#  id                  :integer(4)      not null, primary key
#  base_user_id        :integer(4)      not null
#  base_menu_master_id :integer(4)      not null
#  num                 :integer(4)      not null
#  show_flag           :boolean(1)      default(TRUE), not null
#  deleted_at          :datetime
#  created_at          :datetime
#  updated_at          :datetime
#

class BaseMenu < ActiveRecord::Base
  belongs_to :base_user
  
  # マスタ情報を取得する
  def base_menu_master
    BaseMenuMaster.find(self.base_menu_master_id)
  end
  
  # 表示するメニューかどうか
  def show?
    self.show_flag
  end
  
  # ユーザのメニューを再設定する
  # _param1_:: base_user_id
  # _param2_:: base_menu_master_id 移動するメニューID
  # _param3_:: num　移動値
  def self.resetting_menu(base_user_id, base_menu_master_id, num)
    base_menus = find(:all, :conditions => ["base_user_id = ? ", base_user_id], :order => ["num"])
    
    if base_menus.empty?
      base_menu_masters = BaseMenuMaster.all_menus
      base_menu_masters.each do |master|
        base_menu = BaseMenu.new({:base_user_id => base_user_id, :base_menu_master_id => master.id, :num => master.num})
        base_menu.save
        base_menus << base_menu
      end
    end
    update_base_menu = find(:first, :conditions => ["base_user_id = ? and base_menu_master_id = ? ", base_user_id, base_menu_master_id])
    
    base_menus.delete(update_base_menu)
    base_menus.insert(num-1, update_base_menu)
    base_menus = base_menus.compact
    
    base_menus.each_with_index do |base_menu, index|
      base_menu.num = index + 1
      base_menu.show_flag = (index + 1 <= AppResources[:base][:menu_max_size].to_i)
      base_menu.save
    end
    
  end
end
