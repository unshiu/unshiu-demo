# == Schema Information
#
# Table name: base_profiles
#
#  id                        :integer(4)      not null, primary key
#  base_user_id              :integer(4)      not null
#  name                      :string(100)
#  name_public_level         :integer(4)
#  kana_name                 :string(100)
#  kana_name_public_level    :integer(4)
#  introduction              :text
#  introduction_public_level :integer(4)
#  sex                       :integer(4)
#  sex_public_level          :integer(4)
#  civil_status              :integer(4)
#  civil_status_public_level :integer(4)
#  birthday                  :date
#  birthday_public_level     :integer(4)
#  created_at                :datetime
#  updated_at                :datetime
#  deleted_at                :datetime
#  image                     :string(255)
#  area                      :string(255)
#  area_public_level         :integer(4)
#

module BaseProfileModule
  class << self
    def included(base)
      base.extend(ClassMethods)
      base.class_eval do
        include Types::Prefectures
        include Types::Sex
        include Types::Civil
        acts_as_paranoid
        acts_as_unshiu_user_relation
        
        belongs_to :base_user
        
        validates_length_of :name, :maximum => AppResources[:base][:name_max_length], :allow_blank => true
        validates_length_of :introduction, :maximum => AppResources[:base][:body_max_length], :if => :introduction # 変な文だが、nil だと invalid になるので対策
        validates_good_word_of :name, :introduction
        validates_not_include_emoticon_of :name
        validates_date     :birthday, :allow_nil => true, :message => I18n.t('activerecord.errors.messages.invalid')
        
        validates_filesize_of :image, :in => 0..AppResources[:base][:file_size_max_image_size].to_byte_i
        validates_file_format_of :image, :in => AppResources[:base][:image_allow_format]
        
        file_column :image
      end
    end
  end
  
  module ClassMethods
    
    # 性別値から名称を取得する
    # _param1_:: value 性別値
    # _return_:: 性別名称
    def sex_kind_name(value)
      value.nil? ? nil : BaseProfile::SEX[value.to_i]
    end
    
    # 地域値から名称を取得する
    # _param1_:: value 性別値
    # _return_:: 性別名称
    def area_kind_name(value)
      value.nil? ? nil : BaseProfile::PREFECTURES[value.to_i]
    end
    
    # 配偶者値から名称を取得する
    # _param1_:: value 配偶者値
    # _return_:: 配偶者値名称  
    def civil_status_kind_name(value)
      value.nil? ? nil : BaseProfile::CIVIL[value.to_i]
    end
    
    # 男性数をカウントする
    # _return_:: 男性数
    def count_male
      count(:conditions => ['base_profiles.sex = ? ', BaseProfile::MALE])
    end
    
    # 女性数をカウントする
    # _return_:: 女性数
    def count_female
      count(:conditions => ['base_profiles.sex = ? ', BaseProfile::FEMALE])
    end
    
    # 各所在地エリアごとのカウントをする
    # _param1_:: Integer area 
    # _return_:: 地域ごとのユーザ数
    def count_area(area)
      count(:conditions => ['base_profiles.area = ? ', area])
    end

    # 未婚者数をカウントする
    # _return_:: 未婚者数
    def count_unmarried
      count(:conditions => ['base_profiles.civil_status = ? ', BaseProfile::UNMARRIED])
    end
    
    # 既婚者数をカウントする
    # _return_:: 既婚者数
    def count_married
      count(:conditions => ['base_profiles.civil_status = ? ', BaseProfile::MARRIED])
    end
    
    # プロフィール画像が添付されたメールの受信
    # _param1_:: mail 
    # _param2_:: base_mail_dispatch_info
    def receive(mail, base_mail_dispatch_info)
      unless mail.has_attachments? # 添付ファイルがない
        BaseMailerNotifier::deliver_failure_saving_base_profile_images(mail, '添付画像がありません。')
        return
      end
      
      if mail.attachments.size > 1 # 添付ファイルがあり過ぎる
        BaseMailerNotifier::deliver_failure_saving_base_profile_images(mail, '添付された画像が2つ以上あります。')
        return
      end
        
      unless BaseMailerNotifier.image?(mail.attachments.first) # 画像じゃない
        BaseMailerNotifier::deliver_failure_saving_base_profile_images(mail, '添付ファイルが画像ではありません。')
        return
      end
      
      receive_core(mail, base_mail_dispatch_info)
        
      # 保存完了メールを送る
      BaseMailerNotifier::deliver_success_saving_base_profile_images(mail, base_mail_dispatch_info.model_id)
        
    rescue => ex
      logger.info ex.to_s
      BaseMailerNotifier::deliver_failure_saving_base_profile_images(mail)
    end
    
  private

    # プロフィール画像を受信したときのメインの処理
    # _param1_:: mail
    # _param2_:: base_mail_dispatch_info
    def receive_core(mail, base_mail_dispatch_info)
      profile = BaseProfile.find(base_mail_dispatch_info.model_id)
      profile.image = mail.attachments.first
      profile.save!
    end
      
  end
  
  # サーバー環境（？）によって、数字8桁を Date に変換できないことがあるようなので　/ 付きに明示的に変換
  def attributes=(new_attributes)
    if new_attributes[:birthday] && new_attributes[:birthday].is_a?(String)
      new_attributes[:birthday].gsub!(/([0-9]{4,})([0-9]{2,})([0-9]{2,})/) do
        $1 + '/' + $2 + '/' + $3
      end
    end
    
    super
  end
  
  # サーバー環境（？）によって、数字8桁を Date に変換できないことがあるようなので　/ 付きに明示的に変換
  def birthday=(new_birthday)
    if new_birthday && new_birthday.is_a?(String)
      new_birthday.gsub!(/([0-9]{4,})([0-9]{2,})([0-9]{2,})/) do
        $1 + '/' + $2 + '/' + $3
      end
    end
    
    super
  end
  
  # name を base_user と同期させる
  def after_save
    if base_user && base_user.name != self.name
      base_user.update_attribute(:name, self.name)
    end
  end
  
end
