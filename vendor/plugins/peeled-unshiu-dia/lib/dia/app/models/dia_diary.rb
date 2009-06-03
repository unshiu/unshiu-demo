# == Schema Information
#
# Table name: dia_diaries
#
#  id                   :integer(4)      not null, primary key
#  base_user_id         :integer(4)      not null
#  default_public_level :integer(4)
#  created_at           :datetime
#  updated_at           :datetime
#  deleted_at           :datetime
#

module DiaDiaryModule
  
  class << self
    def included(base)
      base.extend(ClassMethods)
      base.class_eval do
        acts_as_paranoid

        # 日記の所有者
        belongs_to :base_user

        # 日記に属する記事（下書きを含まない）
        has_many :dia_entries, :conditions => "draft_flag = false", :order => 'created_at desc', :dependent => :destroy

        # 日記に属する下書き記事
        has_many :dia_draft_entries, :class_name => "DiaEntry", :foreign_key => "dia_diary_id",
                 :conditions => "draft_flag = true", :order => 'created_at desc', :dependent => :destroy
        
      end
    end
  end
  
  # base_user がアクセス可能なこの日記の記事を返す
  # _base_user_:: アクセスユーザー
  # _return_:: base_user がアクセス可能なこの日記の記事
  def accesible_entries(base_user)
    owner_id = self.base_user_id
    if base_user && base_user != :false # means logged_in?
      if base_user.me?(owner_id)
        dia_entries.owner_accesible
      
      elsif base_user.friend?(owner_id)
        dia_entries.friend_accesible
        
      elsif base_user.foaf?(owner_id)
        dia_entries.foaf_accesible
        
      else
        dia_entries.uncontacts_user_accesible
      end
    else
      dia_entries.unuser_accesible
    end
  end
  
  # base_user の日記かの判定
  # _base_user_:: アクセスユーザー
  # _return_:: base_user が日記の所有者なら true、それ以外なら false
  def mine?(base_user)
    if base_user && base_user != :false # means logged_in?
      self.base_user_id == base_user.id
    else
      return false
    end
  end
  
  module ClassMethods
    # ユーザーの日記を探しそれを返す、日記がない場合は作成してそれを返す
    # 対象のユーザーが複数の日記をもっている場合はいずれかを返す（利用を推奨しない）
    # _base_user_id_:: 対象のユーザーID
    # _return_:: 対象ユーザーの日記
    def find_or_create(base_user_id)
        diary = self.find_by_base_user_id(base_user_id)
        if diary
          diary
        else
          diary = DiaDiary.create(base_user_id)
        end
    end
  
    # ユーザーの日記を作る
    # 2つめ以降でも作成する
    # _base_user_id_:: 対象のユーザーID
    # _return_:: 作成した日記
    def create(base_user_id)
      diary = self.new
      diary.base_user_id = base_user_id
      diary.default_public_level = AppResources["dia"]["default_default_public_level"]
      diary.save
    
      return diary
    end
  end
end
