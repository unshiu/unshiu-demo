# == Schema Information
#
# Table name: base_mail_templates
#
#  id                         :integer(4)      not null, primary key
#  base_mail_template_kind_id :integer(4)      not null
#  content_type               :string(255)     not null
#  subject                    :string(255)     not null
#  body                       :text            default(""), not null
#  active_flag                :boolean(1)
#  footer_flag                :boolean(1)
#  deleted_at                 :datetime
#  created_at                 :datetime
#  updated_at                 :datetime
#  device_type                :integer(4)      not null
#

module BaseMailTemplateModule
  class << self
    def included(base)
      base.extend(ClassMethods)
      base.class_eval do
        acts_as_paranoid
        
        belongs_to :base_mail_template_kind
        
        validates_length_of :subject, :maximum => AppResources[:base][:title_max_length]
        validates_length_of :body, :maximum => AppResources[:base][:body_max_length]
        validates_presence_of :body, :subject
        validates_presence_of :base_mail_template_kind_id
        validates_presence_of :content_type, :device_type
        
        validates_inclusion_of :active_flag, :footer_flag, :in=>[true,false]
        
        named_scope :draft_by_action, lambda { |action_name| 
          { :include => [:base_mail_template_kind], 
            :conditions => [ 'base_mail_template_kinds.action = ? and active_flag = false ', action_name ] }
        }
        
        const_set('DEVICE_TYPE_MOBILE', 1)
        const_set('DEVICE_TYPE_PC', 2)
      end
      
    end
  end
  
  module ClassMethods
    # 指定処理において有効なメールテンプレートを取得する
    # 各送信先デバイスごとにアクティブなメールテンプレートはあるので複数値返る可能性がある
    # _param1_:: action_name
    # _return_:: Array(BaseMailTemplate)
    def find_active_mail_templates_by_action(action_name)
      find(:all, :include => [:base_mail_template_kind], 
           :conditions => [ 'base_mail_template_kinds.action = ? and active_flag = true ', action_name ] )
    end

    # 指定テンプレート種別IDにおいて有効なメールテンプレートを取得する
    # 各送信先デバイスごとにアクティブなメールテンプレートはあるので複数値返る可能性がある
    # _param1_:: template_kind_id
    # _return_:: Array(BaseMailTemplate)
    def find_active_mail_templates_by_template_kind_id(template_kind_id)
      find(:all, :conditions => ['base_mail_template_kind_id = ? and active_flag = true', template_kind_id])
    end
    
    # 指定処理の指定デバイスおいて有効なメールテンプレートを取得する
    # _param1_:: action_name
    # _param2_:: device_type
    # _return_:: BaseMailTemplate
    def find_active_mail_template_by_action_name_and_device_type(action_name, device_type)
      find(:first, :include => [:base_mail_template_kind], 
           :conditions => [ 'base_mail_template_kinds.action = ? and device_type = ? and active_flag = true ', action_name, device_type ] )
    end
    
    # 指定処理の指定デバイスおいて有効なメールテンプレートを取得する
    # _param1_:: base_mail_template_kind_id
    # _param2_:: device_type
    # _return_:: BaseMailTemplate
    def find_active_mail_template_by_template_kind_id_and_device_type(base_mail_template_kind_id, device_type)
      find(:first, :conditions => [ 'base_mail_template_kind_id = ? and device_type = ? and active_flag = true ', base_mail_template_kind_id, device_type ] )
    end
    
    # 設定可能なメールタイプ一覧
    def content_types
      {'HTMLメール' => 'text/html', 'テキストメール' => 'text/plain'}
    end
    
    # 送信デバイス先タイプ
    def device_types
      {'PC用' => BaseMailTemplate::DEVICE_TYPE_PC, '携帯用' => BaseMailTemplate::DEVICE_TYPE_MOBILE}
    end
    
  end
  
  # フッターを利用するかどうかを判断する
  def footer?
    self.footer_flag
  end
  
  # 現在利用設定がされているか
  def active?
    self.active_flag
  end
  
  # 表示用のメールタイプを返す
  def view_content_type
    BaseMailTemplate.content_types.each_pair do |key, value|
      return key if value == self.content_type
    end
    return nil
  end
  
  # 表示用の送信デバイスタイプを返す
  def view_device_type
    BaseMailTemplate.device_types.each_pair do |key, value|
      return key if value == self.device_type
    end
    return nil
  end
end
